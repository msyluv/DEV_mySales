public class ReportDashboardData {
    public static void sendDashboardImageByEmail(String dashboardId, String recipientEmail) {
        // Create the Dashboard REST API URL
        //String dashboardUrl = '/analytics/dashboard/' + dashboardId. ;
        //String dashboardUrl = '/analytics/dashboards/dashboardId.png' ;
        //String dashboardUrl = '/analytics/download/dashboard/01Z1s0000000OdxEAE.png' ;
        String dashboardUrl2 = '/analytics/download/lightning-dashboard/01Z1s0000000OdxEAE.png';
        system.debug('dashboardUrl______' + dashboardUrl2);
        // Make the API call to retrieve the dashboard image
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        request.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + dashboardUrl2);
        request.setMethod('GET');
        
        HttpResponse response = new Http().send(request);
        system.debug('response___' + response.getBody());
        system.debug('response end');
        
        
        
        // Check if the API call was successful
        
        String htmlContent = '<html><body><h1>Hello, World!</h1><p>This is an example email with HTML content.</p></body></html>';
        String dynamicHtmlContent = response.getBody();
        String responseHTMLStringified = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">'
            + '<html>'
            + '<p> I am sample html</p>'
            + '<head>'
            + '<meta HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">'
            + '<script>'
            + 'function redirectOnLoad() {'
            + 'if (this.SfdcApp && this.SfdcApp.projectOneNavigator) { SfdcApp.projectOneNavigator.handleRedirect(\'https://sdssfa--qa.sandbox.my.salesforce.com/?ec=302&startURL=%2Fanalytics%2Fdownload%2Flightning-dashboard%2F01Z1s0000000OdxEAE.png&sid=MDBEMXMwMDAwMDA4bFVNIUFROEFRSjFuSnBzb3Y2Q0VCek9qeE5mSWtiSG5NM0pOVHRidVdmMW9QaTlUU2NnQkVqdFYxZThmY25TSFFzb1lRRGEzNjcwWGZMaEo0OTA5QUpUU0xuUzNXUFpOa3VhQQ==\'); }'
            + 'else if (window.location.replace) {'
            + 'window.location.replace(\'https://sdssfa--qa.sandbox.my.salesforce.com/?ec=302&startURL=%2Fanalytics%2Fdownload%2Flightning-dashboard%2F01Z1s0000000OdxEAE.png&sid=MDBEMXMwMDAwMDA4bFVNIUFROEFRSjFuSnBzb3Y2Q0VCek9qeE5mSWtiSG5NM0pOVHRidVdmMW9QaTlUU2NnQkVqdFYxZThmY25TSFFzb1lRRGEzNjcwWGZMaEo0OTA5QUpUU0xuUzNXUFpOa3VhQQ==\');'
            + '}'
            + 'else {'
            + 'window.location.href =\'https://sdssfa--qa.sandbox.my.salesforce.com/?ec=302&startURL=%2Fanalytics%2Fdownload%2Flightning-dashboard%2F01Z1s0000000OdxEAE.png&sid=MDBEMXMwMDAwMDA4bFVNIUFROEFRSjFuSnBzb3Y2Q0VCek9qeE5mSWtiSG5NM0pOVHRidVdmMW9QaTlUU2NnQkVqdFYxZThmY25TSFFzb1lRRGEzNjcwWGZMaEo0OTA5QUpUU0xuUzNXUFpOa3VhQQ==\';'
            + '}'
            + '}'
            + 'redirectOnLoad();'
            + '</script>'
            + '</head>'
            + '</html>'
            + '<script type="text/javascript">function bodyOnLoad(){if(window.PreferenceBits){window.PreferenceBits.prototype.csrfToken="null";};}function bodyOnBeforeUnload(){}function bodyOnFocus(){}function bodyOnUnload(){}</script>';
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{ 'rakshitsfdc@gmail.com' });
        email.setSubject('Example HTML Email');
        email.setHtmlBody(responseHTMLStringified);
        
        Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
        
        // Check the results
        if (emailResults[0].isSuccess()) {
            System.debug('Email sent successfully.');
        } else {
            System.debug('Failed to send email: ' + emailResults[0].getErrors()[0].getMessage());
        }
        
        
        
        /*sample html
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">





<script>
function redirectOnLoad() {
if (this.SfdcApp && this.SfdcApp.projectOneNavigator) { SfdcApp.projectOneNavigator.handleRedirect('https://sdssfa--qa.sandbox.my.salesforce.com?ec=302&startURL=%2Fanalytics%2Fdownload%2Flightning-dashboard%2F01Z1s0000000OdxEAE.png'); }  else 
if (window.location.replace){ 
window.location.replace('https://sdssfa--qa.sandbox.my.salesforce.com?ec=302&startURL=%2Fanalytics%2Fdownload%2Flightning-dashboard%2F01Z1s0000000OdxEAE.png');
} else {
window.location.href ='https://sdssfa--qa.sandbox.my.salesforce.com?ec=302&startURL=%2Fanalytics%2Fdownload%2Flightning-dashboard%2F01Z1s0000000OdxEAE.png';
} 
} 
redirectOnLoad();
</script>

</head>


</html>





<!-- Body events -->
<script type="text/javascript">function bodyOnLoad(){if(window.PreferenceBits){window.PreferenceBits.prototype.csrfToken="null";};}function bodyOnBeforeUnload(){}function bodyOnFocus(){}function bodyOnUnload(){}</script>

</body>
</html>
ImageUtils.convertImageToBase64('https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg');

Reportdashboarddata.sendDashboardImageByEmail('01Z1s0000000OdxEAE', 'recipientEmail');
https://salesforce.stackexchange.com/questions/357105/how-to-download-dashboard-screenshots-programmatically
*/
    }
}