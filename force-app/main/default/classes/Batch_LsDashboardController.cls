/**
 * @description       : 
 * @author            : kilhwan.an@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-08-10
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.0   2020-11-11   kilhwan.an@partner.samsung.com    Initial Version
 * 1.1   2020-11-20   ghkil@partner.samsung.com         CostCenter__c, Abtel__c 처리 관리 수정 (CostCenter__c, Deparment__c)
 * 1.2   2020-12-01   ghkil@partner.samsung.com         Opportunity의 Company__c 필드 삭제에 따른 주석 처리   
 * 1.3   2020-12-01   kilhwan.an@partner.samsung.com    필드명 수정
 * 1.4   2020-12-07   ghkil@partner.samsung.com         Opportunity의 Company__c(삭제)을 EPCompanyCode__c(추가) 필드로 대체
 * 1.5   2020-12-08   ghkil@partner.samsung.com         Queueable 적용
 * 1.6   2020-12-09   kilhwan.an@partner.samsung.com    ItemNumber__c => 문자*정수형변환
 * 1.7   2020-12-24   ghkil@partner.samsung.com         Start 쿼리에 Id 조건 추가
 * 1.8   2020-12-28   ghkil@partner.samsung.com         Department__c 조회 시 Key값(CostCenter + 99991231 + CompanyCode)에 맞게 수정
 * 1.9   2021-01-14   ghkil@partner.samsung.com         금액(Decimal Type) 표기 과학적(지수)표기 되지 않도록 처리
 * 1.91  2021-01-21   ghkil@partner.samsung.com         Queueable로 인해 DataBase.Stateful을 사용하지 못하는 Batch 처리에 대한 Log 처리 수정 (Start, Excute, End 각각 나눠 기록)
 * 1.10  2021-01-22   kilhwan@partner.samsung.com       DeletionFlag__c 조건 추가
 * 1.11  2021-01-27   ghkil@partner.samsung.com         Queueable 제거하고 Business Ligic을 IF_LsDashboardController를 호출하여 처리
 * 1.12  2021-02-25   ghkil@partner.samsung.com         Batch Log 생성 시 ApexMethod 추가 (JobId 제거)
 **/

global class Batch_LsDashboardController implements DataBase.stateful, DataBase.Batchable<SObject>, DataBase.AllowsCallouts, Schedulable {
    
    private final String INTERFACE_ID = 'IF-042';
    private final String APEX_CLASS   = 'Batch_LsDashboardController';
    private final String METHOD_NAME  = 'Batch';

    public Date  BATCH_CONDITION = null; // 배치 처리 조건
    private Set<Id>  opptyIdSet;

    private static final Boolean DEBUG_FLAG = false;    

    private static String guId = IF_Util.generateGuid();

    public Batch_LsDashboardController() { }

    public Batch_LsDashboardController(Set<Id> opptyIdSet) { this.opptyIdSet = opptyIdSet; }

    public DataBase.QueryLocator start(DataBase.BatchableContext BC){

        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        List<String> startErrorMsgList = new List<String>();

        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + ' ####################');

        if( BATCH_CONDITION == null) 
            BATCH_CONDITION = Date.today().addDays(-3); // 현재일의 기준 3일 전 데이터 처리

        String queryString;
        Database.QueryLocator returnScope;

        // 쿼리 검색 조건 확인 필요
        try{

            // queryString = IF_LsDashboardController.QUERY_STRING + 'And  systemModStamp >= :BATCH_CONDITION ';
            if(opptyIdSet == null) opptyIdSet = new Set<Id>();
            // queryString = IF_LsDashboardController.QUERY_STRING + ' And    Opportunity__c IN :OpptyIdSet ';
            // queryString += ' ORDER BY Opportunity__c';

            queryString = ' SELECT Id, Name FROM Opportunity WHERE Id IN : opptyIdSet';
            returnScope = DataBase.getQueryLocator(queryString);
            
            ifStartLog.addLog('targetOppty Id:' + opptyIdSet);
            ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');
                          
            batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
            
            ifStartLog.createLog(batchStartLog);

        } catch(Exception e){

            batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0, 0, e);
            startErrorMsgList.add('Batch exception : ' + e.getMessage());

            ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');

            ifStartLog.createLog(batchStartLog);
        }
        return returnScope;
    }

    public void execute(DataBase.BatchableContext BC, List<Opportunity> scopeList){
        
        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        List<String> excuteErrorMsgList = new List<String>();

        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 시작' + ' ####################');

        IF_LsDashboardController.ReceiveHeader recHeader;

        String reqMsg = '';
        String resMsg = '';

        Map<String, Object> result = new Map<String,Object>();

        // ifExcuteLog.addLog('처리 대상(Service 기준) : ' + scopeList.size());
        // system.debug('처리 대상(Service 기준) : ' + scopeList.size());

        Set<Id> opptyIdSet = new Set<Id>();
        for(Opportunity oppty : scopeList){
            opptyIdSet.add(oppty.Id);
        }
        String queryString = IF_LsDashboardController.QUERY_STRING + 'And    Opportunity__c IN :opptyIdSet ';
        queryString += ' ORDER BY Opportunity__c';

        List<Service__c> targetList = Database.query(queryString);

        IF_LsDashboardController.OutputHeader outHeader = IF_LsDashboardController.getDashboardDetailInfo(targetList);

        if (DEBUG_FLAG) ifExcuteLog.addLog('Service 처리 건수 : ' + outHeader.BO_SERVICE.size());
        if (DEBUG_FLAG) ifExcuteLog.addLog('Solution 처리 건수 : ' + outHeader.BO_SOLUTION.size());

        try {

            // 관련정보 Callout 처리
            // Callout 처리
            IF_Callout ifCallout = new IF_Callout(INTERFACE_ID);
            result = ifCallout.httpCallout(JSON.serialize(outHeader), '');
            system.debug('CallOut Result' + ' / ' + result);

            reqMsg = String.valueOf(result.get('Request'));
            resMsg = String.valueOf(result.get('Response'));
            
            // Batch는 Request 정보가 길어 주석 처리
            // if (DEBUG_FLAG) ifExcuteLog.addLog('Request : '  + reqMsg);     

            ifExcuteLog.addLog('StatusCode : '  + String.valueOf(result.get('StatusCode')));
            ifExcuteLog.addLog('HttpResponse : '+ String.valueOf(result.get('HttpResponse')));
            // if (DEBUG_FLAG) ifLog.addLog('Log : '         + String.valueOf(result.get('Log')));
            // if (DEBUG_FLAG) ifLog.addLog('Message : '     + String.valueOf(result.get('Message')));
           
            Integer resStatusCode = (Integer)result.get('StatusCode');

            if (resStatusCode != null && resStatusCode == 200) {
                HttpResponse hRes = (HttpResponse)result.get('HttpResponse');

                ifExcuteLog.addLog('HttpResponse getBody : ' + hRes.getBody());

                // recHeader = (ReceiveHeader) JSON.deserialize(hRes.getBody(), ReceiveHeader.class); 
                ifExcuteLog.addLog('recHeader : ' + hRes.getBody());

                batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', reqMsg, outHeader.BO_SERVICE.size());
            } else if (resStatusCode != null && resStatusCode == 202) {         // Batch Asyncronous로 리턴 데이터가 없음
                HttpResponse hRes = (HttpResponse)result.get('HttpResponse');

                ifExcuteLog.addLog('HttpResponse getBody : ' + hRes.getBody());

                // recHeader = (ReceiveHeader) JSON.deserialize(hRes.getBody(), ReceiveHeader.class); 
                ifExcuteLog.addLog('recHeader : ' + hRes.getBody());

                batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', reqMsg, outHeader.BO_SERVICE.size());
            } else {
                ifExcuteLog.addLog('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));
                excuteErrorMsgList.add('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));

                batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', reqMsg, 0, 0, excuteErrorMsgList);
            }

            // 로그 남기기
            ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');

            ifExcutelog.createLog(batchExcuteLog);
        } catch (Exception e) {
            ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
            excuteErrorMsgList.add('Exception : ' + e.getMessage());

            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', '', 0, 0, e);

            ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');            

            ifExcutelog.createLog(batchExcuteLog);
        }
    }

    public void finish(DataBase.BatchableContext BC){
        // IF_Log ifFinishLog = new IF_Log();
        // IF_Log.BatchLog batchFinishLog;
        // List<String> finishErrorMsgList = new List<String>();

        // ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Finish:' + BC.getJobId() + ') 시작' + ' ####################');

        // batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);

        // ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Finish:' + BC.getJobId() + ') 종료' + ' ####################');

        // ifFinishLog.createLog(batchFinishLog);
    }

    // 스케줄 호출
    public void execute(SchedulableContext SC){

        DataBase.executeBatch(new Batch_LsDashboardController(), 2000);
    }
}