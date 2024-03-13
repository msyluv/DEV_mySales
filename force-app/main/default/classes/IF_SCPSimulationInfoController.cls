/**
* @description       : Receive Records of SCPSimulation Object from SCP for UPSERT Operation(IF-183)
* @author            : vikrant.ks@samsung.com
* @group             : 
* @last modified on  : 2023-08-09 
* @last modified by  : vikrant.ks@samsung.com 
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2023-07-25    vikrant.ks@samsung.com   Initial Version(MySales 265)
* 1.1   2023-08-09    vikrant.ks@samsung.com   Add lookup field of opportunity(MySales 265)
**/
@RestResource(urlMapping = '/IF183/*')
global class IF_SCPSimulationInfoController{
    private static final String INTERFACE_ID = 'IF-183';
    private static final String APEX_CLASS   = 'IF_SCPSimulationInfoController';
    private static final String METHOD_NAME  = 'ReceiveDatafromSCP'; 
    private static String guId = IF_Util.generateGuid();
    
    @HttpPost
    global static void ReceiveDatafromSCP(){
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
            
            inputJsonData = reqBody.toString();
            system.debug('inputJsonData : ' + inputJsonData);
            ifLog.addLog('HttpRequest : ' + inputJsonData); 
            
            InputHeader inputHeader = (InputHeader) JSON.deserialize(inputJsonData, InputHeader.class);
            
            List<Opportunity> oppId = new List<Opportunity>([Select Id from Opportunity where OpportunityCode__c = :inputHeader.boCode and CompanyCode__c = :inputHeader.companyCode]);//v1.1
            
            List<SCPSimulation__c> SCPId = new List<SCPSimulation__c>([Select Id from SCPSimulation__c where BOCode__c = :inputHeader.boCode and companyCode__c = :inputHeader.companyCode and quotId__c = :inputHeader.quotId]) ;
            
            SCPSimulation__c temp = new SCPSimulation__c();
            
            if(SCPId.size()>0){
                temp.Id = SCPId[0].Id;
            } 
            if(oppId.size()>0){
                temp.Opportunity__c = oppId[0].Id; //v1.1
            }
            temp.BOCode__c      = inputHeader.boCode;
            temp.companyCode__c = inputHeader.companyCode;
            temp.quotNm__c      = inputHeader.quotNm;
            temp.quotId__c      = inputHeader.quotId;
            
            if(inputHeader.orderRate != null && inputHeader.orderRate != ''){
                temp.orderRate__c   = Decimal.valueOf(inputHeader.orderRate);}
            
            temp.az__c          = inputHeader.aZ;
            
            if(inputHeader.totAmt != null && inputHeader.totAmt != ''){
                temp.totAmt__c      = Decimal.valueOf(inputHeader.totAmt);}
            
            temp.crncyCd__c     = inputHeader.crncyCd;
            temp.serviceDt__c   = inputHeader.serviceDt;
            temp.quotStat__c    = inputHeader.quotStat;
            
            if(inputHeader.regDate != null && inputHeader.regDate != ''){
                temp.regDate__c     = Date.valueOf(inputHeader.regDate);}
            
            if(inputHeader.chgDate != null && inputHeader.chgDate != ''){
                temp.chgDate__c     = Date.valueOf(inputHeader.chgDate);}
			
            upsert temp;
            
            outHeader.RESULT = 'S';
            String sendData = JSON.serialize(outHeader);
            ifLog.addLog('Response : ' + sendData);
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData);
            
        }catch(Exception e){
            
            outHeader.RESULT = 'F';
            String sendData          = JSON.serialize(outHeader);
            ifLog.addLog('Response : ' + sendData);            
            ifLog.addLog('Exception : ' + e.getMessage());
            System.debug('Exception : ' + e.getMessage());
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
        public String boCode;
        public String companyCode;
        public String quotNm;
        public String quotId;
        public String orderRate;
        public String aZ;
        public String totAmt;
        public String crncyCd;
        public String serviceDt;
        public String quotStat;
        public String regDate;
        public String chgDate;
    }
}