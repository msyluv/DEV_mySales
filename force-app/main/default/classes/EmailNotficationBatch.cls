/**
* @description       : This is a batch apex that runs once a year to send notification email to all activer partner members profile users
* @author            : rakshit.s@samsung.com
* @group             : 
* @last modified on  : 06-01-2023
* @last modified by  : akash.g@samsung.com
* Modifications Log 
* Ver   Date         Author                  Modification
* 1.0   03-09-2022   rakshit.s@samsung.com   Initial Version
* 1.1   06-01-2023   akash.g@samsung.com     Add If-Log(MYSALES-105)
*/

global class EmailNotficationBatch  implements Database.Batchable<sObject>, Database.Stateful {
    global static final String INTERFACE_ID = 'BATCH-PARTNERNOTI';
    global static final String APEX_CLASS   = 'EmailNotficationBatch'; 
    global static final String METHOD_NAME  = 'Batch';
	global static String guId = IF_Util.generateGuid();

    global FINAL String strQuery;
    
    global EmailNotficationBatch() { 
        this.strQuery = getBatchQuery();
    }
    
    //Returns the Query String to Batch constructor to fetch right records.
    private String getBatchQuery() {
        
                //String strQuery ='select id,Email,firstname, lastname,LastLoginDate,Last_Notification_Date__c from user where Id= \'0050w000003BXh8AAG\'';
        String strQuery = 'select id,email from user where username like \'%.sdspartner\' and isActive=true';
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
        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 시작' + ' ####################');
        ifExcuteLog.addLog( '###################['+userList.size()+']################');
        
        List < Messaging.SingleEmailMessage > mailList = new List < Messaging.SingleEmailMessage > ();
        List<String> emailSet = new List<String>();
        for(User activeUsers : userList){
            List < String > toAddresses = new List < String > ();
            emailSet.add(activeUsers.email);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //mail.setToAddresses(toAddresses);
            // Specify the address used when the recipients reply to the email. 
            mail.setReplyTo('cloudpartner.sds@samsung.com');
            // Specify the name used as the display name.
            mail.setSenderDisplayName('Cloud Partner Support');
            mail.saveAsActivity = false;
            // Specify the subject line for your email address.
            EmailTemplate emailTemplate =[Select name, Id,Subject,Description, HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName ='Active_Partner_User_Yearly_Notification'];
            //Get templete id for set the templete.
            mail.setTemplateID(emailTemplate.Id);
          //mail.setHtmlBody('SAMSUNG Cloud Portal</br> 회원님의 개인정보가 휴면처리 됩니다.</br>'+'</br>' +'안녕하세요'+ activeUsers.LastName +' ' + activeUsers.FirstName + '회원님,</br></br> 개인정보보호법 제39조 6 (개인정보의 파기에 관한 특례)에 따라</br> 최근 1년 동안 로그인 및 서비스 이용 기록이 없는 휴면 아이디는 안전한 개인정보 관리를 위하여</br></br>개인정보를 파기 또는 분리 보관해야 합니다.</br></br>회원님은 최근 1년간 로그인 및 서비스 이용기록이 없는 휴면 아이디로</br></br>' + (System.Today().year()+1)+'년' + System.Today().month()+'월' +  System.today().day() + '일 이전까지 로그인 및 서비스 이용을 하지 않으시면</br></br>SAMSUNG Cloud Portal에 보관된 회원님의 개인정보가 분리보관 등 조치될 예정이므로</br></br>기존과 동일하게 서비스 이용을 하실 수 없습니다.</br></br>동일한 서비스 이용을 원하시면' + (System.Today().year()+1)+'년' + System.Today().month()+'월' +  System.today().day() + '이전까지</br></br>SAMSUNG Cloud Portal에 로그인하시어 서비스를 이용해 주세요.</br></br>※접속 URL : {!ConnectURL}</br>개인정보 분리보관일 :' + (System.Today().year()+1)+'년' + System.Today().month() +'월' +  System.today().day() + '</br>분리보관 개인정보 : 아이디, 비밀번호, 이름, 생년월일, 성별, 이메일, 휴대폰 번호, 주소');
            mail.setTargetObjectId(activeUsers.Id);
            mailList.add(mail);
        }
        //create Interface Log
        batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', '', 0);
        ifExcutelog.createLog(batchExcuteLog);
        
        // Send the email you have created.
        Messaging.sendEmail(mailList);
        
    }
    
    global void finish(Database.BatchableContext BC) { 
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);
        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');
        ifFinishLog.createLog(batchFinishLog);
    }
    
   
    
    //cron expression to run from dev console
    /*EmailNotificationBatchScheduler testobj = new EmailNotificationBatchScheduler();
String cronexpression = '0 0 0 1 3 ?';
System.schedule('EmailNotificationJob', cronexpression, testobj);    */
    
}