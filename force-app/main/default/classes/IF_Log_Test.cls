/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-02-25
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   01-08-2021   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class IF_Log_Test {

    static final String INTERFACE_ID = 'IF-000';
    static final String APEX_CLASS   = 'IF_LogController';
    static final String METHOD_NAME  = 'saveLog';

    static String guId = IF_Util.generateGuid();

    public IF_Log_Test() {    }

    @TestSetup
    static void makeData(){
        
    }

    @isTest
    static void interfaceSuccessLogTest() {
    
        IF_Log iflog = new IF_Log();
        iflog.setCreateMode('ALL');
        IF_Log.InterfaceLog interfaceLog; 

		// ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');
        ifLog.addLog('Log : '  + 'Log Save');
        interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, 'reqMsg', 'resMsg');
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

        ifLog.createLog(interfaceLog);        
    }

    @isTest
    static void interfaceSuccessListLogTest() {
    
        IF_Log iflog;
        List<IF_Log.InterfaceLog> interfaceLogList = new List<IF_Log.InterfaceLog>();
        IF_Log.InterfaceLog interfaceLog;  

		ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');
        ifLog.addLog('Log : '  + 'Log Save');
        interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, 'reqMsg', 'resMsg');
        interfaceLogList.add(interfaceLog);
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

        ifLog.createLog(interfaceLogList);        
    }

    @isTest
    static void interfaceFailLogTest() {
    
        IF_Log iflog;
        IF_Log.InterfaceLog interfaceLog;
        List<String> errorMsgList = new List<String>();   

		ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');
        
        ifLog.addLog('Webservice call exception : ' + 'interface fail');
        errorMsgList.add('Webservice call exception : ' + 'interface fail');

        interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, 'reqMsg', 'resMsg', errorMsgList);
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

        ifLog.createLog(interfaceLog);        
    }

    @isTest
    static void batchSuccessLogTest() {
    
        IF_Log iflog;
        IF_Log.BatchLog batchLog;

		ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');
        ifLog.addLog('Log : '  + 'Log Save');
        batchLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'reqMsg', 1);
        batchLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, 'reqMsg', 1);
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

        ifLog.createLog(batchLog);        
    }

    @isTest
    static void batchFailLogTest() {
    
        IF_Log iflog;
        IF_Log.BatchLog batchLog;
        List<String> errorMsgList = new List<String>();   

        ifLog = new IF_Log('ALL');
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');
        ifLog.addLog('batch exception : ' + 'batch fail');
        errorMsgList.add('batch exception : ' + 'batch fail');
        batchLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'reqMsg', 1, 1, errorMsgList);
        batchLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, 'reqMsg', 1, 1, errorMsgList);
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

        ifLog.createLog(batchLog);        
    }       
}