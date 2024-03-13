/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2020-11-27
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   11-24-2020   soohong0.kim@partner.samsung.com   Initial Version
**/
public class IF_SdGetOrgChangeController {
    private static final String INTERFACE_ID = 'IF-016';
    private static final String APEX_CLASS   = 'IF_SdGetOrgChangeController';
    private static final String METHOD_NAME  = 'getOrgChange';
    
    @AuraEnabled
    public static Map<String,Object> getOrgChange(InputClass input){
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
            returnMap = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            log.addLog('returnMap : ' + returnMap);
            
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
        public String IV_BUKRS;
        @AuraEnabled
        public String IV_OTSEQ;
        @AuraEnabled
        public List<IT_POSID> IT_POSID;
    }
    public class IT_POSID{
        @AuraEnabled
        public String WBS_ELEMENT;
    }
}