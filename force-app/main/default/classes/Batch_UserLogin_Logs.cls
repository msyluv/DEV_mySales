/**
 * @description       : Extract LoginHistory information and insert them into UserLogin_Logs object every morning.
 * @author            : vikrant.ks@samsung.com
 * @group             : 
 * @last modified on  : 2023-06-19 
 * @last modified by  : vikrant.ks@samsung.com 
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2023-04-11   vikrant.ks@samsung.com   Initial Version(MySales 166)
 * 1.1   2023-06-08   vikrant.ks@samsung.com   Added New Field 'SourceIp' -> MySales- 226
 * 1.2   2023-06-15   vikrant.ks@samsung.com   Add condition to exclude user 'IF_USER'.(MySales - 232)
 * 1.3   2023-06-19   vikrant.ks@samsung.com   Add 14 new fields and assign data from User object.(MySales - 237)
 * 1.4   2023-09-13   vikrant.ks@samsung.com   Change in extract condition and upsert LoginHistory into UserLogin_Logs__c object twice a day (Key : HistoryId__c).(MySale- 295)
**/
global class Batch_UserLogin_Logs implements Database.Batchable<sObject>, Database.Stateful, Schedulable
{
    private static final String INTERFACE_ID = 'BATCH-INSERTUSER_LOGS'; //V 1.0- MYSALES: 166
    private static final String APEX_CLASS   = 'Batch_UserLogin_Logs'; 
    private static final String METHOD_NAME  = 'Execute';  
    private static String guId = IF_Util.generateGuid();
    
    private Map<Id,User> userMap;
    private Map<Id,Id> userInfoMap = new Map<Id,Id>();
    public Map<String,String> UserLogMap = new Map<String,String>(); //V1.4
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
        ifStartLog.addLog('#####-----##### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + '#####-----##### ');
        
        //V1.4 START
        DateTime sTime     = DateTime.now();
        DateTime startTime = sTime.addDays(-1);
        //V1.4 END
        
        
        List<UserInfo__c> UserInfoList = new List<UserInfo__c>([Select Id,User_Id__c from UserInfo__c]);
        if(UserInfoList.Size()>0)
        {
        	for(UserInfo__c info:UserInfoList)
            {
                userInfoMap.put(info.User_Id__c,info.Id);
            }
        }
        //V1.4 START
        List<UserLogin_Logs__c> userloglist = new List<UserLogin_Logs__c>();
        if(Test.isRunningTest()){
        	userloglist = [Select Id,HistoryId__c from UserLogin_Logs__c where LoginTime__c > :startTime LIMIT 45000];
        }else{
            userloglist = [Select Id,HistoryId__c from UserLogin_Logs__c where LoginTime__c > :startTime];
        }
        System.debug('userloglist: '+userloglist.size()+' --'+userloglist);
        For(UserLogin_Logs__c userLog:userloglist){
            UserLogMap.put(userLog.HistoryId__c,userLog.Id);
        }
        //V1.4 END
        userMap = new Map<Id,User>([Select Name, Email, CompanyCode__c, UserRole.Name, Profile.Name, Username ,EvCompany__c ,
                                    CompanyName ,EPCompanyName__c ,EmployeeNumber ,EvEmployeeNumber__c ,DepartmentName__c ,Title ,
                                    CompanyPosition__c ,Division__c ,CostCenter_Level_3__c ,CostCenter_Level_4__c, CostCenter_Level_5__c from User]);//v1.3
        ifStartLog.createLog(batchStartLog);
        
        List<User> if_users = [select Id from USER where name like '%if_user%'];//v1.2
        set<Id> jitterUserID= new set<Id>();//v1.2
        for(User u:if_users)//v1.2
        {
            jitterUserID.add(u.Id);
        }
        
        //V 1.1- MYSALES: 226 Added SourceId field in query
        return Database.getQueryLocator('Select Id, UserId, LoginTime, LoginType, LoginUrl, Browser, Platform, Application,Status,SourceIp '+
                                         'from LoginHistory '+ 
                                         'where LoginTime >= :startTime and UserId NOT IN :jitterUserID' + (Test.isRunningTest()?' LIMIT 200':'')//v1.2 and //V1.4
                                       );
    }
    
    global void execute(Database.BatchableContext bc, List<LoginHistory> logList)
    {
        System.debug('logList:'+logList.Size());
        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        
        List<UserLogin_Logs__c> userList=new List<UserLogin_Logs__c>();
        try{
            
            if(logList.size()>0)
            {
                for(LoginHistory log:logList)
                { 
                    if(!log.Application.toLowerCase().contains('jitterbit') && log.Status == 'Success' && userMap.get(log.UserId).Email  != 'noreply@salesforce.com')
                    {
                        UserLogin_Logs__c temp = new UserLogin_Logs__c();
                        //V1.4 START
                        if(UserLogMap.containsKey(log.Id)){
                            temp.Id = UserLogMap.get(log.Id);
                        }
                        //V1.4 END
                        temp.HistoryId__c=log.Id;
                        temp.UserId__c=log.UserId; 
                        temp.UserName__c=userMap.get(log.UserId).Name;
                        temp.UserEmail__c=userMap.get(log.UserId).Email; 
                        temp.LoginTime__c=log.LoginTime;
                        temp.LoginType__c=log.LoginType;
                        temp.LoginURL__c=log.LoginUrl; 
                        temp.Browser__c=log.Browser;
                        temp.Platform__c=log.Platform; 
                        temp.Application__c=log.Application;
                        temp.UserCompanyCode__c=userMap.get(log.UserId).CompanyCode__c;
                        temp.UserRole__c = userMap.get(log.UserId).UserRole.Name;
                        temp.UserProfile__c=userMap.get(log.UserId).Profile.Name;
                        temp.UserInfo__c= userInfoMap.get(log.UserId);
                        temp.SourceIp__c=log.SourceIp; //v1.1 MySales- 226
                        temp.Id_Username__c = userMap.get(log.UserId).Username;//v1.3 from here till next '//v1.3'
                        temp.EpCompanyCode__c = userMap.get(log.UserId).EvCompany__c;			
                        temp.CompanyName__c = userMap.get(log.UserId).CompanyName;		
                        temp.EpCompanyName__c = userMap.get(log.UserId).EPCompanyName__c;			
                        temp.EvSapEmpNO__c = userMap.get(log.UserId).EmployeeNumber;			
                        temp.EvEmpNO__c = userMap.get(log.UserId).EvEmployeeNumber__c;		
                        temp.DepartmentName__c = userMap.get(log.UserId).DepartmentName__c;			
                        temp.Title_JikGiubNM__c = userMap.get(log.UserId).Title;			
                        temp.Position_JikChakNM__c = userMap.get(log.UserId).CompanyPosition__c;		
                        temp.DivisionName__c = userMap.get(log.UserId).Division__c;		
                        temp.CostCenter_L3__c = userMap.get(log.UserId).CostCenter_Level_3__c;	
                        temp.CostCenter_L4__c = userMap.get(log.UserId).CostCenter_Level_4__c;		
                        temp.CostCenter_L5__c = userMap.get(log.UserId).CostCenter_Level_5__c;
                        temp.UserType__c = userMap.get(log.UserId).Profile.Name.contains('Partner Community')?'MSP Partner' : 'mySales'; //v1.3
                                                         
                        userList.add(temp);
                    }
                }
            }
            String sendData = JSON.serialize(userList);
            ifExcuteLog.addLog(userList);
            
            if(userList.Size()>0)
            {
               upsert userList; //v 1.4
            }
            //create Interface Log
            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', '', 0);
            ifExcutelog.createLog(batchExcuteLog);
        }catch(Exception e){
             batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, e.getMessage(), 0, 0,e);
             ifExcutelog.createLog(batchExcuteLog);
        } 
    }
    
    global void finish(Database.BatchableContext bc)
    {
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);
        ifFinishLog.addLog('#####-----##### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + '#####-----##### ');
        ifFinishLog.createLog(batchFinishLog);
    }
    global void execute(SchedulableContext sc)
    {
        Database.executeBatch(new Batch_UserLogin_Logs(),200);
        /*
         Batch_UserLogin_Logs batch = new Batch_UserLogin_Logs(); 
		 String sch = '0 30 08 * * ? *';
		 String jobIDNew = system.schedule('Batch UserLogin Logs', sch, batch);
         */
        
    }
}