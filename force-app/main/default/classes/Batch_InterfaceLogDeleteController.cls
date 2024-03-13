/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 19-01-2023
 * @last modified by  : akash.g@samsung.com
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.0   2021-02-18   ghkil@partner.samsung.com         Initial Version
 * 1.8   2021-02-25   ghkil@partner.samsung.com         Batch Log 생성 시 ApexMethod 추가 (JobId 제거)
 * 1.9   2021-06-18   seonju.jin@dkbmc.com              BATCH_CONDITION 30일전 데이터 삭제처리되도록 수정
 * 1.3   19-01-2023   akash.g@samsung.com      Add Batch Name to [InterfaceId] of IF_Log(MySales-105)
**/
global class Batch_InterfaceLogDeleteController implements DataBase.stateful, DataBase.Batchable<SObject>, DataBase.AllowsCallouts, Schedulable {
    
    private final String INTERFACE_ID = 'BATCH-LOGDEL'; // V1.3 - MYSALES : 105
    private final String APEX_CLASS   = 'Batch_InterfaceLogDeleteController';
    private final String METHOD_NAME  = 'Batch';

    public Date  BATCH_CONDITION = null; // 배치 처리 조건 

    private static final Boolean DEBUG_FLAG = false;    

    public Batch_InterfaceLogDeleteController() {   }

    public DataBase.QueryLocator start(DataBase.BatchableContext BC){

        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        List<String> startErrorMsgList = new List<String>();

        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + ' ####################');

        if (BATCH_CONDITION == null) {
            //BATCH_CONDITION = Date.today().addDays(-30); // 현재일의 기준 60일전 데이터 삭제 처리 -> 2021.06.18 30일로 수정
            BATCH_CONDITION = Date.today().addYears(-1);	// 현재일의 기준 1년전 데이터 삭제 처리. 
        }
            

        String queryString;
        Database.QueryLocator returnScope;

        // 쿼리 검색 조건 확인 필요
        try{

            queryString =   'Select Id ' + 
                            'From   IF_Log__c ' +
                            'Where  systemModStamp <= :BATCH_CONDITION ';

            returnScope = DataBase.getQueryLocator(queryString);

            ifStartLog.addLog('BATCH_CONDITION : ' + BATCH_CONDITION);
            system.debug('BATCH_CONDITION : ' + BATCH_CONDITION);
            // ifStartLog.addLog('queryString : ' + queryString);
            ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');

            batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, '', APEX_CLASS, 'Start', '', 0);          

            // system.debug([Select Id, systemModStamp From IF_Log__c]);
                        
            // Get an iterator
            // Database.QueryLocatorIterator it =  returnScope.iterator();
            
            // // Iterate over the records
            // while (it.hasNext())
            // {
            //     IF_Log__c logValue = (IF_Log__c)it.next();
            //     System.debug(logValue);
            //     ifStartLog.addLog(logValue);
            // }

            ifStartLog.createLog(batchStartLog);

        } catch(Exception e){

            batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, '', APEX_CLASS, 'Start', '', 0, 0, e);
            startErrorMsgList.add('Batch exception : ' + e.getMessage());

            ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');

            ifStartLog.createLog(batchStartLog);
        }

        return returnScope;
    }

    public void execute(DataBase.BatchableContext BC, List<IF_Log__c> scopeList){
        
        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        List<String> excuteErrorMsgList = new List<String>();

        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 시작' + ' ####################');

        IF_LsDashboardController.ReceiveHeader recHeader;

        // String reqMsg = '';
        // String resMsg = '';

        Map<String, Object> result = new Map<String,Object>();

        ifExcuteLog.addLog('처리 대상 : ' + scopeList.size());
        system.debug('처리 대상 : ' + scopeList.size());
    
        SavePoint sp = DataBase.setSavePoint();

        try {

            // IF_Log__c 삭제
            Delete scopeList;

            // 로그 남기기
            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, '', APEX_CLASS, 'Excute', '', scopeList.size());            
            ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');

            ifExcutelog.createLog(batchExcuteLog);
        } catch (Exception e) {
            DataBase.rollback(sp);

            ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
            excuteErrorMsgList.add('Exception : ' + e.getMessage());

            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, '', APEX_CLASS, 'Excute', '', 0, 0, e);

            ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');            

            ifExcutelog.createLog(batchExcuteLog);
        }
    }

    public void finish(DataBase.BatchableContext BC){
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        List<String> finishErrorMsgList = new List<String>();

        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Finish:' + BC.getJobId() + ') 시작' + ' ####################');

        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, '', APEX_CLASS, 'Finish', '', 0);

        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Finish:' + BC.getJobId() + ') 종료' + ' ####################');

        ifFinishLog.createLog(batchFinishLog);
    }

    // 스케줄 호출
    public void execute(SchedulableContext SC){

        DataBase.executeBatch(new Batch_InterfaceLogDeleteController(), 2000);
    }    
}