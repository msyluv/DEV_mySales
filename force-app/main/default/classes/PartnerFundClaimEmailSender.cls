/**
* @description       : This class is used for email sending for partner fund claim actions
* @author            : rakshit.s@samsung.com
* @group             : 
* @last modified on  : 07-08-2022
* @last modified by  : ukhyeon.lee@samsung.com
* Modifications Log 
* Ver   Date         Author                  Modification
* 1.0   02-01-2022   rakshit.s@samsung.com   Initial Version
* 1.1   07-07-2022   ukhyeon.lee@samsung.com Edit
**/
global class PartnerFundClaimEmailSender {
    private static String toAddrs='';
    private static String ccAddrs='';    
    private static String bccAddrs='';    

    @future (callout=true)
    public static void triggerEmailSendAction(Id recordId, Id sendId, Set<Id> toIds, Set<Id> ccIds, Set<Id> bccIds, String subject, String contents){
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
        //2. Cc(Optional)
        if(ccIds!=null && !ccIds.isEmpty()){
            List<User> ccUsers = [SELECT Id, Email FROM User WHERE Id =:ccIds];
            for(User u : ccUsers){
                recipientsList.add(new IF_KnoxEmailSendController.Recipients(u.Email, 'CC'));
                ccAddrs+=u.Email+',';
            }   
        }
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
                KnoxEmail__c knoxemail = new KnoxEmail__c(
                        RecordId__c = recordId,
                        ToAddress__c = toAddrs.removeEnd(','),
                        CcAddress__c = ccAddrs.removeEnd(','),
                        BccAddress__c = bccAddrs.removeEnd(','),
                        Name = subject, 
                        HtmlBody__c = contents, 
                        Status__c = 'Send');                
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
}