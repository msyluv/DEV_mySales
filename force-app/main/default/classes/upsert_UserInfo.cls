global class upsert_UserInfo implements Database.Batchable<sObject>, Database.Stateful, Schedulable
{
    
    private static final String INTERFACE_ID = 'BATCH_upsert_UserInfo'; //V 1.0- MYSALES: 167
    private static final String APEX_CLASS   = 'Batch_upsert_UserInfo'; 
    private static final String METHOD_NAME  = 'Execute';  
    private static String guId = IF_Util.generateGuid();
    
    // instance member to retain state across transactions
    public Integer recordsProcessed = 0;
    List<User> userList;
    private Map<Id,User> userMap = new Map<Id,User>();
    public Database.QueryLocator start(Database.BatchableContext bc) 
    {
        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
        ifStartLog.addLog('#####-----##### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + '#####-----##### ');
        
        ifStartLog.createLog(batchStartLog);
        userList = new List<User>([select Id, Username, Name, Email, CompanyPosition__c, Title, IsActive,
                                   UserRole.Name, Profile.Name, CompanyCode__c, EvCompany__c, CompanyName,
                                   Department, Division__c, EvKostl__c, CostCenter_Level_3__c, CostCenter_Level_4__c, CostCenter_Level_5__c from User]);
        if(userList.Size()>0)
        {
        	for(User user:userList)
            {
                userMap.put(user.Id,user);
            }
        }
        List<UserInfo__c> infoList = new List<UserInfo__c>([Select User_Id__c from UserInfo__c]);
        List<Id> infoIds = new List<Id>();
        if(infoList.Size()>0)
        {
        	for(UserInfo__c temp:infoList)
            {
                infoIds.add(temp.User_Id__c);
            }
        }
        List<User> newUser= new List<User>([Select Id,Username, Name, Email, CompanyPosition__c, Title, IsActive,
                                   UserRole.Name, Profile.Name, CompanyCode__c, EvCompany__c, CompanyName,
                                   Department, Division__c, EvKostl__c, CostCenter_Level_3__c, CostCenter_Level_4__c, CostCenter_Level_5__c from User where Id NOT IN :infoIds]);
        List<UserInfo__c> newUserInfoList = new List<UserInfo__c>();
        for(User temp:newUser)
        {
            newUserInfoList.add(new UserInfo__c(
                User_Id__c=temp.Id,
                Username__c = temp.Username,
                Name__c = temp.Name, 			
                Email__c = temp.Email, 			
                Company_Position__c = temp.CompanyPosition__c, 			
                Title__c = temp.Title, 			
                IsActive__c = temp.IsActive,
                Role_Name__c = temp.UserRole.Name, 			
                Profile_Name__c = temp.Profile.Name,			
                Company_Code__c = temp.CompanyCode__c, 			
                EpCompany__c = temp.EvCompany__c, 			
                Company_Name__c = temp.CompanyName,		
                Department_Name__c = temp.Department,		
                Division_Name__c = temp.Division__c,			
                CostCenter_Code__c = temp.EvKostl__c, 			
                CostCenter_L3__c = temp.CostCenter_Level_3__c, 			
                CostCenter_L4__c = temp.CostCenter_Level_4__c, 			
                CostCenter_L5__c = temp.CostCenter_Level_5__c));
        }
        insert newUserInfoList;
        return Database.getQueryLocator(     
  			'Select Id,User_Id__c,Username__c,Name__c,Email__c,Company_Position__c,Title__c,IsActive__c, '+
                                                                'Role_Name__c,Profile_Name__c,Company_Code__c,EpCompany__c, '+
                                                                'Company_Name__c,Department_Name__c,Division_Name__c,CostCenter_Code__c,CostCenter_L3__c, '+
                                                                'CostCenter_L4__c,CostCenter_L5__c from UserInfo__c' + (Test.isRunningTest()?' LIMIT 200':'')
        );
    }
    global void execute(Database.BatchableContext bc, List<UserInfo__c> userInfoList){

        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        
        // process each batch of records
        
        for (UserInfo__c info : userInfoList)
        {
            if(userMap.containsKey(info.User_Id__c))
            {   
                info.Username__c = userMap.get(info.User_Id__c).Username;
                info.Name__c = userMap.get(info.User_Id__c).Name; 			
                info.Email__c = userMap.get(info.User_Id__c).Email; 			
                info.Company_Position__c = userMap.get(info.User_Id__c).CompanyPosition__c; 			
                info.Title__c = userMap.get(info.User_Id__c).Title; 			
                info.IsActive__c = userMap.get(info.User_Id__c).IsActive;
                info.Role_Name__c = userMap.get(info.User_Id__c).UserRole.Name; 			
                info.Profile_Name__c = userMap.get(info.User_Id__c).Profile.Name;			
                info.Company_Code__c = userMap.get(info.User_Id__c).CompanyCode__c; 			
                info.EpCompany__c = userMap.get(info.User_Id__c).EvCompany__c; 			
                info.Company_Name__c = userMap.get(info.User_Id__c).CompanyName; 			
                info.Department_Name__c = userMap.get(info.User_Id__c).Department; 			
                info.Division_Name__c = userMap.get(info.User_Id__c).Division__c; 			
                info.CostCenter_Code__c = userMap.get(info.User_Id__c).EvKostl__c; 			
                info.CostCenter_L3__c = userMap.get(info.User_Id__c).CostCenter_Level_3__c; 			
                info.CostCenter_L4__c = userMap.get(info.User_Id__c).CostCenter_Level_4__c; 			
                info.CostCenter_L5__c = userMap.get(info.User_Id__c).CostCenter_Level_5__c; 			
            }
            
            // increment the instance member counter
            recordsProcessed = recordsProcessed + 1;
            }
        ifExcuteLog.addLog( '#####-----##### ['+userInfoList.size()+']#####-----#####  UserInfos upserted');
        
        update userInfoList;
        
        //create Interface Log
        batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', '', 0);
        ifExcutelog.createLog(batchExcuteLog);
    }
    
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed');
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);
        ifFinishLog.addLog('#####-----##### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + '#####-----##### ');
        ifFinishLog.createLog(batchFinishLog);
    }
    global void execute(SchedulableContext sc)
    {
        Database.executeBatch(new upsert_UserInfo(),200);
        
    }
}