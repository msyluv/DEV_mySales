public class Batch_UpdateUserInfo_Tester implements Database.StateFul, Database.Batchable<sobject>, schedulable {
    
    private static final String INTERFACE_ID = 'BATCH-UPDATEUSER';//V1.3 - MYSALES :105
    private static final String APEX_CLASS   = 'Batch_UpdateUserInfoController'; 
    private static final String METHOD_NAME  = 'Batch';
    private static String guId = IF_Util.generateGuid();

    private Map<String, String> CompEmpNameMap = new Map<String, String>();
  
    public Batch_UpdateUserInfo_Tester(){
        List<Company__c> compList = [SELECT Id, Name, CompanyCode__c, EPCompanyName__c FROM Company__c];
        if(!compList.isEmpty()){
            for(Company__c comp : compList){
                CompEmpNameMap.put(comp.CompanyCode__c, comp.EPCompanyName__c);
            }
        }
    }
    Map<String,String> ccMap = new Map<String,String>(); 
    Map<String,String> ccT3Map = new Map<String,String>(); //Added by Anish -V1.5
    Map<String,String> ccT4Map = new Map<String,String>(); //Added by Anish -V1.5
    Map<String,String> ccT5Map = new Map<String,String>(); //Added by Anish -V1.5
    List<CostCenter__c> lstCC = new List<CostCenter__c>(); 
    Map<String, User> userMap = new Map<String, User>();
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + ' ####################');
        ifStartLog.createLog(batchStartLog);
        
        lstCC = [SELECT Id, Name,CostCenter__c,Text2__c,Text3__c,Text4__c,Text5__c From CostCenter__c]; //Added by Anish -V1.5
        for(CostCenter__c cc : lstCC){
           ccMap.put(cc.CostCenter__c, cc.Text2__c);
           ccT3Map.put(cc.CostCenter__c, cc.Text3__c); //Added by Anish -V1.5
           ccT4Map.put(cc.CostCenter__c, cc.Text4__c); //Added by Anish -V1.5
           ccT5Map.put(cc.CostCenter__c, cc.Text5__c); //Added by Anish -V1.5
        }//End - Added by Anish - v 1.4
	
        Set<String> userFederationId = new Set<String>();
        List<User> userList = new List<User>([SELECT Id, Name, Title, MobilePhone, CompanyName, EmployeeNumber, FederationIdentifier, CompanyCode__c, Department,EvCompany__c, EvKostl__c, EvDept__c, EPCompanyName__c FROM User where IsActive = true and FederationIdentifier != null and CompanyCode__c != null]);
        for(User user : userList){
            userFederationId.add(user.FederationIdentifier);
            userMap.put(user.FederationIdentifier + '_' + user.CompanyCode__c, user);
        }

        String queryString = 'Select EvSapEmpNO__c, EvUniqID__c, EvSapBukrs__c,  Id, Name, EvTitleJikChakNM__c, EvCellTel__c, EvCompNM__c, '+
                             'EvSdeptNM__c, EvCompany__c, EvKostl__c, EvDept__c, EvCompENM__c, LastModifiedDate,EvJikGiubNM__c,EvEmpNO__c from Employee__c '+
                             'Where Status__c = null and EvUniqID__c in :userFederationId and EvSapBukrs__c != null order by LastModifiedDate ASC' + (Test.isRunningTest()?' LIMIT 200':'');
        
        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');

        return DataBase.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext BC, List<Employee__c> empList){
        
		System.debug('scopeList : ' + empList);

        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 시작' + ' ####################');
          
        Integer updateUserCount = 0;
        Map<Id, User> userUpdateMap = new Map<Id, User>();
        
        try{
            if(empList.size() > 0){
                for( Employee__c emp : empList){
                    if(userMap.get(emp.EvUniqID__c + '_' + emp.EvSapBukrs__c) != null){
                        User user = userMap.get(emp.EvUniqID__c + '_' + emp.EvSapBukrs__c);
                        user.Title = emp.EvJikGiubNM__c;  //Added by Anish - V1.5
                        user.CompanyPosition__c = emp.EvTitleJikChakNM__c;  //Added by Anish - V1.5
                        user.MobilePhone = emp.EvCellTel__c;
                        user.CompanyName = emp.EvCompNM__c;
                        user.Department = emp.EvSdeptNM__c;
                        user.EvCompany__c = emp.EvCompany__c;
                        user.Division__c = ccMap.get(emp.EvKostl__c); //Added by Anish - v 1.4
                        user.CostCenter_Level_3__c = ccT3Map.get(emp.EvKostl__c); //Added by Anish - V1.5
                        user.CostCenter_Level_4__c = ccT4Map.get(emp.EvKostl__c); //Added by Anish - V1.5
                        user.CostCenter_Level_5__c = ccT5Map.get(emp.EvKostl__c); //Added by Anish - V1.5
                        user.EvKostl__c = emp.EvKostl__c;
                        user.EvDept__c = emp.EvDept__c;
                        user.EmployeeNumber = emp.EvSapEmpNO__c;
                        user.EvEmployeeNumber__c = emp.EvEmpNO__c; //v1.6
                        user.EmployeeName__c = emp.Name; //v1.6
                        user.EPCompanyName__c = CompEmpNameMap.get(emp.EvSapBukrs__c) != null ? CompEmpNameMap.get(emp.EvSapBukrs__c) : ''; // 2022-01-27 / EP Company Name 신규 추가
                        userUpdateMap.put(user.Id, user);
                        
                        ifExcuteLog.addLog( 'updateUser Name : ' + user.Name + ', BeforeUpdateData : '+ String.valueOf(user));
                        updateUserCount += 1;
                    }
                }
            }
            
            update userUpdateMap.values();
    
            ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');
            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', '', 0);
            ifExcutelog.createLog(batchExcuteLog);
    	}catch(Exception e){
             batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, e.getMessage(), 0, 0,e);
             ifExcutelog.createLog(batchExcuteLog);
        }
    }

    public void finish(DataBase.BatchableContext BC){
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);
        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');
        
        ifFinishLog.createLog(batchFinishLog);
    }

    public void execute(SchedulableContext sc){
        DataBase.executeBatch(new Batch_UpdateUserInfoController(), 200);
        /*
         Batch_UpdateUserInfo_Tester batch = new Batch_UpdateUserInfo_Tester(); 
		 String sch = '0 0 08 * * ? *';
		 String jobIDNew = system.schedule('Batch Update UserInfo', sch, batch);
         */
    } 
}