global class ReportDashboardNew {
    global static void getRecentListOfDashBoard() {        
        String dash_url = '/services/data/v56.0/analytics/dashboards';
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
                mail.setToAddresses(toAddresses);//ReportDashboardNew.sendDashboardImageByEmail();
            mail.setSenderDisplayName('Support');
            mail.setSubject('Invoice');
            mail.setBccSender(false); 
            mail.setUseSignature(false);
            mail.setPlainTextBody(responseValue);
            //mail.setHtmlBody('<image src= '+ Recimage+ '/>'); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }
        else
        {System.debug('Failed to retrieve the dashboard image. Error: ' + res.getBody());}
    }
    global static void getDashboardID(){
        
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
    }
    global static void getDashboardStatus(){
        
        String dash_url = '/services/data/v31.0/analytics/dashboards/01Z1s0000000OdxEAE/status';
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
            String[] toAddresses = new String[] {'saurav.k@partner.samsung.com'}; 
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
    }  
    global static void GetDashboardMetadata(){
        
        String dash_url = '/services/data/v37.0/analytics/dashboards/01Z1s0000000OdxEAE/describe';
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
            String[] toAddresses = new String[] {'saurav.k@partner.samsung.com'}; 
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
    }
    global static void deleteDashboard(){
        
        String dash_url = '/services/data/v34.0/analytics/dashboards/01Z1s0000000OdxEAE';
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        request.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + dash_url);
        request.setMethod('DELETE');
        
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
    } 
    global static void ReportDashboardExcel(){     
        String reportId = '00O1s000000HqrjEAC';
		String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
		String apiEndpoint = '/services/data/v56.0/analytics/reports/';
		String apiUrl = baseUrl + apiEndpoint + reportId;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiUrl);
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        request.setHeader('Accept', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        request.setMethod('GET');
        HttpResponse res = new Http().send(request);
        system.debug('RES:'+res);
        string responseValue = '';
        responseValue = res.getBody();
        system.debug('Response Body for File: ' + responseValue);
        
        if (res.getStatusCode() == 200)
        {
            Blob excelData = res.getBodyAsBlob();            
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('ExcelData.csv');
            attachment.setBody(excelData);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Report Excel');
            email.setPlainTextBody('Please find the attached Report Excel.');
            email.setToAddresses(new String[]{'saurav.k@partner.samsung.com','oldman.sea@samsung.com','akash.g@samsung.com'});
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});            
            Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        }
        else
        {System.debug('Failed to retrieve the dashboard image. Error: ' + res.getBody());}
    } 
    
    global static void getDashBoardasPNG() {        
        String dash_url = '/analytics/download/lightning-dashboard/01Z1s0000000OdxEAE.png';
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
            String[] toAddresses = new String[] {'vikrantkumarsingh007@gmail.com','vikrant.ks@samsung.com'}; 
            mail.setToAddresses(toAddresses);//ReportDashboardNew.sendDashboardImageByEmail();
            mail.setSenderDisplayName('Support');
            mail.setSubject('Invoice');
            mail.setBccSender(false); 
            mail.setUseSignature(false);
            mail.setPlainTextBody(responseValue);
            mail.setHtmlBody(responseValue); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }
        else
        {System.debug('Failed to retrieve the dashboard image. Error: ' + res.getBody());}
    }
    global static void RefreshDashboard(){
        
        String dash_url = '/services/data/v31.0/analytics/dashboards/01Z1s0000000OdxEAE';
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        request.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + dash_url);
        request.setMethod('PUT');
        //request.setBody('{"statusUrl" : "/services/data/v31.0/analytics/dashboards/01Z1s0000000OdxEAE/status"}');
        
        HttpResponse res = new Http().send(request);
        system.debug('RES:'+res);
        string responseValue = '';
        responseValue = res.getBody();
        system.debug('Response Body for File: ' + responseValue);
     
        if (res.getStatusCode() == 201)
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'vikrant.ks@samsung.com'}; 
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
    }
    
   global static void getReportMetadata(){
       String dash_url = '/services/data/v56.0/analytics/reports/00O1s000000FrTHEA0/instances';
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
            String[] toAddresses = new String[] {'vikrant.ks@samsung.com'}; 
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('Support');
            mail.setSubject('Report Metadata');
            mail.setBccSender(false); 
            mail.setUseSignature(false);
            mail.setPlainTextBody(responseValue);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }
        else
        {System.debug('Failed to retrieve the dashboard image. Error: ' + res.getBody());}
   }
   global static void getReportData(){
       String dash_url = '/services/data/v56.0/analytics/reports/00O1s000000Fn5uEAC?includeDetails=true';
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
            String[] toAddresses = new String[] {'vikrant.ks@samsung.com'};//,'saurav.k@partner.samsung.com','divyam.gupta@samsung.com','oldman.sea@samsung.com','boram85.jung@samsung.com'}; //'rakshit.s@samsung.com'
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('Support');
            mail.setSubject('Report JSON Data');
            mail.setBccSender(false); 
            mail.setUseSignature(false);
            mail.setPlainTextBody(responseValue);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }
        else
        {System.debug('Failed to retrieve the Report Json data Error: ' + res.getBody());}
   }   
   
}