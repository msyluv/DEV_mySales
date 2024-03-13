/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-02-25
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.0   2020-12-07   ghkil@partner.samsung.com         Initial Version
 * 1.1   2020-12-08   ghkil@partner.samsung.com         Queueable 적용
 * 1.2   2020-12-09   ghkil@partner.samsung.com         날짜 변환 형식 수정 ex) 2020-11-22 => 20201122
 * 1.3   2020-12-11   kilhwan.an@partner.samsung.com    daTA 변수 => Weekly_Report 변경
 * 1.4   2020-12-24   ghkil@partner.samsung.com         Start 쿼리에 Id 조건 추가
 * 1.5   2021-01-21   ghkil@partner.samsung.com         Queueable로 인해 DataBase.Stateful을 사용하지 못하는 Batch 처리에 대한 Log 처리 수정 (Start, Excute, End 각각 나눠 기록)
 * 1.6   2021-01-27   ghkil@partner.samsung.com         Queueable 제거하고 Business Ligic을 IF_LsWeeklyReportController를 호출하여 처리
 * 1.7   2021-02-27   kilhwan.an@partner.samsung.com    where 조건에 allrows 추가
 * 1.8   2021-02-25   ghkil@partner.samsung.com         Batch Log 생성 시 ApexMethod 추가 (JobId 제거)
**/
global class Batch_LsWeeklyReportController implements DataBase.stateful, DataBase.Batchable<SObject>, DataBase.AllowsCallouts, Schedulable {
    
    private final String INTERFACE_ID = 'IF-127';
    private final String APEX_CLASS   = 'Batch_LsWeeklyReportController';
    private final String METHOD_NAME  = 'Batch';    

    private static final Boolean DEBUG_FLAG = IF_Util.DEBUG_FLAG;

    private Date  BATCH_CONDITION = null; // 배치 처리 조건

    private static String guId = IF_Util.generateGuid();

    public Batch_LsWeeklyReportController() { }

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

            queryString = IF_LsWeeklyReportController.QUERY_STRING + ' Where   Systemmodstamp   >= :BATCH_CONDITION ALL ROWS ';

            returnScope = DataBase.getQueryLocator(queryString);

            ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');
                          
            batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
            
            ifStartLog.createLog(batchStartLog);
        }catch( Exception e){

            batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0, 0, e);
            startErrorMsgList.add('Batch exception : ' + e.getMessage());

            ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');

            ifStartLog.createLog(batchStartLog);
        }
        return returnScope;
    }

    public void execute(DataBase.BatchableContext BC, List<WeeklyReport__c> scopeList){
        
        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        List<String> excuteErrorMsgList = new List<String>();

        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 시작' + ' ####################');

        IF_LsWeeklyReportController.ReceiveHeader recHeader;

        String reqMsg = '';
        String resMsg = '';

        ifExcuteLog.addLog('처리 대상 : ' + scopeList.size());

        try {
            
            if (DEBUG_FLAG) ifExcuteLog.addLog('scopeList.size() : ' + scopeList.size());
            system.debug('처리 대상 : ' + scopeList.size());

            // *************************************
            // 상세정보 정보 가져오기
            // *************************************
            IF_LsWeeklyReportController.OutputHeader outHeader = IF_LsWeeklyReportController.getDetailInfo(scopeList);

            // 관련정보 Callout 처리
            // Callout 처리
            IF_Callout ifCallout = new IF_Callout(INTERFACE_ID);
            Map<String, Object> result = ifCallout.httpCallout(JSON.serialize(outHeader), '');
            if (DEBUG_FLAG) ifExcuteLog.addLog('CallOut Result : ' + result);
            if (DEBUG_FLAG) system.debug('CallOut Result: ' + result);

            reqMsg = String.valueOf(result.get('Request'));
            resMsg = String.valueOf(result.get('Response'));

            ifExcuteLog.addLog('StatusCode : '  + String.valueOf(result.get('StatusCode')));
            ifExcuteLog.addLog('HttpResponse : '+ String.valueOf(result.get('HttpResponse')));
            // if (DEBUG_FLAG) ifExcuteLog.addLog('Log : '         + String.valueOf(result.get('Log')));
            // if (DEBUG_FLAG) ifExcuteLog.addLog('Message : '     + String.valueOf(result.get('Message')));

            Integer resStatusCode = (Integer)result.get('StatusCode');

            if (resStatusCode != null && resStatusCode == 200) {
                HttpResponse hRes = (HttpResponse)result.get('HttpResponse');
                if(DEBUG_FLAG) ifExcuteLog.addLog('Response Body : ' + hRes.getBody());

                recHeader = (IF_LsWeeklyReportController.ReceiveHeader) JSON.deserialize(hRes.getBody(), IF_LsWeeklyReportController.ReceiveHeader.class); 

                batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', reqMsg, outHeader.Weekly_Report.size());
            } else if (resStatusCode != null && resStatusCode == 202) {     // Batch Asyncronous로 202도 정상 처리함
                HttpResponse hRes = (HttpResponse)result.get('HttpResponse');
                if(DEBUG_FLAG) ifExcuteLog.addLog('Response Body : ' + hRes.getBody());

                // recHeader = (ReceiveHeader) JSON.deserialize(hRes.getBody(), ReceiveHeader.class);   Batch Asyncronous로 리턴 데이터를 deserialize 할 필요 없음

                batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', reqMsg, outHeader.Weekly_Report.size());
            } else {
                ifExcuteLog.addLog('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));
                excuteErrorMsgList.add('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));

                batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', reqMsg, 0, 0, excuteErrorMsgList);
            }

            ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');

            ifExcutelog.createLog(batchExcuteLog);
        } catch (Exception e) {
            ifExcuteLog.addLog( 'Exception : ' + e.getStackTraceString());
            excuteErrorMsgList.add('Exception : ' + e.getMessage());

            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', '', 0, 0, e);

            ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');            

            ifExcutelog.createLog(batchExcuteLog);
        }
    }

    public void finish(DataBase.BatchableContext BC){
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        List<String> finishErrorMsgList = new List<String>();

        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Finish:' + BC.getJobId() + ') 시작' + ' ####################');

        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);

        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Finish:' + BC.getJobId() + ') 종료' + ' ####################');

        ifFinishLog.createLog(batchFinishLog);
    }

    // 스케줄 호출
    public void execute(SchedulableContext SC){

        DataBase.executeBatch(new Batch_LsWeeklyReportController(), 2000);
    }    
}