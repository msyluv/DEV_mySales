/**
 * @description       : 신용평가 데이터 SFDC로 전송
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2022-03-15
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   12-09-2020   soohong0.kim@partner.samsung.com   Initial Version
 * 1.0.1 12-14-2020   raegganja@partner.samsung.com      class name change
 * 1.0.2 12-21-2020   kilhwan.an@partner.samsung.com     Opportunity Id 처리
 * 1.0.3 03-15-2021   raeganja@partner.samsung.com       Opportunity Activity 처리
**/
@RestResource(urlMapping = '/IF120/*')
global class IF_CelloCreditRatingSendController {
    private static final String INTERFACE_ID = 'IF-120';
    private static final String APEX_CLASS   = 'IF_CelloCreditRatingSendController';
    private static final String METHOD_NAME  = 'saveData';

    @HttpPost
    global static OutputHeader saveData() {
        String       guId      = IF_Util.generateGuid();
        IF_Log.InterfaceLog infLog;
        IF_Log       log       = new IF_Log();
        RestRequest  req       = RestContext.request;
        Blob         reqBody   = req.requestBody;
        OutputHeader outHeader = new OutputHeader();
        SavePoint    sp        = DataBase.setSavePoint();
        try{
            InputHeader inHeader = (InputHeader)JSON.deserializeStrict(reqBody.toString(),InputHeader.class);
            // List<Opportunity> opptyList = [select id from Opportunity where OpportunityCode__c =: input.Opportunity];


            // 데이터가 존재 하지 않는 경우
            if( inHeader.DATA == null){

                outHeader.EV_RESULT = IF_Util.RESULT_MESSAGE_ERROR;
                outHeader.EV_MESG   = 'No Data';
                infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader));
                log.createLog( infLog);
                return outHeader;
            }

            // Opportunity 확인
            Set<Id> oppIdSet = new Set<Id>();
            for( InputClass input : inHeader.DATA) {

                oppIdSet.add( input.Opportunity);
            }

            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([

                SELECT Id FROM Opportunity
                WHERE  Id IN :oppIdSet
            ]);            

            // 정상 데이터 라면
            List<CreditAssessment__c> saveCaList = new List<CreditAssessment__c>();
            List<Opportunity_Activity__c> oppActList = new List<Opportunity_Activity__c>();
            
            // [Start] 2022-03-14 Opportunity Activity에 ExtId__c가 중복으로 입력되지 않도록 로직 추가
            Map<String, Opportunity_Activity__c> oppActMap = new Map<String, Opportunity_Activity__c>();
            // [End] 2022-03-14 Opportunity Activity에 ExtId__c가 중복으로 입력되지 않도록 로직 추가

            Set<String> extKeys = new Set<String>();
            String transactionName = '';
            for( InputClass input : inHeader.DATA) {

                // Opportunity 값이 존재 하지 않는 경우 skip
                Opportunity oppObj = oppMap.get( input.Opportunity);
                if( oppObj == null) continue;

                if(input.USEYN == 'Y'){ // 등록

                    CreditAssessment__c ca = new CreditAssessment__c();
                    ca.Name             = input.Name;
                    ca.Opportunity__c   = input.Opportunity;
                    ca.CompanyName__c   = input.CompanyName;
                    ca.Status__c        = input.Status;
                    ca.Grade__c         = input.Grade;
                    ca.ValidtoDate__c   = Util_String.convertStringDate(input.ValidetoDate);
                    ca.ShipperID__c     = input.ShipperID;
                    ca.IsBlocked__c     = input.IsBlocked == 'Y' ? true : false;
                    ca.ExternalKey__c   = input.Opportunity + '_' + input.Name;
                    
                    saveCaList.add(ca);

                    // Opportunity Activity 정보 등록
                    Opportunity_Activity__c oppAct = new Opportunity_Activity__c();
                    //Credit Assessment
                    transactionName = '2.2.1.';
                    
                    oppAct.TransactionName__c = transactionName;
                    if(input.Status == 'DC' || input.Status == 'MC' || input.Status == 'NC'){
                        oppAct.Status__c = 'Completed';
                    } else {
                        oppAct.Status__c = 'In Progress';
                    }
                    if(input.Status == 'SA'){
                        oppAct.StartDate__c = Date.today();
                    }
                    if(input.Status == 'DC' || input.Status == 'MC' || input.Status == 'NC'){
                        oppAct.EndDate__c = Date.today();
                    }
                    oppAct.CurrencyIsoCode = 'KRW';
                    oppAct.WhatId__c = input.Opportunity;
                    oppAct.ExtID__c = input.Opportunity + '_' + transactionName;

                    // oppActList.add(oppAct);
                    //upsert ca ExternalKey__c;

                    // [Start] 2022-03-14 Opportunity Activity에 ExtId__c가 중복으로 입력되지 않도록 로직 추가
                    oppActMap.put(oppAct.ExtID__c, oppAct);
                    // [End] 2022-03-14 Opportunity Activity에 ExtId__c가 중복으로 입력되지 않도록 로직 추가
                } else{ // 삭제
                    //ca = [select id from CreditAssessment__c where ExternalKey__c =: input.Name ];
                    extKeys.add( input.Opportunity + '_' + input.Name);
                    //delete ca;
                }                
            }

            if (saveCaList != null && saveCaList.size() > 0) {
                upsert saveCaList ExternalKey__c;
            }
            if (extKeys != null && extKeys.size() > 0) {
                List<CreditAssessment__c> delCaList = [ SELECT Id FROM CreditAssessment__c WHERE ExternalKey__c IN :extKeys];
                if (extKeys != null && extKeys.size() > 0) {
                    delete delCaList;
                }
            }

            // [Start] 2022-03-14 Opportunity Activity에 ExtId__c가 중복으로 입력되지 않도록 로직 추가
            if(!oppActMap.isEmpty()) oppActList.addAll(oppActMap.values());
            if (oppActList != null && oppActList.size() > 0) {
                upsert oppActList ExtID__c;
            }
            // [End] 2022-03-14 Opportunity Activity에 ExtId__c가 중복으로 입력되지 않도록 로직 추가

            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_SUCCESS;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_SUCCESS;
        }catch(Exception e){

            DataBase.rollback( sp);
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_ERROR;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_ERROR + ' |' + e.getMessage();
            infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader),e);
            log.createLog( infLog);
        }

        
        infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader));
        log.createLog( infLog);
        return outHeader;
    }



    // 전달 값: JitterBit
    global class OutputHeader{

        @AuraEnabled
        public Integer TOTAL_COUNT = 0; // 전체 데이터 건수
        @AuraEnabled
        public String EV_RESULT = ''; // 처리 결과
        @AuraEnabled
        public String EV_MESG = ''; // 처리 메세지
        @AuraEnabled
        public List<OutputClass> DATA; // 데이터 포멧
    }

    public class OutputClass{

    }

    // 받은 값 : 입력정보
    public class InputHeader{

        @AuraEnabled
        public Integer TOTAL_COUNT;
        @AuraEnabled
        public Integer PAGE_COUNT;
        @AuraEnabled
        public Integer PAGE_NUM;  
        @AuraEnabled
        public List<InputClass> DATA;
    }

    public class InputClass{

        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Opportunity;
        @AuraEnabled
        public String CompanyName;
        @AuraEnabled
        public String Status;
        @AuraEnabled
        public String Grade;
        @AuraEnabled
        public String ValidetoDate;
        @AuraEnabled
        public String ShipperID;
        @AuraEnabled
        public String USEYN;
        @AuraEnabled
        public String IsBlocked;
    }
}