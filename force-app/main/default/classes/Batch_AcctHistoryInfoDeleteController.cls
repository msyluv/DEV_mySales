/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-27
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2021-01-25   raeganja@partner.samsung.com   Initial Version
**/
global class Batch_AcctHistoryInfoDeleteController implements Database.Batchable<sObject>, DataBase.Stateful, DataBase.AllowsCallouts, Schedulable{
    private final String INTERFACE_ID    = 'IF-021';
    private final String APEX_CLASS      = 'Batch_AcctHistoryInfoDeleteController';
    private final String METHOD_NAME     = 'Batch';

    private final Boolean DEBUG_FLAG = true;

    String guId = IF_Util.generateGuid();
    
    IF_Log iflog = new IF_Log();
    IF_Log.BatchLog batchLog;
    List<String> errorMsgList = new List<String>();

    public Batch_AcctHistoryInfoDeleteController() {

    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');
        
        String queryString = '';

        try{
            
            queryString = 'SELECT Account__r.AccountNumber, BizRegNo__c, InformationSource__c From AccountHistory__c where createddate=today';
            
        }catch( Exception e){
            batchLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Batch Start', 0, 0, e);
        }
        
        return DataBase.getQueryLocator(queryString);
    }

    public void execute(DataBase.BatchableContext BC, List<AccountHistory__c> selectList){
        try {
            Set<String> selectDeleteExtIdSet  = new Set<String>();// 기 적용한 DeleteExtId__c 조회용 Set (BizRegNo__c)
            
            for(AccountHistory__c acctHistory : selectList){
                selectDeleteExtIdSet.add(acctHistory.Account__r.AccountNumber +'_'+ acctHistory.BizRegNo__c +'_'+ acctHistory.InformationSource__c);
            }

            List<AccountHistory__c> deleteAcctHistoryList = [SELECT id, BizRegNo__c 
             FROM AccountHistory__c 
             where DeleteExtId__c in :selectDeleteExtIdSet
             and createddate < today];

            // delete 처리
            if(deleteAcctHistoryList.size() > 0)
                delete deleteAcctHistoryList;

            batchLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Batch Excute', selectList.size());
        }catch( Exception e){
            ifLog.addLog( ' Exception : ' + e.getStackTraceString());
                        
            batchLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Batch Excute', 0, 0, e);
        }
    }

    public void finish( DataBase.BatchableContext BC){   
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

        if (batchLog == null)
            batchLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Batch Finish', 0);
        
        ifLog.createLog(batchLog);
    }

    // 스케줄 호출
    public void execute( SchedulableContext SC){
        Batch_AcctHistoryInfoDeleteController controller = new Batch_AcctHistoryInfoDeleteController();
        DataBase.executeBatch( controller, 2000);
    }
}