/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 05-16-2022
 * @last modified by  : ukhyeon.lee@samsung.com
**/
global without sharing class PartnerWelcomeEmailSender {

    private static final String WELCOME_EMAIL_TEMPLATE = 'Communities_New_Member_Welcome_Email_Kor_Custom';
    private static final String DEFAULT_EMAIL_SENDER = 'cloudpartner.adm@samsung.com';
    
    @future(callout=true)
    public static void sendWelcomeEmail(Id id){
        User user = [SELECT Id, Name, FirstName, Username, Email FROM User WHERE ID=:id];

        //Email Template
        EmailTemplate emailTemplate = [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName =:WELCOME_EMAIL_TEMPLATE LIMIT 1];
        String contents = String.valueOf(emailTemplate.htmlValue);

        contents = contents.replace('{!Receiving_User.Name}',  user.Name);
        contents = contents.replace('{!Receiving_User.Username}', user.Username);
        contents = contents.replace('{!Organization.Name}', UserInfo.getOrganizationName());
        
        
        //RecipientsList
        List<IF_KnoxEmailSendController.Recipients> recipientsList = new List<IF_KnoxEmailSendController.Recipients>();
        recipientsList.add(new IF_KnoxEmailSendController.Recipients(user.Email, 'TO'));
        
        //Email Sender
        String emailSender = DEFAULT_EMAIL_SENDER;
        List<Network> n = [SELECT Id, EmailSenderAddress FROM Network WHERE Status = 'Live' ORDER BY lastModifiedDate DESC LIMIT 1];
        if(!n.isEmpty()){
            emailSender = n[0].EmailSenderAddress;
        }
        if([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox){
            emailSender = 'ukhyeon.lee@stage.samsung.com';
        }
        
        IF_KnoxEmailSendController.Sender sender = new IF_KnoxEmailSendController.Sender(emailSender.split('@')[0], emailSender);
        
        IF_KnoxEmailSendController.InputClass bodyMap = new IF_KnoxEmailSendController.InputClass();
        bodyMap.subject = emailTemplate.Subject;
        bodyMap.contents = contents;
        bodyMap.contentType = 'HTML';
        bodyMap.docSecuType = 'PERSONAL';
        bodyMap.sfdcId = user.Id;
        bodyMap.recipients = recipientsList;
        bodyMap.sender = sender;
        bodyMap.isMulti = true;

        system.debug('subject : ' + bodyMap.subject);
        system.debug('contents : ' + bodyMap.contents);
        system.debug('sfdcId : ' + bodyMap.sfdcId);
        system.debug('recipients : ' + user.email);
        system.debug('sender : ' + sender);
        system.debug('isMulti : ' + bodyMap.isMulti);
        
        Map<String,Object> response = new Map<String, Object>();
        try{
            response = IF_KnoxEmailSendController.send(bodyMap);
            if(Integer.valueof(response.get('StatusCode'))==200){
                KnoxEmail__c knoxemail = new KnoxEmail__c(RecordId__c = user.Id, Sender__c = n[0].Id, ToAddress__c = user.email, Name = EmailTemplate.Subject, HtmlBody__c = contents, MailId__c = user.email , Status__c = 'Send');
                insert knoxemail;
                system.debug('Send true');
            }
            system.debug('Send false');
        } catch (Exception e){
            system.debug('Send error');
        }
    }
}