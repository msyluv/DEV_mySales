/**
* @description       : Batch Program that sends user access logs from MySales to DataLake every hour(IF-181)
* @author            : vikrant.ks@samsung.com
* @group             : 
* @last modified on  : 2023-05-11 
* @last modified by  : vikrant.ks@samsung.com 
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2023-05-11   vikrant.ks@samsung.com   Initial Version(MySales 195)
**/
public class Batch_UserLogstoDataLake implements Database.Stateful, Database.Batchable<sObject>, Database.AllowsCallouts, schedulable
{
    private static final String INTERFACE_ID = 'IF-181';
    private static final String APEX_CLASS   = 'Batch_UserLogstoDataLake';
    private static final String METHOD_NAME  = 'sendLoginHistorytoDataLake';
    private static String guId = IF_Util.generateGuid();
    private static Integer errorCount = 0;
    private static Boolean isSandbox = Utils.getIsSandbox();
    
    public Batch_UserLogstoDataLake(){
        System.debug('========== IF-181 ==========');
        System.debug('========== Batch_UserLogstoDataLake ==========');
    }
    
    private Map<String,Employee__c> EmployeeMap = new Map<String,Employee__c>();
    Map<Id,String> userMap = new Map<Id,String>();
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + ' ####################');
        ifStartLog.createLog(batchStartLog);
        
        System.debug('========== start ==========');
        Set<String> fedSet = new Set<String>();
        List<User> userList = new List<User>([Select Id,FederationIdentifier,CompanyCode__c from User]);
        
        for(User user:userList){
            if(user.FederationIdentifier != null && user.CompanyCode__c != null){
                userMap.put(user.Id,user.FederationIdentifier+'_'+user.CompanyCode__c);
                fedSet.add(user.FederationIdentifier);
            }
        } 
        system.debug('userMap@@' + userMap);
        List<Employee__c> EmployeeList = new List<Employee__c>([Select Name,EvMailAddr__c,EvEmpNO__c,EvCompany__c,EvUniqID__c,EvSapBukrs__c from 
                                                                Employee__c Where EvUniqID__c IN :fedSet]);
        if(EmployeeList.Size()>0)
        {
            for(Employee__c emp:EmployeeList)
            {
                if(emp.EvUniqID__c != null && emp.EvSapBukrs__c != null) EmployeeMap.put(emp.EvUniqID__c+'_'+emp.EvSapBukrs__c,emp);
            }
        }
        Datetime endTime = Datetime.now();
        Datetime deadline = Datetime.now().addHours(-1);
        return Database.getQueryLocator('Select UserId, LoginTime,SourceIp, Application,Status '+
                                        'from LoginHistory '+ 
                                        'where LoginTime >= :deadline and LoginTime < :endTime' + (Test.isRunningTest()?' LIMIT 200':'')
                                       );
    }
    
    public void execute(Database.BatchableContext bc, List<LoginHistory> objList)
    {
        System.debug('========== execute ==========' + objList);
        System.debug('Query Result Size : ' + objList.size());
        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        
        Map<String,Object> resMap = new Map<String,Object>();
        List<LOGIN_HISTORY> loginHistoryList = new List<LOGIN_HISTORY>();
        
        try
        {
            for(LoginHistory log : objList)
            {
                system.debug('Akash1' + userMap.get(log.UserId) );
                
                system.debug('Akash4' + EmployeeMap.get(userMap.get(log.UserId)) );
                system.debug('Akash5' + log.Status );
                
                if(userMap.get(log.UserId) != null && EmployeeMap.get(userMap.get(log.UserId)) != null 
                   && !log.Application.toLowerCase().contains('jitterbit') && log.Status == 'Success' 
                   && EmployeeMap.get(userMap.get(log.UserId)).EvMailAddr__c  != 'noreply@salesforce.com')
                { 
                    system.debug('Akash');
                    LOGIN_HISTORY loginHistory = new LOGIN_HISTORY();
                    loginHistory.SYSTEM_CODE = 'C0001001';
                    loginHistory.MENU_NAME = 'Home';
                    loginHistory.COMPANY = EmployeeMap.get(userMap.get(log.UserId)).EvCompany__c;
                    loginHistory.EMPNO = EmployeeMap.get(userMap.get(log.UserId)).EvEmpNO__c;
                    loginHistory.USER_NAME = EmployeeMap.get(userMap.get(log.UserId)).Name;
                    loginHistory.IP = log.SourceIp;
                    Datetime tempTime = log.LoginTime;//.addHours(9);     
                    String temp=tempTime.format('yyyy-MM-dd HH:mm:ss');
                    loginHistory.LOGINTIME = temp;
                    System.debug(loginHistory);
                    
                    loginHistoryList.add(loginHistory);
                }
            }
            if(!loginHistoryList.isEmpty()) resMap = sendLoginHistorytoDataLake(loginHistoryList);
            IF_Log.InterfaceLog ifLog = (IF_Log.InterfaceLog)resMap.get('IF_Log');
            ifExcutelog.createLog(ifLog);
            //System.debug(loginHistoryList);
        }catch(Exception e){
            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, e.getMessage(), 0, 0,e);
            ifExcutelog.createLog(batchExcuteLog);
            
            System.debug('Error : ' + e.getMessage());
            System.debug('Error StackTrace : ' + e.getStackTraceString());
            System.debug('Error Line : ' + e.getLineNumber());
        }
    }
    public void finish(Database.BatchableContext bc)
    {
        System.debug('========== finish ==========');
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);
        ifFinishLog.addLog('#####-----##### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + '#####-----##### ');
        ifFinishLog.createLog(batchFinishLog);
    }
    public void execute(SchedulableContext SC)
    {
        DataBase.executeBatch(new Batch_UserLogstoDataLake(), 200);
        //System.Schedule('Batch_UserLogstoDataLake','0 10 * * * ?',new Batch_UserLogstoDataLake());
    }
    
    public static Map<String,Object> sendLoginHistorytoDataLake(List<LOGIN_HISTORY> loginHistoryList)
    {
        IF_Callout call = new IF_Callout(INTERFACE_ID);
        Map<String,Object> resMap = new Map<String,Object>();
        Map<String,Object> returnMap = new Map<String,Object>{
            'result' => null,
                'IF_Log' => null,
                'StatusCode' => null
                };
                    
                    try{
                        InputClass input = new InputClass();
                        input.LOGIN_HISTORY = loginHistoryList;
                        String jsonBody = JSON.serialize(input);
                        resMap = call.httpCallout(jsonBody, '');
                        System.debug('request : '+resMap.get('Request'));
                        System.debug('response : '+resMap.get('Response'));
                        
                        HttpResponse res = (HttpResponse)resMap.get('HttpResponse');
                        if(res.getStatusCode() == 200){
                            Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                            if(bodyMap.get('RESULT') != null && bodyMap.get('RESULT') == 'F'){
                                if(errorCount < 2){
                                    errorCount += 1;
                                    sendLoginHistorytoDataLake(loginHistoryList);
                                }
                            }
                            //IF 결과
                            returnMap.put('StatusCode',res.getStatusCode());
                            returnMap.put('Response', res.getBody() );
                            
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
        public List<LOGIN_HISTORY> LOGIN_HISTORY; 
    }
    
    public class LOGIN_HISTORY{
        
        public String SYSTEM_CODE; 
        
        public String MENU_NAME; 
        
        public String COMPANY;
        
        public String EMPNO; 
        
        public String USER_NAME;
        
        public String IP;
        
        public String LOGINTIME;
    }
}