/**
* @description       : Rest API CallIn to Interact with Cello system
* @author            : Kajal.c@samsung.com
* @group             : 
* @last modified on  : 2022-11-23
* @last modified by  : Kajal.c@samsung.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   2022-11-2   Kajal.c@samsung.com   Initial Version
* 1.1   2023-12-16  divyam.gupta@samsung.com   Mysales-382 Stage change to Drop in Reject Case
**/
@RestResource(urlMapping = '/IF170/*')
global class IF_CelloCallinAPIController {
    private static final String INTERFACE_ID = 'IF-170';
    private static final String APEX_CLASS   = 'IF_CelloCallinAPIController';
    private static final String METHOD_NAME  = 'doPost';
    private static String CPID, CPType, CPStatus,CPResult,OppCode;
    
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
            OppCode  = input.BO_CODE;
            CPID     = input.LOGI_CP_ID;
            CPType   = input.LOGI_CP_CCD;
            CPStatus = input.LOGI_CP_SCD;
            CPResult = input.LOGI_CP_RV_SCD;
            
            System.debug('CPReviewID**=' + CPID + 'CPReviewType**=' + CPType + 'CPReviewStatus**=' + CPStatus + 'CPReviewResult**=' + CPResult  + 'OpportunityCode**=' + OppCode);
            
            LIST<Opportunity> oppList = [Select id,Opportunity_Logistics_CPReviewStatus_BID__c,
                                         Opportunity_Logistics_CPReviewStatus_FIN__c,Opportunity_Logistics_CPReviewResult_BID__c,
                                         Opportunity_Logistics_CPReviewResult_FIN__c from opportunity 
                                         where OpportunityCode__c =: OppCode];
            if(oppList.size() > 0){
                List<Opportunity_Activity__c> oppActList;
                oppList[0].Opportunity_Logistics_CP_Review_ID__c = CPID;
                if(CPType == 'BID'){
                    oppActList = [Select id,StartDate__c,Status__c from Opportunity_Activity__c where WhatId__r.OpportunityCode__c =: OppCode
                                  AND TransactionName__c = '2.3.1'];
                    oppList[0].Opportunity_Logistics_CPReviewStatus_BID__c = CPStatus;
                    oppList[0].Opportunity_Logistics_CPReviewResult_BID__c = CPResult;
                }
                if(CPType == 'FIN'){
                    oppActList = [Select id,StartDate__c,Status__c from Opportunity_Activity__c where WhatId__r.OpportunityCode__c =: OppCode
                                  AND TransactionName__c = '2.4.4'];
                    oppList[0].Opportunity_Logistics_CPReviewStatus_FIN__c = CPStatus;
                    oppList[0].Opportunity_Logistics_CPReviewResult_FIN__c = CPResult;
                }
                update oppList[0];
                system.debug('oppActList size **' + oppActList.size());
                if(oppActList.size() == 1){
                    if(oppActList[0].StartDate__c == null){
                        oppActList[0].StartDate__c = System.today();
                    }
                    if(oppActList[0].Status__c == null){
                        oppActList[0].Status__c = 'In Progress';
                    }
                    if(CPType == 'BID'){
                        if(oppList[0].Opportunity_Logistics_CPReviewStatus_BID__c == 'CNFM'){
                            oppActList[0].Status__c = 'Completed';
                            oppActList[0].EndDate__c = System.today();
                        }
                        if(oppList[0].Opportunity_Logistics_CPReviewStatus_BID__c == 'SAVE' || oppList[0].Opportunity_Logistics_CPReviewStatus_BID__c == 'REQ'){
                            oppActList[0].Status__c = 'In Progress';
                        }
                    }
                    if(CPType == 'FIN'){
                        if(oppList[0].Opportunity_Logistics_CPReviewStatus_FIN__c == 'CNFM'){
                            oppActList[0].Status__c = 'Completed';
                            oppActList[0].EndDate__c = System.today();
                        }
                        if(oppList[0].Opportunity_Logistics_CPReviewStatus_FIN__c == 'SAVE' || oppList[0].Opportunity_Logistics_CPReviewStatus_FIN__c == 'REQ'){
                            oppActList[0].Status__c = 'In Progress';
                        }
                    }
                    system.debug('oppActList[0]**' + oppActList[0]);
                    update oppActList[0];
                }else if(oppActList.size() == 0){
                    Opportunity_Activity__c newOpAct = new Opportunity_Activity__c();
                    newOpAct.WhatId__c = oppList[0].Id;
                    newOpAct.StartDate__c = System.today();
                    newOpAct.Status__c = 'In Progress';
                    if(CPType == 'BID'){
                        newOpAct.TransactionName__c = '2.3.1';
                        if(oppList[0].Opportunity_Logistics_CPReviewStatus_BID__c == 'CNFM'){
                            newOpAct.Status__c = 'Completed';
                            newOpAct.EndDate__c = System.today();
                        }
                        if(oppList[0].Opportunity_Logistics_CPReviewStatus_BID__c == 'SAVE' || oppList[0].Opportunity_Logistics_CPReviewStatus_BID__c == 'REQ'){
                            newOpAct.Status__c = 'In Progress';
                        }
                    }
                    if(CPType == 'FIN'){
                        newOpAct.TransactionName__c = '2.4.4';
                        if(oppList[0].Opportunity_Logistics_CPReviewStatus_FIN__c == 'CNFM'){
                            newOpAct.Status__c = 'Completed';
                            newOpAct.EndDate__c = System.today();
                        }
                        
                        if(oppList[0].Opportunity_Logistics_CPReviewStatus_FIN__c == 'SAVE' || oppList[0].Opportunity_Logistics_CPReviewStatus_FIN__c == 'REQ'){
                            newOpAct.Status__c = 'In Progress';
                        }
                    }
                    system.debug('newOpAct**' + newOpAct);
                    insert newOpAct;
                }
                if((oppList[0].Opportunity_Logistics_CPReviewStatus_BID__c == 'CNFM' && oppList[0].Opportunity_Logistics_CPReviewResult_BID__c == 'R') ||
                   (oppList[0].Opportunity_Logistics_CPReviewStatus_FIN__c == 'CNFM' && oppList[0].Opportunity_Logistics_CPReviewResult_FIN__c == 'R')){
                     //START V 1.1
                       oppList[0].StageName = 'Z07';
                       update oppList[0]; 
                     // END V 1.1
                       RecordLockController.lockRecord(oppList[0].Id);
                   }else{
                       RecordLockController.unlockRecord(oppList[0].Id);
                   }
            }
            System.debug('opportunity data'+ oppList);
            outHeader.RESULT  = IF_Util.RESULT_STATUS_SUCCESS;
            infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader)); 
        } catch(Exception e){
            DataBase.rollback( sp);            
            outHeader.RESULT  = 'F';
            system.debug('Exception name =' + e);
            system.debug('Exeption detail=' + e.getCause()+e.getMessage()+e.getTypeName()+e.getLineNumber());
            infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader),e);
        }
        ID iFLogId = log.createLog2( infLog); 
        system.debug('iFLogId **' + iFLogId);
        System.debug(outHeader);
        return outHeader;
        
    }
    global class OutputHeader{
        public String RESULT = '';
    }
    global class InputHeader{
        public String BO_CODE;
        public String LOGI_CP_ID;
        public String LOGI_CP_CCD;
        public String LOGI_CP_SCD;
        public String LOGI_CP_RV_SCD;
    }
}