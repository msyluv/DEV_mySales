public class RestAPITest {
    
    public static void CallOut() {
        
        HttpRequest req = new HttpRequest();
        //req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionID());  
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint('https://sdssfa--qa.my.salesforce.com/services/data/v54.0/tooling/executeAnonymous/?anonymousBody=System.debug(\'Test\')%3B');
        req.setMethod('GET');
        
        Http h = new Http();
        HttpResponse res = h.send(req);
        system.debug('### JobExecBreakController, res.getBody() ' + res.getBody());
        
    }

}