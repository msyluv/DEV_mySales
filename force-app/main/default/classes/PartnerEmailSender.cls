/**
 * @description       : This class is used for common email sending
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 03-26-2024
 * @last modified by  : divyam.gupta@samsung.com
 * * Modifications Log 
* Ver   Date         Author                           Modification
* 1.0   2022-07-18   ukhyeon.lee@samsung.com          Initial Version
* 1.1   2024-03-26   divyam.gupta@samsung.com         MFA Application to MSP Portal (MySales-444)
**/
global class PartnerEmailSender {
    private static String toAddrs='';
    private static String ccAddrs='';    
    private static String bccAddrs='';
    
    @future (callout=true)
    public static void emailSendAction(Id recordId, Id sendId, Set<Id> toIds, Set<Id> ccIds, Set<Id> bccIds, String subject, String contents){
        //Sender
        List<User> sendUsers = [SELECT Id, Email FROM User WHERE Id =:sendId];
        
        //RecipientsList
        List<IF_KnoxEmailSendController.Recipients> recipientsList = new List<IF_KnoxEmailSendController.Recipients>();
        //1. To 
        List<User> toUsers = [SELECT Id, Email FROM User WHERE Id =:toIds];
        for(User u : toUsers){
            recipientsList.add(new IF_KnoxEmailSendController.Recipients(u.Email, 'TO'));
            toAddrs+=u.Email+',';
        }
        /* TO-BE
        //2. Cc(Optional)
        if(ccIds!=null && !ccIds.isEmpty()){
            List<User> ccUsers = [SELECT Id, Email FROM User WHERE Id =:ccIds];
            for(User u : ccUsers){
                recipientsList.add(new IF_KnoxEmailSendController.Recipients(u.Email, 'CC'));
                ccAddrs+=u.Email+',';
            }   
        }
        */
        //3. Bcc(Optional)
        if(bccIds!=null && !bccIds.isEmpty()){
            List<User> bccUsers = [SELECT Id, Email FROM User WHERE Id =:bccIds];
            for(User u : bccUsers){
                recipientsList.add(new IF_KnoxEmailSendController.Recipients(u.Email, 'BCC'));
                bccAddrs+=u.Email+',';
            }   
        }
        
        IF_KnoxEmailSendController.Sender sender = new IF_KnoxEmailSendController.Sender(sendUsers[0].Email.split('@')[0], sendUsers[0].Email);      
        IF_KnoxEmailSendController.InputClass bodyMap = new IF_KnoxEmailSendController.InputClass();
        bodyMap.subject = subject;
        bodyMap.contents = contents;
        bodyMap.contentType = 'HTML';
        bodyMap.docSecuType = 'PERSONAL';
        bodyMap.sfdcId = recordId;
        bodyMap.recipients = recipientsList;
        bodyMap.sender = sender;
        bodyMap.isMulti = true;        
        
        system.debug('subject : ' + bodyMap.subject);
        system.debug('contents : ' + bodyMap.contents);
        system.debug('sfdcId : ' + bodyMap.sfdcId);
        system.debug('sender : ' + sender);
        system.debug('isMulti : ' + bodyMap.isMulti);
        system.debug(toAddrs);
        system.debug(ccAddrs);
        system.debug(bccAddrs);
        
        Map<String,Object> response = new Map<String, Object>();
        try{
            response = IF_KnoxEmailSendController.send(bodyMap);
            if(Integer.valueof(response.get('StatusCode'))==200){
                KnoxEmail__c knoxemail = new KnoxEmail__c(RecordId__c = recordId, ToAddress__c = toAddrs.removeEnd(','), BccAddress__c = bccAddrs.removeEnd(','), Name = subject, HtmlBody__c = contents, Status__c = 'Send');                
                insert knoxemail;
                system.debug('Send true');
            }  else{
                system.debug('Send false');
            }
        } catch (Exception e){
            system.debug(e.getStackTraceString());
            system.debug('Send error');
        }     
    }    

   // V 1.1 Divyam Gupta
    @future (callout=true)
    public static void partneremailSendAction(Id recordId, Id sendId, Set<Id> toIds, Set<Id> ccIds, Set<Id> bccIds, String subject, String contents){
        //Sender
        List<User> sendUsers = [SELECT Id, Email FROM User WHERE Id =:sendId];
        //MYSALES-444
        List<Attachment> Attachmentlist = [select id,Name, ContentType,Body,ParentId, parent.name from Attachment where parent.name = 'Communities: New Member Welcome Email Kor Custom'];
        //MYSALES-444 End
        //RecipientsList
        List<IF_KnoxEmailSendController.Recipients> recipientsList = new List<IF_KnoxEmailSendController.Recipients>();
        //1. To 
        List<User> toUsers = [SELECT Id, Email FROM User WHERE Id =:toIds];
        for(User u : toUsers){
            recipientsList.add(new IF_KnoxEmailSendController.Recipients(u.Email, 'TO'));
            toAddrs+=u.Email+',';
        }
       
        if(bccIds!=null && !bccIds.isEmpty()){
            List<User> bccUsers = [SELECT Id, Email FROM User WHERE Id =:bccIds];
            for(User u : bccUsers){
                recipientsList.add(new IF_KnoxEmailSendController.Recipients(u.Email, 'BCC'));
                bccAddrs+=u.Email+',';
            }   
        }
        // MYSALES-444 Start
        List<IF_KnoxEmailSendController.Attachments> attachmentsList = new List<IF_KnoxEmailSendController.Attachments>();
        for(Attachment att : Attachmentlist){
            system.debug('file==>'+String.valueOf(att.Name));
            system.debug('boday456===>'+String.valueOf(EncodingUtil.base64Encode(att.Body)));
            IF_KnoxEmailSendController.Attachments attachments = new IF_KnoxEmailSendController.Attachments(String.valueOf(att.ContentType), String.valueOf(att.Name), String.valueOf(EncodingUtil.base64Encode(att.Body)));
            attachmentsList.add(attachments);
        }
        
        //MYSALES-444 End 
        
        IF_KnoxEmailSendController.Sender sender = new IF_KnoxEmailSendController.Sender(sendUsers[0].Email.split('@')[0], sendUsers[0].Email);      
        IF_KnoxEmailSendController.InputClass bodyMap = new IF_KnoxEmailSendController.InputClass();
        bodyMap.subject = subject;
        bodyMap.contents = contents;
        bodyMap.contentType = 'HTML';
        bodyMap.docSecuType = 'PERSONAL';
        bodyMap.sfdcId = recordId;
        bodyMap.recipients = recipientsList;
        bodyMap.sender = sender;
        bodyMap.isMulti = true; 
        bodyMap.attachments = attachmentsList;
        
        system.debug('subject : ' + bodyMap.subject);
        system.debug('contents : ' + bodyMap.contents);
        system.debug('sfdcId : ' + bodyMap.sfdcId);
        system.debug('sender : ' + sender);
        system.debug('isMulti : ' + bodyMap.isMulti);
        system.debug(toAddrs);
        system.debug(ccAddrs);
        system.debug(bccAddrs);
        
        Map<String,Object> response = new Map<String, Object>();
        try{
            response = IF_KnoxEmailSendController.send(bodyMap);
            //system.debug('Responseforknoxemai'+response);
            if(Integer.valueof(response.get('StatusCode'))==200){
                KnoxEmail__c knoxemail = new KnoxEmail__c(RecordId__c = recordId, ToAddress__c = toAddrs.removeEnd(','), BccAddress__c = bccAddrs.removeEnd(','), Name = subject, HtmlBody__c = contents, Status__c = 'Send');                
                insert knoxemail;
                system.debug('Send true');
            }  else{
                system.debug('Send false');
            }
        } catch (Exception e){
            system.debug(e.getStackTraceString());
            system.debug('Send error');
        }     
    }    



    public static Map<String, Object> emailSendActionDirect(Id recordId, Id sendId, Set<Id> toIds, Set<Id> ccIds, Set<Id> bccIds, String subject, String contents){
        Map<String,Object> resultMap = new Map<String,Object>();
        String result = 'S';
        String message = '';
        
        //Sender
        List<User> sendUsers = [SELECT Id, Email FROM User WHERE Id =:sendId];
        
        //RecipientsList
        List<IF_KnoxEmailSendController.Recipients> recipientsList = new List<IF_KnoxEmailSendController.Recipients>();
        //1. To 
        List<User> toUsers = [SELECT Id, Email FROM User WHERE Id =:toIds];
        for(User u : toUsers){
            recipientsList.add(new IF_KnoxEmailSendController.Recipients(u.Email, 'TO'));
            toAddrs+=u.Email+',';
        }
        /* TO-BE
        //2. Cc(Optional)
        if(ccIds!=null && !ccIds.isEmpty()){
            List<User> ccUsers = [SELECT Id, Email FROM User WHERE Id =:ccIds];
            for(User u : ccUsers){
                recipientsList.add(new IF_KnoxEmailSendController.Recipients(u.Email, 'CC'));
                ccAddrs+=u.Email+',';
            }   
        }
        */
        //3. Bcc(Optional)
        if(bccIds!=null && !bccIds.isEmpty()){
            List<User> bccUsers = [SELECT Id, Email FROM User WHERE Id =:bccIds];
            for(User u : bccUsers){
                recipientsList.add(new IF_KnoxEmailSendController.Recipients(u.Email, 'BCC'));
                bccAddrs+=u.Email+',';
            }   
        }
        IF_KnoxEmailSendController.Sender sender = new IF_KnoxEmailSendController.Sender(sendUsers[0].Email.split('@')[0], sendUsers[0].Email);      
        IF_KnoxEmailSendController.InputClass bodyMap = new IF_KnoxEmailSendController.InputClass();
        bodyMap.subject = subject;
        bodyMap.contents = contents;
        bodyMap.contentType = 'HTML';
        bodyMap.docSecuType = 'PERSONAL';
        bodyMap.sfdcId = recordId;
        bodyMap.recipients = recipientsList;
        bodyMap.sender = sender;
        bodyMap.isMulti = true;        
        
        system.debug('subject : ' + bodyMap.subject);
        system.debug('contents : ' + bodyMap.contents);
        system.debug('sfdcId : ' + bodyMap.sfdcId);
        system.debug('sender : ' + sender);
        system.debug('isMulti : ' + bodyMap.isMulti);
        system.debug(toAddrs);
        system.debug(ccAddrs);
        system.debug(bccAddrs);
        
        Map<String,Object> response = new Map<String, Object>();
        try{
            response = IF_KnoxEmailSendController.send(bodyMap);
            if(Integer.valueof(response.get('StatusCode'))==200 && response.get('errorDetail')==null){
                KnoxEmail__c knoxemail = new KnoxEmail__c(RecordId__c = recordId, ToAddress__c = toAddrs.removeEnd(','), BccAddress__c = bccAddrs.removeEnd(','), Name = subject, HtmlBody__c = contents, Status__c = 'Send');                
                insert knoxemail;
                system.debug('Send true');
            }  else{
                result = 'E';
                system.debug('Send false');
            }
        } catch (Exception e){
            result='E';
            system.debug(e.getStackTraceString());
            system.debug('Send error');
        }     

        resultMap.put('RESULT', result);
        resultMap.put('MESSAGE', message);

        return resultMap;
    }    

}