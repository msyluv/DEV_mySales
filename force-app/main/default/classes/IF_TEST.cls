/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 11-19-2020
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   11-19-2020   soohong0.kim@partner.samsung.com   Initial Version
**/
public class IF_TEST {
    public static void getToken(){
        try{

            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Content-Type','application/x-www-form-urlencoded');
            req.setEndpoint('https://test.salesforce.com/services/oauth2/token');
            
            String CLIENT_ID = '3MVG9pcaEGrGRoTKWhiWyoBD4DOgUEuibCU.3QjAt4iGcGf0ttpRvhZBU2EEmArpK0MH3Ki6GdmNo9xrGgqeO';
            String CLIENT_SECRET = 'E08730A7B65BF5BD31E2EA07190D1B89414930D079A92AC26CE231E7B777D146';
            String USERNAME = 'soohong0.kim@partner.samsung.com.sds.dev';
            String PASSWORD = 'Password123';
            
            req.setBody('grant_type=password' + '&client_id='+CLIENT_ID + 
                        '&client_secret='+CLIENT_SECRET + '&username='+USERNAME + '&password='+PASSWORD);
            
            Http http = new Http();
            HTTPResponse response = http.send(req);
            System.debug('Body ' + response.getBody());
            System.debug('Status ' + response.getStatus());
            System.debug('Status code ' + response.getStatusCode());
        }catch(Exception e){
            system.debug('exception : '+e);
        }
    }
}