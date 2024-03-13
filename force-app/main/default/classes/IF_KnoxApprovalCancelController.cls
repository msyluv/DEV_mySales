/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-05-21
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   2020-11-11   soohong0.kim@partner.samsung.com   Initial Version
 * 1.1   2021-03-04   soohong0.kim@partner.samsung.com   IF_Log 수정(기존 DML 제거, Return 객체에 put)
**/

public class IF_KnoxApprovalCancelController {
    private static final String INTERFACE_ID = 'IF-078';
    private static final String APEX_CLASS   = 'IF_KnoxApprovalCancelController';
    private static final String METHOD_NAME  = 'approvalCancel';

    @AuraEnabled
    public static Map<String,Object> approvalCancel(InputClass input){
        String guId = IF_Util.generateGuid();
        IF_Callout call = new IF_Callout(INTERFACE_ID);
        IF_Log log = new IF_Log();
        IF_Log.InterfaceLog ifLog;
        Map<String,Object> resMap = new Map<String,Object>();
        Map<String,Object> returnMap = new Map<String,Object>();
        try{

            // 기안자 확인
            List<KnoxApprover__c> knoxAprList = [

                SELECT  Id, Employee__c, Employee__r.EvUniqID__c, Employee__r.Knox_Server_Location__c
                FROM    KnoxApprover__c 
                WHERE   KnoxApproval__r.MISID__c = :input.apInfId
                AND     ApproverType__c  = '0'
                LIMIT   1
            ];

            if( knoxAprList.size() > 0){

                input.serverlocation = knoxAprList.get( 0).Employee__r.Knox_Server_Location__c;
            }            


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
        returnMap.put('INTERFACE_LOG',ifLog);
        return returnMap;
    }
 
    public class InputClass{
        @AuraEnabled
        public String apInfId;
        @AuraEnabled
        public String opinion;
        @AuraEnabled
        public String serverlocation;
    }
}