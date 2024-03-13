/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-04-12
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2021-01-18   raeganja@partner.samsung.com   Initial Version
**/
global class Batch_ProfitLossDeleteController implements Database.Batchable<sObject>, DataBase.Stateful, DataBase.AllowsCallouts, Schedulable{
    private final String INTERFACE_ID    = 'IF-031';
    private final String APEX_CLASS      = 'Batch_ProfitLossDeleteController';
    private final String METHOD_NAME     = 'Batch';
    public String bizYear = '';
    public String version = '';

    private final Boolean DEBUG_FLAG = true;

    String guId = IF_Util.generateGuid();
    
    IF_Log iflog = new IF_Log();
    IF_Log.BatchLog batchLog;
    List<String> errorMsgList = new List<String>();

    public Batch_ProfitLossDeleteController() { }

    global Batch_ProfitLossDeleteController(String searchBizYear, String searchVersion){
        bizYear = searchBizYear;
        version = searchVersion;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');

        if( String.isBlank(bizYear)) {
            bizYear = Date.today().year()+''; // 현재년도
        }

        if( String.isBlank(version)) {
            version = '000'; // Version
        }

        String queryString;
        // 쿼리 검색 조건 확인 필요

        try{
            queryString = 'SELECT id, BizYear__c, Version__c ' +
            ' FROM ProfitLoss__c ' +
            ' where BizYear__c = :bizYear ' +
            ' and Version__c = :version';        
        }catch( Exception e){
            batchLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0, 0, e);
        }
        return DataBase.getQueryLocator(queryString);
    }

    public void execute(DataBase.BatchableContext BC, List<ProfitLoss__c> selectList){
        try {

            // delete 처리
            if(selectList.size() > 0)
                delete selectList;

            batchLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', '', selectList.size());
        }catch( Exception e){
            ifLog.addLog( ' Exception : ' + e.getStackTraceString());
                        
            batchLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', '', 0, 0, e);
        }
    }

    public void finish( DataBase.BatchableContext BC){   
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

        if (batchLog == null)
            batchLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);
        
        if( Util_String.nvlStr( bizYear) != '' && Util_String.nvlStr( version) != ''){
            
            IF_LegGetProfitLossController.getProfitLoss( bizYear, version);
        }

        ifLog.createLog(batchLog);        
    }

    // 스케줄 호출
    public void execute( SchedulableContext SC){
        Batch_ProfitLossDeleteController controller = new Batch_ProfitLossDeleteController();
        controller.bizYear = Date.today().year()+'';
        controller.version = '000';
        DataBase.executeBatch( controller, 2000);
    }
}