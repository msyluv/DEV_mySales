/**
* @description       : Program that sends user access logs for mySales to DataLake when requested (IF-181)
* @author            : vikrant.ks@samsung.com
* @group             : 
* @last modified on  : 2023-06-19
* @last modified by  : vikrant.ks@samsung.com 
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2023-05-22   vikrant.ks@samsung.com   Initial Version(MySales 208)
* 1.1   2023-06-09   vikrant.ks@samsung.com   Check if any values are Null in output before sending.(MySales -229)
* 1.2   2023-06-15   vikrant.ks@samsung.com   Add condition to exclude user 'IF_USER'.(MySales - 232)
* 1.3   2023-06-19   vikrant.ks@samsung.com   Change extraction value (Employee --> User) (MySales - 236)
**/
@RestResource(urlMapping = '/IF181/*')
global class IF_SendUserLogstoDataLake{
    
    private static final String INTERFACE_ID = 'IF-181';
    private static final String APEX_CLASS   = 'IF_SendUserLogstoDataLake';
    private static final String METHOD_NAME  = 'sendLoginHistorytoDataLake'; 
    private static String guId = IF_Util.generateGuid();
    private static Integer errorCount = 0;
    
    @HttpPost
    global static void sendLoginHistorytoDataLake(){
        
        OutputHeader outHeader   = new OutputHeader();
        IF_Log ifLog;
        IF_Log.InterfaceLog interfaceLog;
        List<String> errorMsgList = new List<String>();        
		RestResponse rep = RestContext.response;
        String inputJsonData;
        
		ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');
		try
        {
            RestRequest req = RestContext.request;
            Blob    reqBody = req.requestBody;
    
            rep.addHeader('Content-Type', 'application/json');
            
            if(reqBody == null || reqBody.toString() == '{}') {
                outHeader.RESULT = 'F';
                outHeader.RESULT_MESSAGE = 'Request body is Null or Empty.';
                rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(),JSON.serialize(outHeader));
                ifLog.createLog(interfaceLog);
                return;      
            }
            
            inputJsonData = reqBody.toString();
            system.debug('inputJsonData : ' + inputJsonData);
            ifLog.addLog('HttpRequest : ' + inputJsonData); 
            
            InputHeader inputHeader = (InputHeader) JSON.deserialize(inputJsonData, InputHeader.class);
            if( inputHeader == null || inputHeader.FROM_DATE == '' ){
                outHeader.RESULT = 'F';
                outHeader.RESULT_MESSAGE = 'FROM DATE variable is Null or Empty.';
                rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData,JSON.serialize(outHeader));
                ifLog.createLog(interfaceLog);
                return;
            }
            if(!validate(inputHeader.FROM_DATE)){
                outHeader.RESULT = 'F';
                outHeader.RESULT_MESSAGE = 'FROM DATE variable is not in a valid format.';
                rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData,JSON.serialize(outHeader));
                ifLog.createLog(interfaceLog);
                return;
            }
            system.debug('inputHeader : ' + inputHeader);        
            system.debug('inputDataList : ' + inputHeader.FROM_DATE);
             
            Map<Id,User> userMap = new Map<Id,User>([Select Id,EvCompany__c,EvEmployeeNumber__c,EmployeeName__c,Email from User 
                                                     Where EmployeeName__c != null and EvEmployeeNumber__c != null and EvCompany__c != null 
                                                     and EmployeeName__c != '' and EvEmployeeNumber__c != '' and EvCompany__c != '']); //v1.3
                        
            Datetime startTime = stringtoDatetime(inputHeader.FROM_DATE);
            
            Date myDate = Date.today();
            Time myTime = Time.newInstance(0, 0, 0, 0);
            DateTime endTime = DateTime.newInstance(myDate, myTime);
          
            List<User> if_users = [select Id from USER where name like '%if_user%'];//v1.2
            set<Id> jitterUserID= new set<Id>();//v1.2
            for(User u:if_users)//v1.2
            {
                jitterUserID.add(u.Id);
            }
            
            String query='Select UserId, LoginTime,SourceIp, Application,Status '+
                                            'from LoginHistory '+ 
                                            'where UserId != NULL and LoginTime != NULL and SourceIp != NULL and '+ //v1.1 
                                            'LoginTime >= :startTime and LoginTime < :endTime and UserId NOT IN :jitterUserID' + (Test.isRunningTest()?' LIMIT 200':'');//v1.2
            String QueryForCount='Select COUNT() from LoginHistory '+ 
                                            'where UserId != NULL and LoginTime != NULL and SourceIp != NULL and '+ //v1.1 
                                            'LoginTime >= :startTime and LoginTime < :endTime and UserId NOT IN :jitterUserID' + (Test.isRunningTest()?' LIMIT 200':'');//v1.2
            if(Database.countQuery(QueryForCount)>50000)
            {
                outHeader.RESULT = 'F';
                outHeader.RESULT_MESSAGE = 'The target data size exceeded the maximum.';
                rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData,JSON.serialize(outHeader));
                ifLog.createLog(interfaceLog);
                return;
            }
            List<LoginHistory> objList=Database.query(query);
        
            List<OutputClass> loginHistoryList = new List<OutputClass>();
        
            for(LoginHistory log : objList)
            {
                if(userMap.get(log.UserId) != null && !log.Application.toLowerCase().contains('jitterbit') 
                   && log.Status == 'Success' && userMap.get(log.UserId).Email  != 'noreply@salesforce.com')
                { 
                    OutputClass loginHistory = new OutputClass();
                    loginHistory.SYSTEM_CODE = 'C0001001';
                    loginHistory.MENU_NAME = 'Home';
                    loginHistory.COMPANY = userMap.get(log.UserId).EvCompany__c;//v1.3
                    loginHistory.EMPNO = userMap.get(log.UserId).EvEmployeeNumber__c;//v1.3
                    loginHistory.USER_NAME = userMap.get(log.UserId).EmployeeName__c;//v1.3
                    loginHistory.IP = log.SourceIp;
                    Datetime tempTime = log.LoginTime;
                    loginHistory.LOGINTIME = tempTime.format('yyyy-MM-dd HH:mm:ss');
                    
                    loginHistoryList.add(loginHistory);
                }
            }
            outHeader.RESULT = 'S';
            outHeader.RESULT_MESSAGE = 'The request has been processed successfully.';
            outHeader.LOGIN_HISTORY = loginHistoryList;
            
            String sendData = JSON.serialize(outHeader);
            ifLog.addLog('Response : ' + sendData);
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData);
            
        }catch(Exception e)
        {
            outHeader.RESULT = 'F';
            outHeader.RESULT_MESSAGE = 'An error occurred when processing the request.' +' | '+e.getMessage();
            String sendData          = JSON.serialize(outHeader);
            ifLog.addLog('Response : ' + sendData);            
            ifLog.addLog('Exception : ' + e.getMessage());
            errorMsgList.add('Exception : ' + e.getMessage());

            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData, e);      
        }
        
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');
        ifLog.createLog(interfaceLog);        

        rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
    }
       
    public class OutputHeader{
        public String RESULT;
        public String RESULT_MESSAGE;
        public List<OutputClass> LOGIN_HISTORY;
    }
    public class OutputClass{
        
        public String SYSTEM_CODE; 
        
        public String MENU_NAME; 
        
        public String COMPANY;
        
        public String EMPNO; 
        
        public String USER_NAME;
        
        public String IP;
        
        public String LOGINTIME;
    }
    public class InputHeader{
        public String FROM_DATE;
    }
    public static Datetime stringtoDatetime(String s)
    {
		Integer year= Integer.valueof(s.substring(0, 4));
        Integer month= Integer.valueof(s.substring(4,6));
        Integer day= Integer.valueof(s.substring(6,8));
        Integer hour= Integer.valueof(s.substring(8, 10));
        Integer minute= Integer.valueof(s.substring(10,12));
        Integer sec= Integer.valueof(s.substring(12,14));
		Datetime dt = Datetime.newInstance(year,month,day,hour,minute,sec);
        
		return dt;
    }
    public static Boolean validate(String s)
    {
        if(!s.isNumeric()) return false;
        if(s.length() != 14) return false;
        
        Integer year= Integer.valueof(s.substring(0, 4));
        Integer month= Integer.valueof(s.substring(4,6));
        Integer day= Integer.valueof(s.substring(6,8));
        Date myDate;
        string stringDate = year + '-' + month + '-' + day;
        
        try{myDate = date.valueOf(stringDate);} 
        catch(Exception e){System.debug(e);return false;}
        if(myDate >= Date.today()) return false;
        return true;
    }
}