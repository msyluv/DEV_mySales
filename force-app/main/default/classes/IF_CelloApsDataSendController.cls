/**
 * @description       : APS 데이터 SFDC로 전송
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2022-03-15
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   12-08-2020   soohong0.kim@partner.samsung.com   Initial Version
 * 1.0.1 12-14-2020   raegganja@partner.samsung.com      class name change
 * 1.0.2 12-21-2020   kilhwan.an@partner.samsung.com     Opportunity Id 처리
 * 1.0.3 03-15-2021   raeganja@partner.samsung.com       Opportunity Activity 처리
**/
@RestResource(urlMapping = '/IF122/*')
global class IF_CelloApsDataSendController {
    private static final String INTERFACE_ID = 'IF-122';
    private static final String APEX_CLASS   = 'IF_CelloApsDataSendController';
    private static final String METHOD_NAME  = 'saveData';

    public IF_CelloApsDataSendController() {
    }

    @HttpPost
    global static OutputHeader saveData() {
        String guId = IF_Util.generateGuid();
        IF_Log.InterfaceLog infLog;
        IF_Log log = new IF_Log();
        RestRequest req = RestContext.request;
        Blob reqBody = req.requestBody;
        OutputHeader outHeader = new OutputHeader();
        SavePoint sp = DataBase.setSavePoint();
        try{
            InputHeader inputHeader = (InputHeader)JSON.deserializeStrict(reqBody.toString(),InputHeader.class);
            
            // 데이터가 존재 하지 않는 경우
            if( inputHeader.DATA == null){

                outHeader.EV_RESULT = IF_Util.RESULT_MESSAGE_ERROR;
                outHeader.EV_MESG   = 'No Data';
                infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader));
                log.createLog( infLog);
                return outHeader;
            }
            
            // Id 검색
            // Set<String> ids         = new Set<String>();
            // for(InputClass obj : inputHeader.DATA){
            //     ids.add(obj.Opportunity);
            // }
            // // List<Opportunity> optyList = [select id, OpportunityCode__c from Opportunity where OpportunityCode__c in: ids];
            // List<Opportunity>  optyList = [ 

            //     SELECT Id
            //           ,OpportunityCode__c 
            //     FROM   Opportunity 
            //     WHERE  Id   IN :ids
            // ];
            // Map<String,String> optyMap = new Map<String,String>();
            // if(optyList.size()>0){
            //     for(Opportunity obj : optyList){
                    
            //         optyMap.put(obj.OpportunityCode__c, obj.id);
            //     }
            // }


            // Opportunity 확인
            Set<Id> oppIdSet = new Set<Id>();
            for( InputClass input : inputHeader.DATA) {

                oppIdSet.add( input.Opportunity);
            }

            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([

                SELECT Id FROM Opportunity
                WHERE  Id IN :oppIdSet
            ]);
            
            // 데이터가 존재 하는 경우
            List<APS__c> upsertList = new List<APS__c>();
            List<Opportunity_Activity__c> oppActList = new List<Opportunity_Activity__c>();

            // [Start] 2022-03-14 Opportunity Activity에 ExtId__c가 중복으로 입력되지 않도록 로직 추가
            Map<String, Opportunity_Activity__c> oppActMap = new Map<String, Opportunity_Activity__c>();
            // [End] 2022-03-14 Opportunity Activity에 ExtId__c가 중복으로 입력되지 않도록 로직 추가
            
            Set<String>  delIds     = new Set<String>();
            String transactionName = '';
            for( InputClass obj : inputHeader.DATA){

                Opportunity oppObj = oppMap.get( obj.Opportunity);
                if( oppObj == null) continue;
                if(obj.isDeleted != 'Y' ){

                    // system.debug('optyMap : '+optyMap);
                    APS__c aps          = new APS__c();
                    // aps.Opportunity__c  = optyMap.get(obj.Opportunity);
                    aps.Opportunity__c  = obj.Opportunity;
                    aps.Name            = obj.APSID;
                    aps.ExternalKey__c  = obj.APSID;
                    aps.BiddingType__c  = obj.BiddingType;
                    aps.RequestDate__c  = Util_String.convertStringDate(obj.RequestDate);
                    aps.RequestStatus__c= obj.RequestStatus;
                    aps.ShippingType__c = obj.ShippingType;
                    upsertList.add(aps);

                    // Opportunity Activity 정보 등록
                    Opportunity_Activity__c oppAct = new Opportunity_Activity__c();
                    //Request AP(APS)
                    transactionName = '2.2.2.';

                    oppAct.TransactionName__c = transactionName;
                    if(obj.RequestStatus == 'Save'){
                        oppAct.Status__c = 'Not Started';
                    } else if(obj.RequestStatus == 'Submit' || obj.RequestStatus == 'Progress' || obj.RequestStatus == 'Reject'){
                        oppAct.Status__c = 'In Progress';
                    } else if(obj.RequestStatus == 'Completed'){
                        oppAct.Status__c = 'Completed';
                    }
                    if(obj.RequestStatus == 'Save'){
                        oppAct.DueDate__c = Date.today();
                    }
                    if(obj.RequestStatus == 'Submit'){
                        oppAct.StartDate__c = Util_String.convertStringDate(obj.RequestDate);
                    }
                    if(obj.RequestStatus == 'Completed'){
                        oppAct.EndDate__c = Date.today();
                    }
                    oppAct.CurrencyIsoCode = 'KRW';
                    oppAct.WhatId__c = obj.Opportunity;
                    oppAct.ExtID__c = obj.Opportunity + '_' + transactionName;

                    // oppActList.add(oppAct);

                    // [Start] 2022-03-14 Opportunity Activity에 ExtId__c가 중복으로 입력되지 않도록 로직 추가
                    oppActMap.put(oppAct.ExtID__c, oppAct);
                    // [End] 2022-03-14 Opportunity Activity에 ExtId__c가 중복으로 입력되지 않도록 로직 추가
                }
                else{
                    delIds.add(obj.APSID);
                }
            }
            if(delIds.size()>0){
                List<APS__c> testList = [select id from APS__c where Name in:delIds];
                delete testList;
            }
            if(upsertList.size()>0) upsert upsertList ExternalKey__c;
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
        public String Opportunity;
        @AuraEnabled
        public String APSID;
        @AuraEnabled
        public String BiddingType;
        @AuraEnabled
        public String RequestDate;
        @AuraEnabled
        public String RequestStatus;
        @AuraEnabled
        public String ShippingType;
        @AuraEnabled
        public String isDeleted;
    }
}