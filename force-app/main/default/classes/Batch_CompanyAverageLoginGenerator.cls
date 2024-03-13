/**
 * @description       : Company Average Login Generator
 * @author            : vikrant.ks@samsung.com
 * @group             : 
 * @last modified on  : 2023-09-22
 * @last modified by  : vikrant.ks@samsung.com 
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2023-09-22   vikrant.ks@samsung.com   Initial Version(MySales 303)
**/
Global class Batch_CompanyAverageLoginGenerator implements Database.Batchable<sObject>, Database.Stateful, Schedulable{

    private static final String INTERFACE_ID = 'AverageLoginGenerator'; //V 1.0- MYSALES: 303
    private static final String APEX_CLASS   = 'Batch_CompanyAverageLoginGenerator'; 
    private static final String METHOD_NAME  = 'Execute';  
    private static String guId = IF_Util.generateGuid();
    
    Public Map<String,LoginUsers> LoginMap = new Map<String,LoginUsers>();
    Public Set<String> profileSet = new Set<String>(System.Label.CompanyAverageLogin_Profiles.split(','));
    Public Set<String> companySet = new Set<String>(System.Label.CompanyAverageLogin_CompanyNames.split(','));
    Public String recordType = System.Label.CompanyAverageLogin_UserType;
    Public Boolean isInterface = false;
    Date tempDate = Date.today().addMonths(-1);
    Public Date LoginDate = Date.newInstance(tempDate.Year(),tempDate.Month(),1);
    
    Public Batch_CompanyAverageLoginGenerator(){}
    Public Batch_CompanyAverageLoginGenerator(String month,String year,String RecordType,Set<String> company,Set<String> profile){
        this.LoginDate = Date.newInstance(Integer.valueOf(year),Integer.valueOf(month),1);
        this.recordType = RecordType;
        this.companySet = company;
        this.profileSet = profile;
        this.isInterface = true;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('Start Started');
        System.debug('LoginDate: '+LoginDate+' recordType: '+recordType+' companySet: '+companySet+' profileSet: '+profileSet+' isInterface: '+isInterface);
        
        String UserType = 'mySales';
        List<String> compCodeList = new List<String>{'T110','T120','T140','T640','T641','L1B0','L1E0','ZB01','ZB10',''};
        
        DateTime endTime  = DateTime.newInstanceGmt(Date.today().Year(),Date.today().Month(),1,0,0,0);
        DateTime startTime= endTime.addMonths(-1);
        
        if(isInterface){
            startTime = DateTime.newInstanceGmt(LoginDate.year(),LoginDate.month(),1,0,0,0);
			endTime= startTime.addMonths(1);
        }
        startTime= startTime.addHours(-9);
		endTime= endTime.addHours(-9);
        
        System.debug('String endTime: '+endTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX')+' startTime: '+startTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX'));
        system.debug('Start Ended');
        return Database.getQueryLocator('Select LoginTime__c, Id_Username__c, UserName__c, UserId__r.Profile.Name, UserId__r.EPCompanyName__c,  WeekNumLogin__c from UserLogin_Logs__c'+
                                        ' where LoginTime__c >= :startTime and LoginTime__c < :endTime and UserId__r.CompanyCode__c NOT IN :compCodeList'+
                                        ' and UserType__c = :UserType and UserId__r.Profile.Name in :profileSet and UserId__r.EPCompanyName__c in :companySet'+
                                         + (Test.isRunningTest()?' LIMIT 200':'')
                                       );
        
    }
    global void execute(Database.BatchableContext bc,List<UserLogin_Logs__c> UserLog){
        system.debug('Execute Started');
        for(UserLogin_Logs__c temp:UserLog){
            if(temp.UserId__r.EPCompanyName__c != null){
                if(LoginMap.get(temp.UserId__r.EPCompanyName__c) != null){
                    if(temp.UserId__r.Profile.Name != 'Sales Rep.(Logi)' && temp.UserId__r.Profile.Name != 'Sales Manager(Logi)'){
                        LoginMap.get(temp.UserId__r.EPCompanyName__c).ITuserSet.add(temp.Id_Username__c);
                    	LoginMap.get(temp.UserId__r.EPCompanyName__c).ITCount++;
                    }
                    else{
                        LoginMap.get(temp.UserId__r.EPCompanyName__c).LogiUserSet.add(temp.Id_Username__c);
                    	LoginMap.get(temp.UserId__r.EPCompanyName__c).LogiCount++;
                    }
                }
                else{
                    LoginUsers loginData = new LoginUsers();
                    Set<String> ISet = new Set<String>();
                    Set<String> LSet = new Set<String>();
                    loginData.ITuserSet   = ISet;
                    loginData.LogiUserSet = LSet;
                    if(temp.UserId__r.Profile.Name != 'Sales Rep.(Logi)' && temp.UserId__r.Profile.Name != 'Sales Manager(Logi)'){
                        loginData.ITuserSet.add(temp.Id_Username__c);
                        loginData.ITCount = 1;
                        loginData.LogiCount = 0;
                    }
                    else{
                        loginData.LogiUserSet.add(temp.Id_Username__c);
                        loginData.ITCount = 0;
                        loginData.LogiCount = 1;
                    }
                    
                    LoginMap.put(temp.UserId__r.EPCompanyName__c,loginData);
                }
            }
        }
    }
    global void finish(Database.BatchableContext bc){
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;        
        
        try{
            if(isInterface){
                List<CompanyLoginAverage__c> deleteList;
                if(recordType == 'ALL'){
                    deleteList = [Select Id from CompanyLoginAverage__c where LoginDate__c = :LoginDate];
                }
                else if(recordType == 'IT'){
                    deleteList = [Select Id from CompanyLoginAverage__c where LoginDate__c = :LoginDate and UserType__c = 'IT'];
                }
                else{
                    deleteList = [Select Id from CompanyLoginAverage__c where LoginDate__c = :LoginDate and UserType__c != 'IT'];
                }
                Delete deleteList;
            }
                        
            List<CompanyLoginAverage__c> insertList = new List<CompanyLoginAverage__c>();
            System.debug('LoginMap.keySet(): '+LoginMap.keySet());
            For(String com:LoginMap.keySet()){
                if(LoginMap.get(com).ITCount > 0 && LoginMap.get(com).ITuserSet.size() > 0 && recordType != 'Logistics' && recordType != '물류'){
                	CompanyLoginAverage__c ITCompLogin = new CompanyLoginAverage__c();
                    ITCompLogin.CompanyName__c = com;
                    ITCompLogin.MonthlyLoginCount__c = LoginMap.get(com).ITCount;
                    ITCompLogin.MonthlyUserCount__c = LoginMap.get(com).ITuserSet.size();
                    ITCompLogin.LoginDate__c = LoginDate;
                    ITCompLogin.UserType__c = 'IT';
                    insertList.add(ITCompLogin);
                }
                if(LoginMap.get(com).LogiCount > 0 && LoginMap.get(com).LogiUserSet.size() > 0 && recordType != 'IT'){
                	CompanyLoginAverage__c LogiCompLogin = new CompanyLoginAverage__c();
                    LogiCompLogin.CompanyName__c = com;
                    LogiCompLogin.MonthlyLoginCount__c = LoginMap.get(com).LogiCount;
                    LogiCompLogin.MonthlyUserCount__c = LoginMap.get(com).LogiUserSet.size();
                    LogiCompLogin.LoginDate__c = LoginDate;
                    LogiCompLogin.UserType__c = '물류';
                    insertList.add(LogiCompLogin);
                }
            }
            system.debug('insertList: '+insertList.size()+'_'+insertList);
            insert insertList;
            
            batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);
            ifFinishLog.addLog('#####-----##### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + '#####-----##### ');
            ifFinishLog.addLog('insertList: '+insertList);
            ifFinishLog.createLog(batchFinishLog);
            
            }catch(Exception e){
             batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', 0, 0,e);
             ifFinishLog.createLog(batchFinishLog);
        }     
    }
    global void execute(SchedulableContext sc){
        DataBase.executeBatch(new Batch_CompanyAverageLoginGenerator(), 200);
    }
    
    public class LoginUsers{
        public Set<String> ITuserSet;
        public Integer ITCount;
        public Set<String> LogiUserSet;
        public Integer LogiCount;
    }
}