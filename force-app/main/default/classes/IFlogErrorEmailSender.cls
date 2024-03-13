global class IFlogErrorEmailSender {
    
   @future (callout=true)
    public static void SendIFerrorEmail(Id recordid,Id sendId,String contents,String Subject){
        
                     List<User> sendUsers = [SELECT Id,email FROM User WHERE Email= 'chae_ho.yang@stage.samsung.com' LIMIT 1];

                     String toAddrs='';

         List<IF_KnoxEmailSendController.Recipients> recipientsList = new List<IF_KnoxEmailSendController.Recipients>();
                 List<String> Emails = new List<String>{'Divyam.gupta@stage.samsung.com','Kajal.c@stage.samsung.com'};
        for(String e : Emails){
            recipientsList.add(new IF_KnoxEmailSendController.Recipients(e, 'TO'));
            toAddrs+=e+',';
        }
      IF_KnoxEmailSendController.Sender sender = new IF_KnoxEmailSendController.Sender(sendUsers[0].Email.split('@')[0], sendUsers[0].Email);      
        IF_KnoxEmailSendController.InputClass bodyMap = new IF_KnoxEmailSendController.InputClass();
        bodyMap.subject = Subject;
        bodyMap.contents = contents;
        bodyMap.contentType = 'HTML';
        bodyMap.docSecuType = 'PERSONAL';
        bodyMap.sfdcId = recordid;
        bodyMap.recipients = recipientsList;
        bodyMap.sender = sender;
        bodyMap.isMulti = true; 
        system.debug('subject : ' + bodyMap.subject);
        system.debug('contents : ' + bodyMap.contents);
        system.debug('sender : ' + sender);
        system.debug('isMulti : ' + bodyMap.isMulti);
        system.debug(toAddrs);

            //    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
      /*  if(ToID != null && TempID != null){
            semail.setTargetObjectId(ToID);
            semail.setSaveAsActivity(false);
            semail.setTemplateId(TempID);
            if(fromAddressID != null){
            	semail.setOrgWideEmailAddressId(fromAddressID);     
            }
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
         } */
             Map<String,Object> response = new Map<String, Object>();
        try{
            response = IF_KnoxEmailSendController.send(bodyMap);
            //system.debug('Responseforknoxemai'+response);
            if(Integer.valueof(response.get('StatusCode'))==200){
                KnoxEmail__c knoxemail = new KnoxEmail__c(RecordId__c = recordid, ToAddress__c = toAddrs.removeEnd(','),Name = Subject, HtmlBody__c = contents, Status__c = 'Send');                
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