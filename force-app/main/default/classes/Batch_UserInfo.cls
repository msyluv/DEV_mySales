/**
* @description       : 
* @author            : g.navneet@samsung.com
* @group             : 
* @last modified on  : 2023-4-13
* @last modified by  : g.navneet@samsung.com 
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2023-04-13   g.navneet@samsung.com   Initial Version(MySales 167)
**/

global class Batch_UserInfo implements Database.Batchable<sObject>, Database.Stateful, Schedulable
{
    
    private static final String INTERFACE_ID = 'BATCH_upsert_UserInfo';
    private static final String APEX_CLASS   = 'Batch_UserInfo'; 
    private static final String METHOD_NAME  = 'Execute';  
    private static String guId = IF_Util.generateGuid();
    
    // instance member to retain state across transactions
    public Integer recordsProcessed = 0;
    
    private Map<Id,Id> userInfoMap = new Map<Id,Id>();
    public Database.QueryLocator start(Database.BatchableContext bc) 
    {
        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
        ifStartLog.addLog('#####-----##### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + '#####-----##### ');
        
        ifStartLog.createLog(batchStartLog);
        
        List<UserInfo__c> userInfoList= new List<UserInfo__c>([Select Id,User_Id__c from UserInfo__c]);
        for(UserInfo__c info:UserInfoList)
        {
            userInfoMap.put(info.User_Id__c,info.Id);
        }
        return Database.getQueryLocator( 'Select Id,Username, Name, Email, CompanyPosition__c,'+
                                        ' Title, IsActive,UserRole.Name, Profile.Name, CompanyCode__c, EvCompany__c,'+
                                        ' CompanyName,Department, Division__c, EvKostl__c, CostCenter_Level_3__c,'+
                                        ' CostCenter_Level_4__c, CostCenter_Level_5__c from User' + (Test.isRunningTest()?' LIMIT 200':'')
                                       );
    }
    global void execute(Database.BatchableContext bc, List<User> userList){
        
        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        
        // process each batch of records
        List<UserInfo__c> newUserInfo = new List<UserInfo__c>();
        try{
            
            
            for (User user : userList)
            {
                UserInfo__c temp=new UserInfo__c();
                if(userInfoMap.containsKey(user.Id)) 
                {
                    temp.Id=userInfoMap.get(user.Id);
                }
                temp.User_Id__c=user.Id;
                temp.Username__c = user.Username;
                temp.Name__c = user.Name;		
                temp.Email__c = user.Email; 			
                temp.Company_Position__c = user.CompanyPosition__c; 			
                temp.Title__c = user.Title; 			
                temp.IsActive__c = user.IsActive;
                temp.Role_Name__c = user.UserRole.Name; 			
                temp.Profile_Name__c = user.Profile.Name;			
                temp.Company_Code__c = user.CompanyCode__c; 			
                temp.EpCompany__c = user.EvCompany__c; 			
                temp.Company_Name__c = user.CompanyName; 			
                temp.Department_Name__c = user.Department; 			
                temp.Division_Name__c = user.Division__c; 			  
                temp.CostCenter_Code__c = user.EvKostl__c; 			
                temp.CostCenter_L3__c = user.CostCenter_Level_3__c; 			
                temp.CostCenter_L4__c = user.CostCenter_Level_4__c; 			
                temp.CostCenter_L5__c = user.CostCenter_Level_5__c;
                newUserInfo.add(temp);
                // increment the instance member counter
                recordsProcessed = recordsProcessed + 1;
            }
            
            if(newUserInfo.size()>0){
                upsert newUserInfo;
            }
            //create Interface Log
            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Execute', '', 0);
            ifExcutelog.createLog(batchExcuteLog);
        }catch(Exception e){
            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, e.getMessage(), 0, 0,e);
            ifExcutelog.createLog(batchExcuteLog);
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {
        System.debug(recordsProcessed + ' records processed');
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);
        ifFinishLog.addLog('#####-----##### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + '#####-----##### ');
        ifFinishLog.createLog(batchFinishLog);
    }
    global void execute(SchedulableContext sc) 
    {
        Database.executeBatch(new Batch_UserInfo(),200);
        
    }
}