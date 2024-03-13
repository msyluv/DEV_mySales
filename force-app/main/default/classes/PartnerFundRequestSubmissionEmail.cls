global class PartnerFundRequestSubmissionEmail {

    private static final String DEFAULT_EMAIL_SENDER = 'cloudpartner.adm@samsung.com';
    private static final String SANDBOX_EMAIL_SENDER = 'gitesh.s@stage.samsung.com';

    //@InvocableMethod
    @future(callout=true)
    public static void emailSubmittedForApproval(Id recordId, String templateName, String email) {
        
        EmailTemplate emailTemplate = [SELECT Id, Name, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName =:templateName LIMIT 1];
        String contents = String.valueOf(emailTemplate.htmlValue);

        //RecipientsList
        List<IF_KnoxEmailSendController.Recipients> recipientsList = new List<IF_KnoxEmailSendController.Recipients>();

        if(templateName == 'Partner_Fund_Request_Submission_Email') {
            contents = contents.replace('{!PartnerFundRequest.Link}', 'https://sdssfa--qa.lightning.force.com/lightning/r/PartnerFundRequest/'+recordId+'/view');
            recipientsList.add(new IF_KnoxEmailSendController.Recipients('cloudpartner.adm@samsung.com', 'TO'));
            recipientsList.add(new IF_KnoxEmailSendController.Recipients('gitesh.s@stage.samsung.com', 'BCC'));
        }
        else {
            contents = contents.replace('{!PartnerFundRequest.Link}', 'https://qa-sds-msp.cs113.force.com/s/detail/'+recordId);
            recipientsList.add(new IF_KnoxEmailSendController.Recipients(email, 'TO'));
            recipientsList.add(new IF_KnoxEmailSendController.Recipients('cloudpartner.mkt@samsung.com', 'BCC'));
            recipientsList.add(new IF_KnoxEmailSendController.Recipients('gitesh.s@stage.samsung.com', 'CC'));
        }
        
        //Email Sender
        String emailSender = DEFAULT_EMAIL_SENDER;
        List<Network> n = [SELECT Id, EmailSenderAddress FROM Network WHERE Status = 'Live' ORDER BY lastModifiedDate DESC LIMIT 1];
        if(!n.isEmpty()){
            emailSender = n[0].EmailSenderAddress;
        }
        if([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox){
            emailSender = SANDBOX_EMAIL_SENDER;
        }
        
        IF_KnoxEmailSendController.Sender sender = new IF_KnoxEmailSendController.Sender(emailSender.split('@')[0], emailSender);
        
        IF_KnoxEmailSendController.InputClass bodyMap = new IF_KnoxEmailSendController.InputClass();
        bodyMap.subject = emailTemplate.Subject;
        bodyMap.contents = contents;
        bodyMap.contentType = 'HTML';
        bodyMap.docSecuType = 'PERSONAL';
        //bodyMap.sfdcId = user.Id;
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
                //KnoxEmail__c knoxemail = new KnoxEmail__c(RecordId__c = user.Id, Sender__c = n[0].Id, ToAddress__c = user.email, Name = EmailTemplate.Subject, HtmlBody__c = contents, MailId__c = user.email , Status__c = 'Send');
                KnoxEmail__c knoxemail = new KnoxEmail__c(Sender__c = n[0].Id, Name = EmailTemplate.Subject, HtmlBody__c = contents, Status__c = 'Send');
                insert knoxemail;
                system.debug('Send true');
            }
            system.debug('Send false');
        } catch (Exception e){
            system.debug('Send error');
        }
    }
}