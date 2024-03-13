/**
* @description       : Schedulable class for BOReport 
* @author            : d.ashish@samsung.com
* @group             : 
* @last modified on  : 2023-07-06
* @last modified by  : d.ashish@samsung.com
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2023-07-06   d.ashish@samsung.com   Initial Version
**/

public class BOReportScheduler  implements schedulable,Database.StateFul,Database.AllowsCallouts{
    public void execute(SchedulableContext cx){
        
        sendMyMail('BO_REPORT_SDSAE',system.label.BO_REPORT_SDSAE);
        sendMyMail('BO_REPORT_SDSEG',system.label.BO_REPORT_SDSEG);
        sendMyMail('BO_REPORT_SDSI_CNL',system.label.BO_REPORT_SDSI_CNL);
        sendMyMail('BO_REPORT_SDSI_NDL',system.label.BO_REPORT_SDSI_NDL);
        sendMyMail('BO_REPORT_SDSTR',system.label.BO_REPORT_SDSTR);
        sendMyMail('BO_REPORT_SDSZA',system.label.BO_REPORT_SDSZA);
        
    }
    public static void sendMyMail(String eTempName , String emailSet){
        system.debug('eTempName'+eTempName);
        EmailTemplate temp = [SELECT Id, Name, DeveloperName, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName =:eTempName LIMIT 1];
        // Here we will build the single email message
        //Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'invalid@emailaddr.es'};
            mail.setToAddresses(toAddresses);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(false);
        mail.setSenderDisplayName('MMPT');
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setTemplateId(temp.Id);  
        Savepoint sp = Database.setSavepoint();
        try{
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }
        catch(exception e){
            
        }
        finally{
        Database.rollback(sp);
        String mailTextBody = mail.getPlainTextBody();
        String mailHtmlBody = mail.getHTMLBody();
        String mailSubject = mail.getSubject();
        system.debug('temp sub::'+temp.Subject);
        //Email : Template조회
        //EmailTemplate emailTemplate = getEmailTemplate('SalesLead_Owner_Change_Email');
        List<KnoxEmail__c> KnoxEmailList = new List<KnoxEmail__c>();
        
        String SENDER_EMAIL = 'mysales@samsung.com';
        
        //String systemEmail = '';
        //String systemId = '';
        //String LinkAddress = '';
        //QA
        Boolean isSandbox = Utils.getIsSandbox();
        /*Employee__c senderEmployee = Utils.getLoginEmployeeData(UserInfo.getUserId());
        senderEmployee.EvMailAddr__c = 'chae_ho.yang@stage.samsung.com';
        if(!isSandbox){
            senderEmployee.EvMailAddr__c =   'mysales@samsung.com';
        }
        */
        
        Employee__c senderEmployee;
        	if(isSandbox){
            //systemEmail = 'oldman.sea@stage.samsung.com';
            //systemId    = 'a091s0000035Ax2AAE';
            //LinkAddress = 'https://sdssfa--qa.lightning.force.com/lightning/';
            senderEmployee = Utils.getLoginEmployeeData('0051s000001E9SuAAK');
            senderEmployee.EvMailAddr__c = 'chae_ho.yang@stage.samsung.com';
            
        }
        //REAL
        else{
            //systemEmail = 'mysales@samsung.com';
            //LinkAddress = 'https://sdssfa.lightning.force.com/';
            
            List<User> userList = [SELECT Id, Name From User WHERE Username = :SENDER_EMAIL];
            if(userList.size() > 0) senderEmployee = Utils.getLoginEmployeeData(userList.get(0).Id);
            
        }
        
        
        //------------------------------------------------------------------------------------------
        //Email : Knox mail 송신자 정보 처리
        IF_KnoxEmailSendController.Sender sender;
        
        if(test.isRunningTest()){
            sender = new IF_KnoxEmailSendController.Sender('mysales', 'mysales@samsung.com');
        }
        else{
            sender = new IF_KnoxEmailSendController.Sender(senderEmployee.EvMailAddr__c.split('@')[0], senderEmployee.EvMailAddr__c);
        }
        
        //------------------------------------------------------------------------------------------
        //Email : Knox mail 수신자 정보 처리
        List<IF_KnoxEmailSendController.Recipients> recipientsList = new List<IF_KnoxEmailSendController.Recipients>();
        List<String> toList = new List<String>();
        for(String emailString : emailSet.split(',')){
            toList.add(emailString);
            recipientsList.add(new IF_KnoxEmailSendController.Recipients(emailString, 'TO'));
            
        }
        //------------------------------------------------------------------------------------------
        //Email : Knox mail 전송처리
        IF_KnoxEmailSendController.InputClass bodyMap = new IF_KnoxEmailSendController.InputClass();
        bodyMap.subject = mailSubject;//subject;
        bodyMap.contents = mailHtmlBody;//body;
        bodyMap.contentType = 'HTML';
        bodyMap.docSecuType = 'PERSONAL';
        bodyMap.sfdcId = Userinfo.getUserId();//sales.Id;
        bodyMap.recipients = recipientsList;
        bodyMap.sender = sender;
        bodyMap.isMulti = true;
        Map<String,Object> resMap = new Map<String,Object>();
        Map<String,Object> response = new Map<String, Object>();
        
        IF_KnoxEmailSendController.send2(JSON.serialize(bodyMap));
        
        KnoxEmail__c knoxemail = new KnoxEmail__c(
            RecordId__c = temp.Id
            //, Sender__c = 'a091s0000035Ax2AAE'
            , ToAddress__c = String.join(toList, ',')
            , Name = mailsubject
            , HtmlBody__c = mailHtmlbody
            , MailId__c = senderEmployee.EvMailAddr__c
            , Status__c = 'Send'
        );
        knoxemailList.add(knoxemail);
        
        
        //------------------------------------------------------------------------------------------
        //end of for
        
        insert knoxemailList;
        }
    }
}