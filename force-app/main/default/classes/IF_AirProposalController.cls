/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2022-03-15
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-11-05   ghkil@partner.samsung.com   Initial Version
 * 1.1   2021-01-22   ghkil@partner.samsung.com   Opportunity_Activity__c 반영 추가
**/
@RestResource( urlMapping= '/IF041/*')
global class IF_AirProposalController {
    
    private static final String INTERFACE_ID = 'IF-041';
    private static final String APEX_CLASS   = 'IF_AirProposalController';
    private static final String METHOD_NAME  = 'regPropsalCheck';

    private static final Boolean DEBUG_FLAG = true;

    public IF_AirProposalController() { }

    @HttpPost
    global static void regPropsalCheck(){

        String guId = IF_Util.generateGuid();

        OutputHeader outHeader   = new OutputHeader();
        outHeader.DATA           = new List<OutputClass>();
        OutputClass outClass     = new OutputClass();
        outHeader.TOTAL_COUNT    = 0;
        outHeader.EV_RESULT      = 'S';
        outHeader.EV_MESG        = '';

        // outHeader.DATA.add(outClass);

        IF_Log ifLog;
        IF_Log.InterfaceLog interfaceLog;
        List<String> errorMsgList = new List<String>();        

		ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');

        // RequestBody 데이터 확인
        RestRequest req = RestContext.request;
        Blob    reqBody = req.requestBody;

        RestResponse rep = RestContext.response;
        rep.addHeader('Content-Type', 'application/json');

        if( reqBody == null || reqBody.size() == 0 ) {
            rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
            return;
        }
        if (DEBUG_FLAG) ifLog.addLog('클라이언트 데이터 수신');
        
        // 데이터 파싱
        String inputJsonData = reqBody.toString(); //.escapeJava();
        ifLog.addLog('HttpRequest : ' + inputJsonData);
        InputHeader inputHeader = (InputHeader) JSON.deserialize(inputJsonData, InputHeader.class);
        List<InputClass> inputDataList = inputHeader.DATA;
        if( inputDataList == null && inputDataList.size() != 0 ) {
            rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
            return;
        } 
        if (DEBUG_FLAG) ifLog.addLog('데이터 파싱');

        // 1) 해당정보 반영
        Savepoint sp = Database.setSavepoint();
        String ACT_CODE_SUBMIT_PROPOSAL = 'ZP61';  //  제안서 등록 Code 'ZP61'

        try {
            Map<String, String> inputDataMap = new Map<String, String>();
            for (InputClass inputData : inputDataList) {
                inputDataMap.put(inputData.BO_CODE, inputData.PROPOSAL_YN);
            }
    
            List<Opportunity> opportunityTagetList = [ 
                Select  Id
                        , Name
                        , ActivityStatus__c
                        , OpportunityCode__c
                        , ProposalRegistrationDate__c 
                From    Opportunity 
                Where   OpportunityCode__c IN :inputDataMap.keySet()
            ];
            Set<String> selectOpportunityIdSet = new Set<String>();
            for (Opportunity opportunityData : opportunityTagetList) {
                selectOpportunityIdSet.add(opportunityData.Id);
            }

            // Opportunity_Activity__c 조회
            List<Opportunity_Activity__c> opportunityActivityList = [
                Select  Id
                        , WhatId__c
                        , TransactionName__c
                        , StartDate__c
                        , EndDate__c
                        , DueDate__c
                        , Status__c
                        , ExtId__c
                From    Opportunity_Activity__c
                Where   WhatId__c IN :selectOpportunityIdSet
                And     TransactionName__c = :ACT_CODE_SUBMIT_PROPOSAL
            ];
            Map<String, Opportunity_Activity__c> opportunityActivityMap = new Map<String, Opportunity_Activity__c>();
            for (Opportunity_Activity__c opportunityActivityData : opportunityActivityList) {
                opportunityActivityMap.put(opportunityActivityData.ExtId__c, opportunityActivityData);
            }

            // Opportunity, Opportunity_Activity__c 반영
            List<Opportunity> regOpportunityList = new List<Opportunity>();
            List<Opportunity_Activity__c> regOpportunityActivityList = new List<Opportunity_Activity__c>();
            
            // [Start] 2022-03-14 Opportunity Activity에 ExtId__c가 중복으로 입력되지 않도록 로직 추가
            Map<String, Opportunity_Activity__c> regOpptyActMap = new Map<String, Opportunity_Activity__c>();
            // [End] 2022-03-14 Opportunity Activity에 ExtId__c가 중복으로 입력되지 않도록 로직 추가

            for (Opportunity opportunityData : opportunityTagetList) {
                
                // Opportunity 처리
                date proposalDate = null;
                if (inputDataMap.get(opportunityData.OpportunityCode__c) != null) {
                    if (inputDataMap.get(opportunityData.OpportunityCode__c).toUpperCase() == 'Y') {
                        proposalDate = Date.today();
                    }
                }

                opportunityData.ProposalRegistrationDate__c = proposalDate;
                regOpportunityList.add(opportunityData);

                // Opportunity_Activity__c 처리
                // [처리 기준]
                // 1. 'Y'인 경우 Insert - StartDate, EndDate은 today, Status는 'Completed'
                // 2. 'N'인 경우 Insert - Status는 'In Progress'
                // 3. 'Y'인 경우 Update - EndDate은 today, Status는 'Completed'
                // 4. 'N'인 경우 Update - EndDate은 null, Status는 'In Progress'                
                Opportunity_Activity__c regOpportunityActivity = new Opportunity_Activity__c();
                String getMapId = opportunityData.Id + '_' + ACT_CODE_SUBMIT_PROPOSAL;

                if (opportunityActivityMap.get(getMapId) != null) {                 // 기 등록된 Opportunity_Activity__c 처리 (Update)

                    regOpportunityActivity = opportunityActivityMap.get(getMapId);

                    if (proposalDate != null) {     // Y인 경우
                        regOpportunityActivity.Status__c            = 'Completed';
                    } else {                        // N인 경우
                        regOpportunityActivity.Status__c            = 'In Progress';
                    }
                    regOpportunityActivity.EndDate__c           = proposalDate;                    

                    regOpportunityActivityList.add(regOpportunityActivity);
                } else {                                                            // 신규 Opportunity_Activity__c 처리 (Insert)

                    regOpportunityActivity.WhatId__c            = opportunityData.Id;
                    regOpportunityActivity.TransactionName__c   = ACT_CODE_SUBMIT_PROPOSAL;

                    if (proposalDate != null) {     // Y인 경우
                        regOpportunityActivity.StartDate__c         = proposalDate;
                        regOpportunityActivity.Status__c            = 'Completed';
                        
                    } else {                        // N인 경우
                        regOpportunityActivity.StartDate__c         = null;                        
                        regOpportunityActivity.Status__c            = 'In Progress';
                    }
                    regOpportunityActivity.EndDate__c           = proposalDate;
                    regOpportunityActivity.ExtId__c             = opportunityData.Id + '_' + ACT_CODE_SUBMIT_PROPOSAL;
                    regOpportunityActivity.DueDate__c           = null;                    

                    // regOpportunityActivityList.add(regOpportunityActivity);

                    // [Start] 2022-03-14 Opportunity Activity에 ExtId__c가 중복으로 입력되지 않도록 로직 추가
                    regOpptyActMap.put(regOpportunityActivity.ExtId__c, regOpportunityActivity);
                    // [End] 2022-03-14 Opportunity Activity에 ExtId__c가 중복으로 입력되지 않도록 로직 추가
                }                
            }
    
            update regOpportunityList;

            // [Start] 2022-03-14 Opportunity Activity에 ExtId__c가 중복으로 입력되지 않도록 로직 추가
            if(!regOpptyActMap.isEmpty()) regOpportunityActivityList.addAll(regOpptyActMap.values());
            // [End] 2022-03-14 Opportunity Activity에 ExtId__c가 중복으로 입력되지 않도록 로직 추가

            upsert regOpportunityActivityList ExtId__c;


            // 2) 성공 로그 데이터
            outHeader.TOTAL_COUNT    = regOpportunityList.size();
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_SUCCESS;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_SUCCESS;
            String sendData          = JSON.serialize(outHeader);

            ifLog.addLog('Response : ' + sendData);

            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData);  
            if (DEBUG_FLAG) ifLog.addLog('데이터 반영');

        } catch(exception e) {
            Database.rollback(sp);

            // 2) 에러 로그 데이터
            outHeader.TOTAL_COUNT    = 0;
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_ERROR;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_ERROR + ' |' + e.getMessage();
            String sendData          = JSON.serialize(outHeader);

            ifLog.addLog('Response : ' + sendData);            
            ifLog.addLog('Exception : ' + e.getMessage());
            errorMsgList.add('Exception : ' + e.getMessage());
            
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData, e);                         
        } finally {
            ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

            ifLog.createLog(interfaceLog);       
        }
        rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
    }

    // 받은 값 : 입력정보
    public class InputHeader{

        @AuraEnabled
        public List<InputClass> DATA;
    }

    public class InputClass{

        @AuraEnabled
        public String BO_CODE;          // 사업코드
        @AuraEnabled
        public String PROPOSAL_YN;      // 제안사 등록 여부
    }

    // 전달 값: JitterBit
    public class OutputHeader{

        @AuraEnabled
        public Integer TOTAL_COUNT;     // 전체 데이터 건수
        @AuraEnabled
        public String EV_RESULT;        // 처리 결과
        @AuraEnabled
        public String EV_MESG;          // 처리 메세지
        @AuraEnabled
        public List<OutputClass> DATA;  // 데이터 포멧
    }

    public class OutputClass{

        @AuraEnabled
        public String BO_CODE;          // 사업코드
        @AuraEnabled
        public String PROPOSAL_YN;      // 제안사 등록 여부
    }    
}