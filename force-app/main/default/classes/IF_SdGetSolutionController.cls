/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 12-18-2020
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   12-15-2020   soohong0.kim@partner.samsung.com   Initial Version
**/
public class IF_SdGetSolutionController {
    
    private static final String INTERFACE_ID = 'IF-063';
    private static final String APEX_CLASS   = 'IF_SdGetSolutionController';
    private static final String METHOD_NAME  = 'send';
    
    @AuraEnabled
    public static Map<String,Object> send(InputClass input){
        IF_Callout call = new IF_Callout(INTERFACE_ID);
        String guId = IF_Util.generateGuid();
        IF_Log log = new IF_Log();
        IF_Log.InterfaceLog ifLog;
        Map<String,Object> resMap = new Map<String,Object>();
        
        try{

            String jsonBody = JSON.serialize(input);
            system.debug('jsonbody : '+jsonBody);
            resMap = call.httpCallout(jsonBody, '');
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
                
            

        }catch(Exception e){
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')),e);
        }
        log.createLog(ifLog);
        return resMap;
    }

    public class InputClass{
        @AuraEnabled
        public List<CT_SOL> CT_SOL;
    }
    public class CT_SOL {
        @AuraEnabled
        public String GUID; // GUID of a CRM Order Object
        @AuraEnabled
        public String ZZORDER_ID; // BO코드
        @AuraEnabled
        public String DESCRIPTION; // BO명
        @AuraEnabled
        public String NUMBER_INT; // 문서의 Item 번호
        @AuraEnabled
        public String ZZSERVICE_CLASS; // 서비스코드
        @AuraEnabled
        public String ZZSOLUTION; // 솔루션코드
        @AuraEnabled
        public String ZZBUKRS_H; // 회사코드
        @AuraEnabled
        public String AERDAT; // Current Date of Application Server
        @AuraEnabled
        public String ZZSALES_CELL_NAM; // 영업부서 코스트센터 코드
        @AuraEnabled
        public String ZZDEVELOP_CELL_N; // 개발부서 코스트센터 코드
    }
}