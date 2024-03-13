global class KnoxCalenderApi_Check {
    global static void getCalenderData(){
   String dash_url = '/pims/calendar/api/v2.0/calendars?userId=saurav.k';
        HttpRequest request = new HttpRequest();
        request.setHeader('System-ID','KCC60REST00209');
        request.setHeader('Authorization','Bearer 5729957d-5e08-3054-b1ee-f7fbfd6b8609 ');         
        request.setTimeout(120000);
        request.setEndpoint('https://openapi.stage.samsung.net'+ dash_url);
        request.setMethod('GET'); 
        system.debug('request:'+request);
        HttpResponse res = new Http().send(request);
        system.debug('RES:'+res);
        string responseValue = '';
        responseValue = res.getBody();
        system.debug('Response Body for File: ' + responseValue);
        
        if (res.getStatusCode() == 200)
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'saurav.k@partner.samsung.com'};//,'saurav.k@partner.samsung.com','divyam.gupta@samsung.com','oldman.sea@samsung.com','boram85.jung@samsung.com'}; //'rakshit.s@samsung.com'
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('Support');
            mail.setSubject('Calender JSON Data');
            mail.setBccSender(false); 
            mail.setUseSignature(false);
            mail.setPlainTextBody(responseValue);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }
        else
        {System.debug('Failed to retrieve the Report Json data Error: ' + res.getBody());}
       
   }   
}