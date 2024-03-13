/**
 * @author            : younghoon.kim@dkbmc.com
 * @description       : [IF-152] mySales의 사업리드 정보 전송 (mySales -> Legacy 공통)
 * 		              : [schedule execution code] System.Schedule('Batch_SalesLeadDashBoardController', '0 0 6,13 * * ? *', new Batch_SalesLeadDashBoardController()); -> \제외해야함.
 * @last modified on  : 2022-01-06
 * @last modified by  : akash.g@samsung.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2022-02-21   younghoon.kim@dkbmc.com  Initial Version
 * 1.1   2022-03-03   younghoon.kim@dkbmc.com  삭제여부 필드 추가
 * 1.2   2022-01-06   akash.g@samsung.com      Change in CONTRACT_DATE field value with close date .
**/
public class Batch_SalesLeadDashBoardController implements Database.Stateful, Database.Batchable<sObject>, Database.AllowsCallouts, schedulable{
	private static final String INTERFACE_ID = 'IF-152';
    private static final String APEX_CLASS   = 'Batch_SalesLeadDashBoardController';
    private static final String METHOD_NAME  = 'sendSalesLead';

    List<IF_Log.InterfaceLog> ifLogList = new List<IF_Log.InterfaceLog>();

    private static Integer errorCount = 0;

    public Batch_SalesLeadDashBoardController(){
        System.debug('========== IF-152 ==========');
        System.debug('========== Batch_SalesLeadDashBoardController ==========');
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('========== start ==========');
        string QUERY_STRING = 'SELECT Id ' +
                              '     , Name ' +
                              '     , CurrencyIsoCode ' +
                        	  '		, IsDeleted  ' +
                              '		, LastModifiedDate ' +
                              '     , Amount__c ' +
                              '     , LeadStage__c ' +
                              '     , CloseDate__c ' +
                              '     , AccountId__c ' +
                              '     , AccountId__r.Name ' +
                              '     , AccountId__r.AccountNumber ' +
                              '     , Description__c ' +
            				  '		, OpportunityName__c ' +
                              '		, OpportunityName__r.OpportunityCode__c ' +            
                              '  FROM Sales_Lead__c  ' +
                              ' WHERE LastModifiedDate >= LAST_N_DAYS:2 ' + // 최종 수정일 기준 2일 이내 사업리드만 전송 대상
                              ' ORDER BY LastModifiedDate DESC ' + 
                              '   ALL ROWS ';

        System.debug('QUERY_STRING : ' + QUERY_STRING);

        return Database.getQueryLocator(QUERY_STRING);
    }

    public void execute(Database.BatchableContext bc, List<Sales_Lead__c> objList) {
        System.debug('========== execute ==========');
        System.debug('Query Result Size : ' + objList.size());

        Map<String,Object> resMap = new Map<String,Object>();
        List<SALESLEAD_INFO> slInfoList = new List<SALESLEAD_INFO>();
        try{
            for(Sales_Lead__c sl : objList){
                SALESLEAD_INFO slInfo = new SALESLEAD_INFO();
                slInfo.LEAD_ID = sl.Id;
                slInfo.LEAD_NAME = sl.Name;
                slInfo.LEAD_STAGE = sl.LeadStage__c;
                slInfo.CURRENCY_CODE = sl.CurrencyIsoCode;
                slInfo.IS_DELETED = sl.IsDeleted == true ? 'D' : '';
                // slInfo.CONTRACT_AMT = sl.Amount__c == null ? '' : String.valueOf(sl.Amount__c);
                slInfo.CONTRACT_AMT = sl.Amount__c == null ? '' : sl.Amount__c.setScale(2, System.RoundingMode.HALF_UP).toPlainString();
                //V1.2 : Change in CONTRACT_DATE field value with close date
                slInfo.CONTRACT_DATE = sl.CloseDate__c == null ? '' : (((String.valueOf(sl.CloseDate__c)).replaceAll( '-', '')).left(8));
                slInfo.ACCOUNT_NO = sl.AccountId__r.AccountNumber == null ? '' : sl.AccountId__r.AccountNumber;
                slInfo.ACCOUNT_NAME = sl.AccountId__r.Name == null ? '' : sl.AccountId__r.Name;
                slInfo.BO_CODE = sl.OpportunityName__r.OpportunityCode__c == null ? '' : sl.OpportunityName__r.OpportunityCode__c;
                slInfo.DESCRIPTION = sl.Description__c == null ? '' : sl.Description__c;

                slInfoList.add(slInfo);
            }
    
            if(!slInfoList.isEmpty()) resMap = sendSalesLead(slInfoList);
            IF_Log.InterfaceLog ifLog = (IF_Log.InterfaceLog)resMap.get('IF_Log');
            ifLogList.add(ifLog);
        }catch(Exception e){
            System.debug('Error : ' + e.getMessage());
            System.debug('Error StackTrace : ' + e.getStackTraceString());
            System.debug('Error Line : ' + e.getLineNumber());
        }
    }

    public void finish(Database.BatchableContext bc) { 
        System.debug('========== finish ==========');
        try{
            IF_Log log = new IF_Log();
            for(IF_Log.InterfaceLog ifLog : ifLogList){
                log.createLog(ifLog);
            }
        }catch(Exception e){
            System.debug('Error : ' + e.getMessage());
            System.debug('Error StackTrace : ' + e.getStackTraceString());
            System.debug('Error Line : ' + e.getLineNumber());
        }
        
        // 2시간 이후 다시 실행되도록 배치 재등록
        /*
        if(System.isScheduled()){
            List<CronTrigger> schJobList = [SELECT Id,  CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'Batch_SalesLeadDashBoardController'];
            for(CronTrigger obj : schJobList){
                System.abortJob(obj.id);
            }
    
            Integer nextHour = Datetime.now().hour()+2;
            if(nextHour >= 24) nextHour -=24;
            String hour = String.valueOf(nextHour);
            System.schedule('Batch_SalesLeadDashBoardController', '0 0'+hour+' * * ? *' , new Batch_SalesLeadDashBoardController());
        }
        */
    }

    public void execute(SchedulableContext SC){
        DataBase.executeBatch(new Batch_SalesLeadDashBoardController(), 200);
    }

    @AuraEnabled    
    public static Map<String,Object> sendSalesLead(List<SALESLEAD_INFO> slInfoList){
        System.debug('========== sendSalesLead ==========');
        IF_Callout call = new IF_Callout(INTERFACE_ID);
        String guId = IF_Util.generateGuid();

        Map<String,Object> resMap = new Map<String,Object>();
        Map<String,Object> returnMap = new Map<String,Object>{
            'result' => null,
            'IF_Log' => null,
            'StatusCode' => null
        };

        try{
            InputClass input = new InputClass();
            input.SALESLEAD_INFO = slInfoList;
            String jsonBody = JSON.serialize(input);
            resMap = call.httpCallout(jsonBody, '');
            System.debug('request : ' + resMap.get('Request'));
            System.debug('response : ' + resMap.get('Response'));

            HttpResponse res = (HttpResponse)resMap.get('HttpResponse');
            if(res.getStatusCode() == 200){
                Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                System.debug('RESULT : ' + bodyMap.get('RESULT'));
                if(bodyMap.get('RESULT') != null && bodyMap.get('RESULT') == 'F'){
                    if(errorCount < 2){
                        errorCount += 1;
                        sendSalesLead(slInfoList);
                    }
                }
                //IF 결과
                returnMap.put('StatusCode',res.getStatusCode());
                returnMap.put('Response', res.getBody());
            }
            returnMap.put('IF_Log', new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response'))));
        }catch(Exception e){
            returnMap.put('IF_Log', new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('HttpResponse')), e));
            System.debug('Error : ' + e.getMessage());
            System.debug('Error StackTrace : ' + e.getStackTraceString());
            System.debug('Error Line : ' + e.getLineNumber());
        }
        return returnMap;
    }

    public class InputClass{
        @AuraEnabled
        public List<SALESLEAD_INFO> SALESLEAD_INFO;
    }
    
    public class SALESLEAD_INFO{
        @AuraEnabled
        public String LEAD_ID; // 사업리드 ID
        @AuraEnabled
        public String LEAD_NAME; // 사업리드 명
        @AuraEnabled
        public String LEAD_STAGE; // 리드상태
        @AuraEnabled
        public String CURRENCY_CODE; // 통화코드
        @AuraEnabled
        public String CONTRACT_AMT; // 예상금액
        @AuraEnabled
        public String CONTRACT_DATE; // 수주예상일
        @AuraEnabled
        public String ACCOUNT_NO; // 고객사 Account No.
        @AuraEnabled
        public String ACCOUNT_NAME; // 고객사 명
        @AuraEnabled
        public String BO_CODE; // Converted BO 코드
        @AuraEnabled
        public String IS_DELETED; // 삭제여부
        @AuraEnabled
        public String DESCRIPTION; // 개요
    }
}