Global class IF_SendDashboard{
    
    global static void SendDashboard(){
        
        String dash_url = '/services/data/v31.0/analytics/dashboards/01Z1s0000000OdxEAE';
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        request.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + dash_url);
        request.setMethod('GET');
        
        HttpResponse res = new Http().send(request);
        system.debug('RES:'+res);
        string responseValue = '';
        responseValue = res.getBody();
        system.debug('Response Body for File: ' + responseValue);
     
        if (res.getStatusCode() == 200)
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'akash.g@samsung.com'}; 
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('Support');
            mail.setSubject('Invoice');
            mail.setBccSender(false); 
            mail.setUseSignature(false);
			mail.setPlainTextBody(responseValue);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }
        else
        {System.debug('Failed to retrieve the dashboard image. Error: ' + res.getBody());}
        
        /*Attachment n = new Attachment();
        //You will want to tie your attachment to some type of custom or standard object
        //n.ParentId = myAccount.Id;
        n.Name = 'myImage.png';
        n.Body = image;
        //If we were saving a PDF as an attachment the ContentType would be 'pdf'
        n.contentType = 'image/png';
        insert n;*/
    }
}