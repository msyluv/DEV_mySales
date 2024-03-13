/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-12-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   12-22-2020   soohong0.kim@partner.samsung.com   Initial Version
**/

@RestResource(urlMapping = '/IF103/*')
global class IF_SdBOStatusUpdateController {
    private static final String INTERFACE_ID = 'IF-103';
    private static final String APEX_CLASS   = 'IF_SdBOStatusUpdateController';
    private static final String METHOD_NAME  = 'updateOppty';

    
    @HttpPost
    global static OutputHeader updateOppty() {
        String guId      = IF_Util.generateGuid();
        IF_Log.InterfaceLog infLog;
        IF_Log log = new IF_Log();
        RestRequest req = RestContext.request;
        Blob    reqBody = req.requestBody;
        
        InputClass input = (InputClass)JSON.deserializeStrict(reqBody.toString(),InputClass.class);

        OutputHeader outheader = new OutputHeader();
        try{
            system.debug('input : '+input);
            List<Opportunity> oppList = new List<Opportunity>();
            List<Opportunity_Activity__c> oppActList = new List<Opportunity_Activity__c>();
            Opportunity oppty = [select id, CollaborationBOId__c, StageName from Opportunity where OpportunityCode__c =: input.IV_ZZORDER_ID and companyCode__c =: input.IV_BUKRS limit 1];
            //Stage의 Abort API Name = XPX1, Translate 처리때문에 Object에서 코드값으로 정의되어있음
            oppty.StageName = 'XPX1';
            oppList.add(oppty);
            Opportunity_Activity__c oppAct = new Opportunity_Activity__c();
            oppAct.TransactionName__c = 'XPX1';
            oppAct.WhatId__c = oppty.id;
            oppAct.Description__c = '중도전결';
            oppAct.DueDate__c = Date.today();
            oppAct.StartDate__c = Date.today();
            oppAct.EndDate__c = Date.today();
            oppAct.status__c = 'Completed';
            oppAct.ExtId__c = oppty.id+'_'+'XPX1';
            oppActList.add(oppAct);

            //협업 BO 가 있을 시 협업 BO Status Update
            if(oppty.CollaborationBOId__c != null){
                Opportunity coOppty = [select id, StageName from Opportunity where id =:oppty.CollaborationBOId__c limit 1];
                coOppty.StageName = 'XPX1';
                oppList.add(coOppty);
                
                Opportunity_Activity__c coOppAct = new Opportunity_Activity__c();
                coOppAct.TransactionName__c = 'XPX1';
                coOppAct.WhatId__c = coOppty.id;
                coOppAct.Description__c = '중도전결';
                coOppAct.DueDate__c = Date.today();
                coOppAct.StartDate__c = Date.today();
                coOppAct.EndDate__c = Date.today();
                coOppAct.status__c = 'Completed';
                coOppAct.ExtId__c = coOppty.id+'_'+'XPX1';
                oppActList.add(coOppAct);
            }
            update oppList;
            insert oppActList;
            outheader.TOTAL_COUNT = oppList.size();
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_SUCCESS;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_SUCCESS;
        }catch(Exception e){
            system.debug('Exception : '+e);
            outHeader.TOTAL_COUNT    = 0;
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_ERROR;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_ERROR + ' |' + e.getMessage();
            infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader),e);
            log.createLog( infLog);
        }

        
        infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader));
        log.createLog( infLog);
        return outHeader;
    }



    global class OutputHeader{

        @AuraEnabled
        public Integer TOTAL_COUNT = 0; // 전체 데이터 건수
        @AuraEnabled
        public String EV_RESULT = ''; // 처리 결과
        @AuraEnabled
        public String EV_MESG = ''; // 처리 메세지
    }


    public class InputClass{
        public String IV_BUKRS; // Company Code
        public String IV_ZZORDER_ID; // BO코드 / 통합코드
    }
}