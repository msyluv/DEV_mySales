/**
* @description       : This is a batch apex that runs every day and identify the user who have not logged in for 11 months and notify them that their account would be deleted after 1 more month and then deletes it.
* @author            : rakshit.s@samsung.com
* @group             : 
* @last modified on  : 06-01-2023
* @last modified by  : akash.g@samsung.com
* Modifications Log 
* Ver   Date         Author                  Modification
* 1.0   03-11-2022   rakshit.s@samsung.com   Initial Version
* 1.1   06-01-2023   akash.g@samsung.com     Add If-Log(MYSALES-105)
*/
global class DeleteAndNotifyUserBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    global FINAL String strQuery;
    global List<String> partnerEnrollmentIds; 
    global List<String> partnerEnrollmentAggIds; 
    global List<String> partnerSignupIds;
    global List<String> partnerSignupAggIds;
    global DeleteAndNotifyUserBatch() { 
        this.strQuery = getBatchQuery();
        this.partnerEnrollmentIds = new List<String>();
        this.partnerEnrollmentAggIds = new List<String>();
        this.partnerSignupIds = new List<String>();
        this.partnerSignupAggIds = new List<String>();
        
    }
    global static final String INTERFACE_ID = 'BATCH-DELETENOTI';
    global static final String APEX_CLASS   = 'DeleteAndNotifyUserBatch'; 
    global static final String METHOD_NAME  = 'Batch';
	global static String guId = IF_Util.generateGuid();
    //Returns the Query String to Batch constructor to fetch right records.
    private String getBatchQuery() {
        
        //String strQuery ='select id,Email,firstname, lastname,LastLoginDate,Last_Notification_Date__c from user where Id= \'0050w000003BXh8AAG\''; 
        String strQuery = 'select id,firstname, email, lastname,LastLoginDate,Last_Notification_Date__c, Date_Last_Login__c, Username from user where username like \'%.sdspartner\' and isActive=true';
        //select id,name from user where profile.name=\'Partner Community Member\' and isActive=true
        return strQuery;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        
        batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + ' ####################');
        Database.QueryLocator returnScope;
        returnScope = DataBase.getQueryLocator(strQuery);
        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');
        ifStartLog.createLog(batchStartLog);
        System.debug('###################################');
        System.debug(returnScope);
        System.debug('###################################');
        
        return returnScope;
    }
    
    
    global void execute(Database.BatchableContext BC, List<User> userList) {
        Integer noOfMonths;
        String communityURL = [SELECT id, name FROM Network where name='Delivery'].id;
        List < Messaging.SingleEmailMessage > mailList = new List < Messaging.SingleEmailMessage > ();
        List<String> emailSet = new List<String>();
        List<User> updateUserList = new List<User>();
        // List<String> userName = new List<String>();
        
        for(User activeUsers : userList){
            Date userLoginDate;
            //userName.add(activeUsers.username);
            //system.debug( 'before userLoginDate : ' + userLoginDate);
            if(Test.isRunningTest() || activeUsers.Date_Last_Login__c != null){
                system.debug( 'test env : ' + activeUsers.Date_Last_Login__c );
                if(activeUsers.Date_Last_Login__c!=null){
                    userLoginDate = Date.newInstance(activeUsers.Date_Last_Login__c.year(), activeUsers.Date_Last_Login__c.month(), activeUsers.Date_Last_Login__c.day());
                }
                
                else{
                    userLoginDate = Date.newInstance(2021, 04, 17);
                }
                
            }
            else{
                //system.debug( 'not test env : ' + activeUsers.LastLoginDate );
                if(activeUsers.LastLoginDate!=null){
                    userLoginDate = Date.newInstance(activeUsers.LastLoginDate.year(),activeUsers.LastLoginDate.month(),activeUsers.LastLoginDate.day());
                }
                
            }
            //system.debug( 'userLoginDate is ' + userLoginDate );
            
            if(userLoginDate !=null){
                //if(activeUsers.LastLoginDate !=null){
                noOfMonths = numberOfMonths(Date.valueOf(userLoginDate) , Date.today());
                //noOfMonths = numberOfMonths(Date.valueOf(activeUsers.LastLoginDate) , Date.today());
                //noOfMonths = 11;
                system.debug( 'noOfMonths is ' + noOfMonths );
            }
            
            if( (noOfMonths == 11 && activeUsers.Last_Notification_Date__c == null) || (noOfMonths == 11 && date.valueOf(activeUsers.Last_Notification_Date__c).daysBetween( Date.today() ) >= 365 ) ){
                
                List < String > toAddresses = new List < String > ();
                emailSet.add(activeUsers.email);
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                mail.setReplyTo('cloudpartner.sds@samsung.com');
                mail.setSubject('[SAMSUNG SDS Cloud Partner Network]장기 미사용 고객정보 파기에 대한 안내');
                // Specify the name used as the display name.
                mail.setSenderDisplayName('Cloud Partner Support');
                mail.saveAsActivity = false;
                
                
                mail.setHtmlBody(
                    activeUsers.LastName + ' ' + activeUsers.FirstName + ' 고객님, 안녕하세요.<br/>'
                    +'SAMSUNG SDS Cloud Partner Network 입니다.<br/>'
                    +'<br/><br/>'
                    +'안전한 개인정보 관리를 위하여 SAMSUNG SDS Cloud Partner Network 홈페이지에<br/>'
                    +'1년 이상 로그인하지 않은 회원에 대하여 회원탈퇴 처리 및 개인정보 파기<br/>'
                    +'(홈페이지 회원가입 시 입력한 정보)가 예정되어 있음을 안내해 드립니다.<br/>'
                    +'<br/><br/>'
                    +activeUsers.LastName + ' ' + activeUsers.FirstName + ' 고객님의 ID : '+activeUsers.Username+'<br/>'
                    +'<br/><br/>'
                    +'본 메일을 수신하신 회원님께서는 회원탈퇴 처리 대상에 해당되며,<br/>'
                    +'회원탈퇴를 원치 않는 경우에는 '  + (System.Today().addDays(30).year())+'년' + System.Today().addDays(30).month() +'월' +  System.today().addDays(30).day() + '일 까지<br/>'
                    +'SAMSUNG SDS Cloud Partner Network 홈페이지('+Network.getLoginUrl(communityURL)+')<br/>'
                    +'에 로그인 해주시기 바랍니다.<br/>'
                    +'<br/><br/>'
                    +'회원탈퇴 처리예정일 : '+(System.Today().addDays(30).year())+'년' + System.Today().addDays(30).month() +'월' +  System.today().addDays(30).day()+'일<br/>'
                    +'<br/><br/>'
                    +'관련근거 : 개인정보보호법 제39조 6 (개인정보의 파기에 관한 특례)<br/>'
                    +'① 정보통신서비스 제공자등은 정보통신서비스를 1년의 기간 동안 이용하지 아니하는 이용자의<br/>'
                    +'  개인정보를 보호하기 위하여 대통령령으로 정하는 바에 따라 개인정보의 파기 등 필요한 조치를 취하여야 한다.<br/>'
                    +'  다만, 그 기간에 대하여 다른 법령 또는 이용자의 요청에 따라 달리 정한 경우에는 그에 따른다.<br/>'
                    +'② 정보통신서비스 제공자등은 제1항의 기간 만료 30일 전까지 개인정보가 파기되는 사실,<br/>'
                    +'  기간 만료일 및 파기되는 개인정보의 항목 등 대통령령으로 정하는 사항을 전자우편 등<br/>'
                    +'  대통령령으로 정하는 방법으로 이용자에게 알려야 한다.'
                );
                mail.setTargetObjectId(activeUsers.Id);
                
                
                mailList.add(mail);
                activeUsers.Last_Notification_Date__c = Date.today();
                updateUserList.add(activeUsers);
                
            }
            
            else if(noOfMonths > 11 ){
                activeUsers.isActive = false;
                updateUserList.add(activeUsers);
                
                
                List<Partner_Enrollment_Request__c> enrollmentsToDel = new List<Partner_Enrollment_Request__c>([select id , (select id from Partner_Enrollment_T_C_Agreements__r where isAgree__c = true) from Partner_Enrollment_Request__c where Partner_ID__c =: activeUsers.username]);
                List<Partner_Signup_Request__c> signuPToDelete = new List<Partner_Signup_Request__c>([Select id , (select id from Partner_Signup_T_C_Agreements__r where isAgree__c = true) from Partner_Signup_Request__c where Partner_ID__c =: activeUsers.username]);
                for(Partner_Enrollment_Request__c enn : enrollmentsToDel){
                    partnerEnrollmentIds.add(enn.id);
                    for(Partner_Enrollment_T_C_Agreement__c agg : enn.Partner_Enrollment_T_C_Agreements__r ){
                        
                        partnerEnrollmentAggIds.add(agg.id);
                    }
                }
                
                for(Partner_Signup_Request__c signupReq : signuPToDelete){
                    partnerSignupIds.add(signupReq.id);
                    for(Partner_Signup_T_C_Agreement__c sgg : signupReq.Partner_Signup_T_C_Agreements__r ){
                        
                        partnerSignupAggIds.add(sgg.id);
                    }
                }
                
                
            }
            //system.debug( 'Output is ' + noOfMonths );
            
            
        }
        
        // Send the email you have created.
        Messaging.sendEmail(mailList);
        update updateUserList;
        
    }
    
    
    global void finish(Database.BatchableContext BC) { 
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);
        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');
        
        List<Partner_Enrollment_Request__c> enrollmentsToDel = new List<Partner_Enrollment_Request__c>([select id  from Partner_Enrollment_Request__c where Id =: partnerEnrollmentIds]);
        List<Partner_Signup_Request__c> signuPToDelete = new List<Partner_Signup_Request__c>([Select id from Partner_Signup_Request__c where Id =: partnerSignupIds]);
        List<Partner_Enrollment_T_C_Agreement__c> agToDelete = new List<Partner_Enrollment_T_C_Agreement__c>([select id from Partner_Enrollment_T_C_Agreement__c where Id =: partnerEnrollmentAggIds]);
        List<Partner_Signup_T_C_Agreement__c> signupAggToDelete = new List<Partner_Signup_T_C_Agreement__c>([select id from Partner_Signup_T_C_Agreement__c where Id =: partnerSignupAggIds]);
        
        
        If(enrollmentsToDel.size()>0 && enrollmentsToDel!=null) delete enrollmentsToDel;
        If(signuPToDelete.size()>0 && signuPToDelete!=null) delete signuPToDelete;
        If(agToDelete.size()>0 && agToDelete!=null) delete agToDelete;
        If(signupAggToDelete.size()>0 && enrollmentsToDel!=null) delete signupAggToDelete;
        ifFinishLog.createLog(batchFinishLog);
    }
    
    global static integer numberOfMonths(Date firstDate , Date LastDate){
        
        Date a = firstDate;
        Date b = LastDate;
        System.debug('TEST firstDate :'+firstDate);
        System.debug('TEST LastDate :'+LastDate);
        System.debug('TEST Today :'+String.valueOf(System.Today()).split('-'));
        Integer monthDiff = a.monthsBetween(b);
        
        
        return monthDiff;
    }
    
    //cron expression to run from dev console
    /*EmailNotificationBatchScheduler testobj = new EmailNotificationBatchScheduler();
String cronexpression = '0 0 0 1 3 ?';
System.schedule('EmailNotificationJob', cronexpression, testobj);    */
    
    
}