/**
 * @author            : younghoon.kim@dkbmc.com
 * @description       : [IF-151] mySales의 사용자 접속 로그 전송
 * 		              : [schedule execution code] System.Schedule('Batch_UserLoginHistoryController', '0 0 * * * ? *', new Batch_UserLoginHistoryController());
 * @last modified on  : 2022-04-14
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2022-01-21   younghoon.kim@dkbmc.com  Initial Version
**/
public class Batch_UserLoginHistoryController implements Database.Stateful, Database.Batchable<sObject>, Database.AllowsCallouts, schedulable{
    private static final String INTERFACE_ID = 'IF-151';
    private static final String APEX_CLASS   = 'Batch_UserLoginHistoryController';
    private static final String METHOD_NAME  = 'sendLoginHistory';
    
    List<IF_Log.InterfaceLog> ifLogList = new List<IF_Log.InterfaceLog>();

    private static Integer errorCount = 0;
    
    public Batch_UserLoginHistoryController(){
        System.debug('========== IF-151 ==========');
        System.debug('========== Batch_UserLoginHistoryController ==========');
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('========== start ==========');
        Datetime deadline = Datetime.now().addHours(-1); 
        string QUERY_STRING = 'SELECT Id ' +
                              '     , UserId ' +
                              '     , LoginTime ' +
                              '     , LoginType ' +
                              '     , SourceIp ' +
                              '     , LoginUrl ' +
                              '     , AuthenticationServiceId ' +
                              '     , LoginGeoId ' +
                              '     , TlsProtocol ' +
                              '     , CipherSuite ' +
                              '     , OptionsIsGet ' +
                              '     , OptionsIsPost ' +
                              '     , Browser ' +
                              '     , Platform ' +
                              '     , Status ' +
                              '     , Application ' +
                              '     , ClientVersion ' +
                              '     , ApiType ' +
                              '     , ApiVersion ' +
                              '     , CountryIso ' +
                              '     , AuthMethodReference ' +
                              '  FROM LoginHistory ' +
                              ' WHERE LoginTime >= :deadline ' +
                              ' ORDER BY LoginTime DESC ';
        if(Test.isRunningTest()) QUERY_STRING += ' LIMIT 100';
        System.debug('QUERY_STRING : ' + QUERY_STRING);
        
        return Database.getQueryLocator(QUERY_STRING);
    }
    
    public void execute(Database.BatchableContext bc, List<LoginHistory> objList) {
        System.debug('========== execute ==========');
        System.debug('Query Result Size : ' + objList.size());

        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name, IsActive, Email, ProfileId, Profile.Name, UserRoleId, UserRole.Name, CompanyCode__c FROM User WHERE IsActive = True AND CompanyCode__c = 'T100']);
        
        Map<String,Object> resMap = new Map<String,Object>();
        List<LOGIN_HISTORY> loginHistoryList = new List<LOGIN_HISTORY>();
        try{
            for(LoginHistory lh : objList){
                System.debug('lh : ' + lh);
                System.debug('userMap.size() : ' + userMap.size());
                System.debug('userMap : ' + userMap);
                User user = userMap.get(lh.UserId);
                if(user != null && lh.Application != 'jitterbit'){ // LiginHistory 전송 대상(Company Code = 'T100' & Active = True)
                    LOGIN_HISTORY loginHistory = new LOGIN_HISTORY();
                    loginHistory.NAME = user.Name;
                    loginHistory.EMAIL = user.Email;
                    loginHistory.ROLE = user.UserRole.Name;
                    loginHistory.PROFILE = user.Profile.Name;
                    loginHistory.LOGINTIME = (lh.LoginTime).addHours(9); // 한국시간 기준으로 전송
                    // loginHistory.LOGINTIME = Util_String.convertTimeZone(lh.LoginTime,'GMT'); // 한국시간 기준으로 전송
                    
                    loginHistoryList.add(loginHistory);
                }
            }
            
            System.debug('loginHistoryList.size() : ' + loginHistoryList.size());
            System.debug('loginHistoryList : ' + loginHistoryList);
            if(!loginHistoryList.isEmpty()) resMap = sendLoginHistory(loginHistoryList);
            IF_Log.InterfaceLog ifLog = (IF_Log.InterfaceLog)resMap.get('IF_Log');
            ifLogList.add(ifLog);
        }catch(Exception e){
            System.debug('Error : ' + e.getMessage());
            System.debug('Error StackTrace : ' + e.getStackTraceString());
            System.debug('Error Line : ' + e.getLineNumber());
        }
    }
    
    public void finish(Database.BatchableContext bc) { 
        System.debug('========== finish ==========');
        try{
            IF_Log log = new IF_Log();
            for(IF_Log.InterfaceLog ifLog : ifLogList){
                log.createLog(ifLog);
            }
        }catch(Exception e){
            System.debug('Error : ' + e.getMessage());
            System.debug('Error StackTrace : ' + e.getStackTraceString());
            System.debug('Error Line : ' + e.getLineNumber());
        }
    }
    
    public void execute(SchedulableContext SC){
        DataBase.executeBatch(new Batch_UserLoginHistoryController(), 200);
    }
    
    @AuraEnabled    
    public static Map<String,Object> sendLoginHistory(List<LOGIN_HISTORY> loginHistoryList){
        System.debug('sendLoginHistory loginHistoryList : ' + loginHistoryList);
        IF_Callout call = new IF_Callout(INTERFACE_ID);
        String guId = IF_Util.generateGuid();
        
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
                        sendLoginHistory(loginHistoryList);
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
        @AuraEnabled
        public List<LOGIN_HISTORY> LOGIN_HISTORY; 
    }

    public class LOGIN_HISTORY{
        @AuraEnabled
        public String NAME; // 사용자 이름
        @AuraEnabled
        public String EMAIL; // 사용자 Email 주소
        @AuraEnabled
        public String ROLE; // 역할
        @AuraEnabled
        public String PROFILE; // 프로필
        @AuraEnabled
        public DateTime LOGINTIME; // 접속일시
    }
}