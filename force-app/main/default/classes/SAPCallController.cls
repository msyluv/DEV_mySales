/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2020-08-24
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-08-24   younghoon.kim@dkbmc.com   Initial Version
**/
public class SAPCallController {
    /**
    * @description 
    * @author younghoon.kim@dkbmc.com | 2020-08-24 
    * @param String prodCode 
    * @return String 
    **/
    @AuraEnabled
    public static String sendToSap(String prodCode){
        String returnString = '';
        // String url = 'http://203.241.151.21:9000/crm_api2/api/apitest?startDate=' + prodCode;
        // try{
        //     Http h = new Http();
        //     HttpRequest req = new HttpRequest();
        //     req.setEndpoint(url);
        //     req.setMethod('GET');
        //     HttpResponse res = h.send(req);
        //     returnString = res.getBody();
        // }catch(Exception e){
        //     System.debug('Get Sales Info ERROR : ' + e.getMessage());
        // }

        returnString = 'Send to SAP Test';

        return returnString;
    }
}