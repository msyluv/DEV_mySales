/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 03-19-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   11-18-2020   soohong0.kim@partner.samsung.com   Initial Version
**/


public class IF_MdgAccountSenderController {
    private static final String INTERFACE_ID = 'IF-052';
    private static final String APEX_CLASS   = 'IF_MdgAccountSenderController';
    private static final String METHOD_NAME  = 'send';
    
    @AuraEnabled
    public static Map<String,Object> send(InputClass input){
        IF_Callout call = new IF_Callout(INTERFACE_ID);
        String guId = IF_Util.generateGuid();
        IF_Log log = new IF_Log();
        IF_Log.InterfaceLog ifLog;
        Map<String,Object> resMap = new Map<String,Object>();
        Map<String,Object> returnMap = new Map<String,Object>();
        
        try{

            String jsonBody = JSON.serialize(input);
            system.debug('### IF_MdgAccountSenderController :: send :: jsonbody : '+jsonBody);
            resMap = call.httpCallout(jsonBody, '');

            HttpResponse res = (HttpResponse)resMap.get('HttpResponse');
            
            system.debug('### IF_MdgAccountSenderController :: send :: res : '+res);
            system.debug('### IF_MdgAccountSenderController :: send :: res body = : ' + res.getBody());
            system.debug('### IF_MdgAccountSenderController :: send :: res body IF_MSG = : ' + resMap.get('IF_MSG'));
            
            returnMap.put('StatusCode',res.getStatusCode());
            returnMap.put('IF_MSG',String.valueOf(resMap.get('IF_MSG')));
            returnMap.putAll((Map<String,Object>) JSON.deserializeUntyped(res.getBody()));
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));

        }catch(Exception e){
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')),e);
        }
        // log.createLog(ifLog);
        returnMap.put('INTERFACE_LOG', JSON.serialize(ifLog));
        return returnMap;
    }

    public class InputClass{
        @AuraEnabled
        public List<Address> ADRESS;
        @AuraEnabled
        public List<Kna1> KNA1; 
    }
    public class Address{
        /*
        @AuraEnabled
        public String BillingAddressState;*/
        @AuraEnabled
        public String BillingAddressCity1;
        @AuraEnabled
        public String BillingAddressStreet;
        @AuraEnabled
        public String BillingAddressPostalCode;
        @AuraEnabled
        public String BillingAddressCountry;
        @AuraEnabled
        public String Region;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String SFDCID;
    }
    public class Kna1{
        @AuraEnabled
        public String CreatedById;
        @AuraEnabled
        public String mCountry;
        @AuraEnabled
        public String CorporateNumber;
        @AuraEnabled
        public String mDomesticForeign;
        @AuraEnabled
        public String mCEOName;
        @AuraEnabled
        public String mBizTypeL1Code;
        @AuraEnabled
        public String mBizTypeL2Code;
    }
}