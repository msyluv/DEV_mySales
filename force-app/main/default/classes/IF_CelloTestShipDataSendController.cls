/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2020-12-21
 * @last modified by  : raegganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   12-08-2020   soohong0.kim@partner.samsung.com   Initial Version
 * 1.0.1 12-14-2020   raegganja@partner.samsung.com      class name change
 * 1.0.2 12-21-2020   kilhwan.an@partner.samsung.com     Opportunity Id 처리
**/
@RestResource(urlMapping = '/IF123/*')
global class IF_CelloTestShipDataSendController {
    private static final String INTERFACE_ID = 'IF-123';
    private static final String APEX_CLASS   = 'IF_CelloTestShipDataSendController';
    private static final String METHOD_NAME  = 'saveData';

    public IF_CelloTestShipDataSendController() {
    }

    @HttpPost
    global static OutputHeader saveData() {
        String guId = IF_Util.generateGuid();
        IF_Log.InterfaceLog infLog;
        IF_Log log = new IF_Log();
        RestRequest req = RestContext.request;
        Blob reqBody = req.requestBody;
        OutputHeader outHeader = new OutputHeader();

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



            // Set<String> ids = new Set<String>();
            // for(InputClass obj : inputHeader.DATA){
            //     ids.add(obj.Opportunity);
            // }
            // List<Opportunity> optyList = [select id, OpportunityCode__c from Opportunity where OpportunityCode__c in: ids];
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
            
            List<TestShipment__c> upsertList = new List<TestShipment__c>();
            Set<String>           delIds     = new Set<String>();
            for(InputClass obj : inputHeader.DATA){

                Opportunity oppObj = oppMap.get( obj.Opportunity);
                if( oppObj == null) continue;

                if(obj.isDeleted != 'Y' ){

                    // system.debug('optyMap : '+optyMap);
                    TestShipment__c test     = new TestShipment__c();
                    // test.Opportunity__c     = optyMap.get(obj.Opportunity);
                    test.Opportunity__c      = obj.Opportunity;
                    test.Name                = obj.Name;
                    test.ContractStartDate__c= Util_String.convertStringDate(obj.cRevenueStartDate);
                    test.ContractEndDate__c  = Util_String.convertStringDate(obj.cRevenueEndDate);
                    test.ServiceType__c      = obj.ServiceType;
                    test.Route__c            = obj.Route;
                    test.Amount__c           = Decimal.valueOf(obj.Amount);
                    test.ExternalKey__c      = obj.Name;
                    upsertList.add(test);
                }
                else{
                    delIds.add(obj.Name);
                }
            }
            if(delIds.size()>0){
                List<TestShipment__c> testList = [select id from TestShipment__c where Name in:delIds];
                delete testList;
            }
            if(upsertList.size()>0) upsert upsertList ExternalKey__c;

            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_SUCCESS;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_SUCCESS;
        }catch(Exception e){
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
        public String Name;
        @AuraEnabled
        public String cRevenueStartDate;
        @AuraEnabled
        public String cRevenueEndDate;
        @AuraEnabled
        public String ServiceType;
        @AuraEnabled
        public String Route;
        @AuraEnabled
        public String Amount;
        @AuraEnabled
        public String isDeleted;
    }
}