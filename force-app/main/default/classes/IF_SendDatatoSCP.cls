/**
* @description       : Send BO information for request of SCP/Legal system (IF-182)
* @author            : vikrant.ks@samsung.com
* @group             : 
* @last modified on  : 2023-06-12 
* @last modified by  : vikrant.ks@samsung.com 
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2023-06-12   vikrant.ks@samsung.com   Initial Version(MySales 230)
**/
@RestResource(urlMapping = '/IF182/*')
global class IF_SendDatatoSCP {
    
    private static final String INTERFACE_ID = 'IF-182';
    private static final String APEX_CLASS   = 'IF_SendDatatoSCP';
    private static final String METHOD_NAME  = 'SendDatatoSCP'; 
    private static String guId = IF_Util.generateGuid();
    
    @HttpPost
    global static void SendDatatoSCP(){
        
        OutputHeader outHeader   = new OutputHeader();
        IF_Log ifLog;
        IF_Log.InterfaceLog interfaceLog;
        List<String> errorMsgList = new List<String>();
		RestResponse rep = RestContext.response;
		String inputJsonData;
        
        try
        {   
            Map<String,String> stageMap = new Map<String,String>{'Z01'=>'Identified','Z02'=>'Validated','Z03'=>'Qualified','Z04'=>'Solutioned','Z05'=>'Won','Z06'=>'Lost','Z07'=>'Dropped','Z08'=>'Cleansed'};
            Map<String,String> statusMap = new Map<String,String>();
            Schema.PicklistEntry[] picklist = Opportunity.OpportunityStatus__c.getDescribe().getPicklistValues();
            for (Schema.PicklistEntry p : picklist) {
                statusMap.put(p.getValue(),p.getLabel());
            }
            
            ifLog = new IF_Log();
            ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');
            
            RestRequest req = RestContext.request;
            Blob    reqBody = req.requestBody;  
            
            rep.addHeader('Content-Type', 'application/json');
            
            if(reqBody == null || reqBody.toString() == '{}') {
                outHeader.RESULT = 'F';
                outHeader.RESULT_MESSAGE = 'Request format is incorrect.';
                rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(),JSON.serialize(outHeader));
                ifLog.createLog(interfaceLog);
                return;      
            }
            
            inputJsonData = reqBody.toString();
            system.debug('inputJsonData : ' + inputJsonData);
            ifLog.addLog('HttpRequest : ' + inputJsonData); 
            
            String query='Select OpportunityCode__c,Name,OpportunityStatus__c,StageName,Account.Name,CloseDate,Owner.Name,'+
                         'Owner.Email,CompanyCode__c,EPCompanyCode__c,Amount,ProposalPM__r.Name,cRevenueStartDate__c,cRevenueEndDate__c,'+
                         'cOriginAcc__r.Name,cPrimarySalesDepartment__r.Name,SalesDepartment__r.Name,CurrencyIsoCode,Reuse__c, ReuseReason__c from Opportunity ';
            
            InputHeader inputHeader = (InputHeader) JSON.deserialize(inputJsonData, InputHeader.class); 
            if(validate(inputHeader)){
                outHeader.RESULT = 'F';
                outHeader.RESULT_MESSAGE = 'Request format is incorrect.';
                rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData,JSON.serialize(outHeader));
                ifLog.createLog(interfaceLog);
                return;
            }
            
            String hq= 'HQ';        
            query+= 'where RecordType.Name = :hq ';
            
            if(inputHeader.ACCOUNT_ID != Null && inputHeader.ACCOUNT_ID != ''){
                String accId = inputHeader.ACCOUNT_ID;
                query+= 'AND Account.AccountNumber = :accId ';  
            }
            
            if(inputHeader.TYPE != Null && inputHeader.TYPE != '' && inputHeader.TYPE == 'SCP'){
                String csp = 'CSP';
                String csp_scp ='CSP_SCP';
                query+= 'AND CspMspType__c = :csp AND CMBizType__c = :csp_scp ';  
            }
            
            if(inputHeader.BO_CODE != Null && inputHeader.BO_CODE != ''){
                String BoCode = '%'+ inputHeader.BO_CODE +'%';
                query+= 'AND OpportunityCode__c LIKE :BoCode ';   
            }
            
            if(inputHeader.BO_NAME != Null && inputHeader.BO_NAME != ''){
                String temp1 = '%'+inputHeader.BO_NAME+'%';
                query+= ' AND Name LIKE :temp1 ';
            }
            if(inputHeader.BO_OWNER_EMAIL != Null && inputHeader.BO_OWNER_EMAIL != ''){
                string temp=inputHeader.BO_OWNER_EMAIL;
                query+= ' AND Owner.Email = :temp ';
            }
            if(inputHeader.SYSTEM_ID == '2'){
                query+= ' order by LastModifiedDate DESC limit 3';
            }else{
            query+= ' ORDER BY Name ASC';
            query+=  (Test.isRunningTest()?' LIMIT 200':'');
            }
            List<Opportunity> objList=Database.query(query);
            
            if(inputHeader.BO_CODE != Null && inputHeader.BO_CODE != '' && objList.size()>1)
            {
                for (Integer i = (objList.size()-1) ; i>= 0 ; i--){
                    if(objList[i].CompanyCode__c != 'T100'){
                        objList.remove(i);
                    }
                }
            }
            
            List<OutputClass> OpportunityList = new List<OutputClass>();
            
            for(Opportunity opp : objList)
            {	
                OutputClass opportunity         = new OutputClass();
                opportunity.BO_CODE             = opp.OpportunityCode__c;
                opportunity.BO_NAME             = opp.Name;
                opportunity.BO_STATUS           = statusMap.get(opp.OpportunityStatus__c);
                opportunity.BO_STAGE            = stageMap.get(opp.StageName);
                opportunity.CONTRACT_ACCOUNT    = opp.Account.Name;  
                opportunity.CLOSE_DATE          = datetoString(opp.CloseDate);
                opportunity.SALES_REP_NAME      = opp.Owner.Name;
                opportunity.SALES_REP_EMAIL     = opp.Owner.Email;
                opportunity.ORIGIN_ACCOUNT      = opp.cOriginAcc__r.Name;
                opportunity.SALES_DEPT_NAME     = opp.SalesDepartment__r.Name;
                opportunity.DELIVERY_DEPT_NAME  = opp.cPrimarySalesDepartment__r.Name;
                opportunity.CONTRACT_START_DATE = datetoString(opp.cRevenueStartDate__c);
                opportunity.CONTRACT_END_DATE   = datetoString(opp.cRevenueEndDate__c);
                opportunity.PROPOSAL_PM         = opp.ProposalPM__r.Name;
                opportunity.AMOUNT              = String.valueOf(opp.Amount);
                opportunity.CURRENCY_CODE       = opp.CurrencyIsoCode;
                opportunity.COMPANY_CODE        = opp.EPCompanyCode__c;
                opportunity.REUSE               = opp.Reuse__c; 
                opportunity.REUSE_REASON        = opp.ReuseReason__c;

                OpportunityList.add(opportunity);
            }
            outHeader.RESULT = 'S';
            outHeader.RESULT_MESSAGE = 'The request has been processed successfully.';
            outHeader.BO_LIST = OpportunityList;
            
            String sendData = JSON.serialize(outHeader);
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData);
        }   
        catch(Exception e)
        {
            outHeader.RESULT = 'F';
            outHeader.RESULT_MESSAGE = 'An error occurred when processing the request.' +' | '+e.getMessage();
            String sendData          = JSON.serialize(outHeader);
            ifLog.addLog('Response : ' + sendData);            
            ifLog.addLog('Exception : ' + e.getMessage());
            errorMsgList.add('Exception : ' + e.getMessage());
            
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData, e);     
        }
        
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');
        ifLog.createLog(interfaceLog);        
        
        rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
        
    }
    
    public class OutputHeader{
        public String RESULT;
        public String RESULT_MESSAGE;
        public List<OutputClass> BO_LIST;
    }
    public class OutputClass{
        
        public String BO_CODE;
        public String BO_NAME;
        public String BO_STATUS;
        public String BO_STAGE;
        public String CONTRACT_ACCOUNT;
        public String CLOSE_DATE;
        public String SALES_REP_NAME;
        public String SALES_REP_EMAIL;
        public String ORIGIN_ACCOUNT;
        public String SALES_DEPT_NAME;
        public String DELIVERY_DEPT_NAME;
        public String CONTRACT_START_DATE;
        public String CONTRACT_END_DATE;
        public String PROPOSAL_PM;
        public String AMOUNT;
        public String CURRENCY_CODE;
        public String COMPANY_CODE;
        public String REUSE;
		public String REUSE_REASON;
    }
    public class InputHeader{
        public String SYSTEM_ID;
        public String ACCOUNT_ID;
        public String TYPE;
        public String BO_CODE;
        public String BO_NAME;
        public String BO_OWNER_EMAIL;
    }
    public static Boolean validate(InputHeader inputHeader)
    {   
        if(inputHeader.SYSTEM_ID == Null) return true;
        if(inputHeader.SYSTEM_ID != '1' && inputHeader.SYSTEM_ID != '2') return true;
        Boolean flag = true;
        
        if(inputHeader.ACCOUNT_ID != Null && inputHeader.ACCOUNT_ID != '') flag = false;
        if(inputHeader.TYPE != Null && inputHeader.TYPE != '')
        {
            if(inputHeader.TYPE != 'SCP') return true;
            flag = false;
        } 
        if(inputHeader.BO_CODE != Null && inputHeader.BO_CODE != '') flag = false;
        if(inputHeader.BO_NAME != Null && inputHeader.BO_NAME != '') flag = false;
        if(inputHeader.BO_OWNER_EMAIL != Null && inputHeader.BO_OWNER_EMAIL != '') flag = false;
        return flag;
    }
    public static String datetoString(Date d)
    {	
        String nullString;
        if(d == Null) return nullString;
        String sMonth = String.valueof(d.month());
        String sDay = String.valueof(d.day());
        if(sMonth.length()==1){
            sMonth = '0' + sMonth;
        }
        if(sDay.length()==1){
            sDay = '0' + sDay;
        }
        return String.valueof(d.year()) + sMonth + sDay ;
    }
}