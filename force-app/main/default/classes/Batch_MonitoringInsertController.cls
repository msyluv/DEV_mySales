/**
 * @description       : 
 * @author            : yeongju.baek@dkbmc.com
 * @group             : 
 * @last modified on  : 19-01-2023
 * @last modified by  : akash.g@samsung.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   10-26-2021   yeongju.baek@dkbmc.com   Initial Version
 * 1.1   19-01-2023   akash.g@samsung.com      Add Batch Name to [InterfaceId] of IF_Log(MySales-105)
**/
public class Batch_MonitoringInsertController  implements DataBase.stateful, DataBase.Batchable<SObject>, DataBase.AllowsCallouts, Schedulable {
    private static final String INTERFACE_ID = 'BATCH-MONITORING'; //V1.1 - MYSALES:105
    private static final String APEX_CLASS   = 'Batch_MonitoringInsertController'; 
    private static final String METHOD_NAME  = 'Batch';

    private static Boolean isSandbox = Utils.getIsSandbox();
    private static String guId = IF_Util.generateGuid();

    public Batch_MonitoringInsertController(){}

    public Database.QueryLocator start(Database.BatchableContext BC){
        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + ' ####################');
        
        String queryString;
        queryString = 'SELECT Id, StartDatetime__c, EndDatetime__c, InterfaceId__c, LogType__c, ExceptionType__c, ErrorMessage__c,Name, ApexName__c, ApexMethod__c from IF_Log__c';
        queryString += ' where CreatedDate = YESTERDAY and StatusCode__c !=\'S\'';
        queryString += ' ORDER BY InterfaceId__c , CreatedDate';
        Database.QueryLocator returnScope;
        returnScope = DataBase.getQueryLocator( queryString);
        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');
        ifStartLog.createLog(batchStartLog);
        System.debug('###################################');
        System.debug(returnScope);
        System.debug('###################################');
        return returnScope;
    }
    public void execute(Database.BatchableContext BC, List<IF_Log__c> scopeList){
        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        List<IF_Monitoring__c> insertList = new List<IF_Monitoring__c>();
        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 시작' + ' ####################');
        if(scopeList.size() > 0){
            for( IF_Log__c log : scopeList ){
                IF_Monitoring__c mon = new IF_Monitoring__c();
                mon.IF_Log__c = log.Id;
                mon.StartDatetime__c = log.StartDatetime__c;
                mon.EndDatetime__c = log.EndDatetime__c;
                mon.InterfaceId__c = log.InterfaceId__c;
                mon.LogType__c = log.LogType__c;
                mon.ExceptionType__c = log.ExceptionType__c;
                mon.ErrorMessage__c = log.ErrorMessage__c;
                mon.ApexName__c = log.ApexName__c;
                mon.ApexMethod__c = log.ApexMethod__c;
                ifExcuteLog.addLog( 'InsertData : '+ String.valueOf(mon));
                insertList.add(mon);
            }
        }
        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');
        batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', '', 0);
        ifExcutelog.createLog(batchExcuteLog);
        if(insertList.size() > 0) insert insertList;
    }
    public void finish(DataBase.BatchableContext BC){
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);
        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');
        
        ifFinishLog.createLog(batchFinishLog);
    }
    public void execute( SchedulableContext SC){
        DataBase.executeBatch( new Batch_MonitoringInsertController(), 500);
    }
}