/**
 * @description       : 
 * @author            : akash.g@samsung.com
 * @group             : 
 * @last modified on  : 06-17-2022
 * @last modified by  : akash.g@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   06-17-2022   akash.g@samsung.com   Initial Version
 **/
@RestResource(urlMapping = '/IF156/*')
global class IF_SdUpdatePMFieldController {
    private static final String INTERFACE_ID = 'IF-156';
    private static final String APEX_CLASS   = 'IF_SdUpdatePMFieldController';
    private static final String METHOD_NAME  = 'doPost';
    private static String boCode, companyCode,proposalPM,execPM;
   
    @HttpPost
    global static OutputHeader doPost() {
        String guId = IF_Util.generateGuid();
        IF_Log.InterfaceLog infLog;
        IF_Log log = new IF_Log();
        RestRequest req = RestContext.request;
        system.debug('Request**=' + req);
        Blob reqBody = req.requestBody;
        system.debug('reqBody**=' + reqBody);
        
        InputHeader input = (InputHeader)JSON.deserializeStrict(reqBody.toString(),InputHeader.class);
        system.debug('Input**=' + input);
        OutputHeader outHeader = new OutputHeader();
        SavePoint sp = DataBase.setSavePoint();
        try{
            boCode = input.BO_CODE;
            companyCode = input.Company_Code;
            proposalPM = input.Proposal_PM;
            execPM = input.Exec_PM;
            system.debug('boCode**=' + boCode + 'companyCode**=' + companyCode + 'proposalPM**=' + proposalPM + 'execPM**=' + execPM);
            List<opportunity> updatedOpportunity = new List<opportunity>();
            Opportunity opp = [Select id,ProposalPM__c,RepresentativePM__c from opportunity where OpportunityCode__c =: boCode AND CompanyCode__c =: companyCode];
            if(String.isNotBlank(proposalPM) && opp != null ){
                ID empID = [Select Id from Employee__c where EvSapEmpNO__c =: proposalPM].Id;
                if(opp.ProposalPM__c != empID){
                     opp.ProposalPM__c = empID;
               		 updatedOpportunity.add(opp);
                }
            }
            if(String.isNotBlank(execPM)  && opp != null){
                ID empRepID = [Select Id from Employee__c where EvSapEmpNO__c =: execPM].Id;
                if(opp.RepresentativePM__c != empRepID){
                    opp.RepresentativePM__c = empRepID;
                	updatedOpportunity.add(opp);
                }
            }
            system.debug('updatedOpportunitySize=' + updatedOpportunity.size());
            if(updatedOpportunity.size() > 0){
                update opp;
            }
            outHeader.RESULT  = IF_Util.RESULT_STATUS_SUCCESS;
            infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader));         
        }catch(Exception e){
            DataBase.rollback( sp);            
            outHeader.RESULT  = IF_Util.RESULT_STATUS_ERROR;
            outHeader.RESULT_MESSAGE = e.getMessage();
            system.debug('Exception name =' + e);
            system.debug('Exeption detail=' + e.getCause()+e.getMessage()+e.getTypeName()+e.getLineNumber());
            infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader),e);
        }
        
        log.createLog( infLog);        
        return outHeader;
    }   

   
    global class OutputHeader{
        public String RESULT = '';
        public String RESULT_MESSAGE = '';
	}
    
    global class InputHeader{
        public String BO_CODE;
        public String Company_Code;
        public String Proposal_PM;
        public String Exec_PM;
    }

}