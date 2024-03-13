/**
* @description       : Receives the completed information of the Approval by version from SD for HQ mailing(IF-185)
* @author            : vikrant.ks@samsung.com
* @group             : 
* @last modified on  : 2023-11-28
* @last modified by  : vikrant.ks@samsung.com 
* Modifications Log 
* Ver   Date          Author                   Modification
* 1.0   2023-08-16    vikrant.ks@samsung.com   Initial Version(MySales 278)
* 1.1   2023-10-10    vikrant.ks@samsung.com   Added four new fields(MySales 317)
* 1.2   2023-11-28    vikrant.ks@samsung.com   Added two new fields.(MySales 367)
**/
@RestResource(urlMapping = '/IF185/*')
global class IF_SDApprovalInfoController{
    private static final String INTERFACE_ID = 'IF-185';
    private static final String APEX_CLASS   = 'IF_SDApprovalInfoController';
    private static final String METHOD_NAME  = 'ReceiveDatafromSD'; 
    private static String guId = IF_Util.generateGuid();
    
    @HttpPost
    global static void ReceiveDatafromSD(){
        
        OutputHeader outHeader   = new OutputHeader();
        IF_Log ifLog;
        IF_Log.InterfaceLog interfaceLog;
        List<String> errorMsgList = new List<String>();        
		RestResponse rep = RestContext.response;
        String inputJsonData;
        
        
		ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');
		try
        {
            RestRequest req = RestContext.request;
            Blob    reqBody = req.requestBody;
            rep.addHeader('Content-Type', 'application/json');
            
            if(reqBody == null || reqBody.toString() == '{}') {
                outHeader.RESULT = 'F';
                rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData,JSON.serialize(outHeader),new List<String>{'Request format is incorrect.'});
                ifLog.createLog(interfaceLog);
                return;      
            }
            inputJsonData = reqBody.toString();
            ifLog.addLog('HttpRequest : ' + inputJsonData); 
            
            InputHeader inputHeader = (InputHeader) JSON.deserialize(inputJsonData, InputHeader.class);
            
            //V1.1 Start
            Map<String , Decimal> isoWithRateMap = new Map<String, Decimal>();
            
            Date tempCloseDate = Date.valueOf(inputHeader.Closedate.replace('.', '-'));
            List<DatedConversionRate> currencyTypeList = [SELECT IsoCode, ConversionRate, startdate, nextstartdate FROM DatedConversionRate where StartDate <= :tempCloseDate and NextStartDate > :tempCloseDate];
            
            for(DatedConversionRate d : currencyTypeList) {
                isoWithRateMap.put(d.IsoCode , d.ConversionRate);
            }
            if(inputHeader.Curr == null || isoWithRateMap.containsKey(inputHeader.Curr) == false){
                outHeader.RESULT = 'F';
                rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData,JSON.serialize(outHeader),new List<String>{'Invalid Currency Code.'});
                ifLog.createLog(interfaceLog);
                return;
            }
            //V1.1 End
            
            List<Opportunity> oppId = new List<Opportunity>([Select Id from Opportunity where Opportunitycode__c = :inputHeader.OpportunityCode and Companycode__c = :inputHeader.CompanyCode]);
                        
            List<OpportunityAmt__c> SDId = new List<OpportunityAmt__c>([Select Id from OpportunityAmt__c where Opportunitycode__c = :inputHeader.OpportunityCode and Companycode__c = :inputHeader.CompanyCode and Version__c = :inputHeader.Version]) ;
            
            OpportunityAmt__c temp = new OpportunityAmt__c();
            
            if(SDId.size()>0){ temp.Id = SDId[0].Id; } 
            
            if(oppId.size()>0){ temp.Opportunity__c = oppId[0].Id; }
            
            temp.Opportunitycode__c = inputHeader.OpportunityCode;
            temp.Companycode__c 	= inputHeader.CompanyCode;
            temp.Version__c 		= inputHeader.Version;
            temp.Currency__c 		= inputHeader.Curr;
            temp.CurrencyLoc__c 	= inputHeader.Currency_Loc;
            temp.Rateyn__c 			= inputHeader.Rate_yn;
            
            if(inputHeader.Closedate != null && inputHeader.Closedate != ''){
                temp.Closedate__c     = Date.valueOf(inputHeader.Closedate.replace('.', '-'));} 
            else{
                temp.Closedate__c = null;
            }
            //V1.1 Start
            Decimal krwRate = 1;
            if(inputHeader.Curr != 'KRW'){
                krwRate = (isoWithRateMap.get('KRW')/isoWithRateMap.get(inputHeader.Curr));
            }
            Decimal usdRate = (isoWithRateMap.get('USD')/isoWithRateMap.get(inputHeader.Curr));
            //V1.1 End
            
            if(inputHeader.TotalAmt != null && inputHeader.TotalAmt != ''){
                temp.TotalAmt__c     = Decimal.valueOf(inputHeader.TotalAmt);
                temp.TotalAmtKRW__c  = (temp.TotalAmt__c*krwRate).setscale(2);//V1.1
                temp.TotalAmtUSD__c  = (temp.TotalAmt__c*usdRate).setscale(2);//V1.1
            }
            
            if(inputHeader.DiffAmt != null && inputHeader.DiffAmt != ''){
                temp.DiffAmt__c     = Decimal.valueOf(inputHeader.DiffAmt);
                temp.DiffAmtKRW__c  = (temp.DiffAmt__c*krwRate).setscale(2);//V1.1
                temp.DiffAmtUSD__c  = (temp.DiffAmt__c*usdRate).setscale(2);//V1.1
             }
            
            if(inputHeader.TotalAmt_Loc != null && inputHeader.TotalAmt_Loc != ''){
                temp.TotalAmtLoc__c     = Decimal.valueOf(inputHeader.TotalAmt_Loc);
            }
            
            if(inputHeader.DiffAmt_Loc != null && inputHeader.DiffAmt_Loc != ''){
                temp.DiffAmtLoc__c     = Decimal.valueOf(inputHeader.DiffAmt_Loc);
            }
            //V1.2 Start
            temp.Contractno__c 		   = inputHeader.Contractno;
            if(inputHeader.Confirmdate != null && inputHeader.Confirmdate != ''){
                temp.Confirmdate__c     = Date.valueOf(inputHeader.Confirmdate.replace('.', '-'));}
            else{
                temp.Confirmdate__c = null;
            }
            //V1.2 End
            
            upsert temp;
            
            outHeader.RESULT = 'S';
            String sendData = JSON.serialize(outHeader);
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData);
            
        }catch(Exception e){
            
            outHeader.RESULT = 'F';
            String sendData          = JSON.serialize(outHeader);
            errorMsgList.add('Exception : ' + e.getMessage());

            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData, e); 
        }
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');
        ifLog.createLog(interfaceLog);        

        rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));

    }
    
	public class OutputHeader{
        public String RESULT;
    }
    
    public class InputHeader{
        
        public String OpportunityCode;
        public String CompanyCode;
        public String Version;
        public String Closedate;
        public String TotalAmt;
        public String Curr;
        public String DiffAmt;
        public String TotalAmt_Loc;
        public String Currency_Loc;
        public String DiffAmt_Loc;
        public String Rate_yn;
        public String Contractno;//V1.2
		public String Confirmdate;//V1.2
    }
}