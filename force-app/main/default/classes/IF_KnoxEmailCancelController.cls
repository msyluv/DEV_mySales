/*
@Desc : IF_KnoxEmailCancelController
@Author : Soohong.Kim
@Date : 2020. 11. 10
@Version : 1.0

@Method : 



@Modified : 
---------------------------------------------
NO | Date       | Modifier      | Description 
---------------------------------------------
1. | 2020.11.10 | Soohong.Kim   | 최초작성


*/
public class IF_KnoxEmailCancelController {
    private static final String INTERFACE_ID = 'IF-076';
    private static final String APEX_CLASS   = 'IF_KnoxEmailCancelController';
    private static final String METHOD_NAME  = 'cancelMail';
    
    @AuraEnabled
    public static Map<String,Object> cancelMail(InputClass input){
        String guId = IF_Util.generateGuid();
        IF_Callout call = new IF_Callout(INTERFACE_ID);
        IF_Log log = new IF_Log();
        IF_Log.InterfaceLog ifLog;
        Map<String,Object> resMap = new Map<String,Object>();
        Map<String,Object> returnMap = new Map<String,Object>();
        try{
            String jsonBody = JSON.serialize(input);
            resMap = call.httpCallout(jsonBody, '');
            system.debug('request : '+resMap.get('Request'));
            system.debug('response : '+resMap.get('Response'));

            HttpResponse res = (HttpResponse)resMap.get('HttpResponse');
            returnMap.put('StatusCode',res.getStatusCode());
            returnMap.put('IF_MSG',String.valueOf(resMap.get('IF_MSG')));
            returnMap.putAll((Map<String,Object>) JSON.deserializeUntyped(res.getBody()));
            
            
            system.debug('returnMap : '+returnMap);

            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
        
        }catch(Exception e){
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')),e);
        }
        log.createLog(ifLog);
        return returnMap;
    }

    public class InputClass{
        @AuraEnabled
        public String sfdcId;
        @AuraEnabled
        public String mailId;
        @AuraEnabled
        public String userId;
        @AuraEnabled
        public List<String> recipients;
    }
}