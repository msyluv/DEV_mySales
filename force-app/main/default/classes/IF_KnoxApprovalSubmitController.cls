/*
@Desc : IF_KnoxSubmitApprovalController
@Author : Soohong.Kim
@Date : 2020. 11. 11
@Version : 1.0

@Method : 



@Modified : 
---------------------------------------------
NO | Date       | Modifier      | Description 
---------------------------------------------
1. | 2020.11.11 | Soohong.Kim   | 최초작성


*/
public class IF_KnoxApprovalSubmitController {
    
    private static final String INTERFACE_ID = 'IF-079';
    private static final String APEX_CLASS   = 'IF_KnoxApprovalSubmitController';
    private static final String METHOD_NAME  = 'approvalSubmit';

    @AuraEnabled
    public static Map<String,Object> approvalSubmit(InputClass input){
        String guId = IF_Util.generateGuid();
        IF_Callout call = new IF_Callout(INTERFACE_ID);
        IF_Log log = new IF_Log();
        IF_Log.InterfaceLog ifLog;

        IF_Log callout_log = new IF_Log();
        IF_Log.InterfaceLog callout_ifLog;
        Map<String,Object> resMap = new Map<String,Object>();
        Map<String,Object> returnMap = new Map<String,Object>();
        try{

            // knox 지역 코드
            List<IF_KnoxApprovalSubmitController.Aplns> aplnsList = input.aplns;
            if( aplnsList != null){

                String epId = null;
                for( IF_KnoxApprovalSubmitController.Aplns apln: aplnsList){

                    if( apln.seq == '0') {

                        epId = apln.epId;
                        break;
                    }
                }

                List<Employee__c> empList = [

                    SELECT Id
                          ,EvUniqID__c
                          ,Knox_Server_Location__c
                    FROM   Employee__c
                    WHERE  EvUniqID__c  = :epId
                ];

                if( empList.size() > 0) input.serverlocation = empList.get( 0).Knox_Server_Location__c;
            }


            String jsonBody = JSON.serialize(input);
            resMap = call.httpCallout(jsonBody, '');
            system.debug('request : '+resMap.get('Request'));
            system.debug('response : '+resMap.get('Response'));
            system.debug('Ani HttpResponse : '+resMap.get('HttpResponse'));
            system.debug('Ani HttpResponse 1 : '+resMap);

            callout_ifLog = new IF_Log.InterfaceLog(INTERFACE_ID+'_calloutLog', guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')) , String.valueOf(resMap.get('DEBUG_LOG')));

            HttpResponse res = (HttpResponse)resMap.get('HttpResponse');
            returnMap.put('StatusCode',res.getStatusCode());
            returnMap.put('IF_MSG',String.valueOf(resMap.get('IF_MSG')));
            returnMap.putAll((Map<String,Object>) JSON.deserializeUntyped(res.getBody()));

            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
        
        }catch(Exception e){
            callout_ifLog = new IF_Log.InterfaceLog(INTERFACE_ID+'_calloutLog', guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')) , String.valueOf(resMap.get('DEBUG_LOG')),e);
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')),e);
        }
        log.createLog(ifLog);
        callout_log.createLog(callout_ifLog);
        return returnMap;
    }

    public class InputClass{
        @AuraEnabled
        public String contents;
        @AuraEnabled
        public String contentsType;
        @AuraEnabled
        public String docSecuType;
        @AuraEnabled
        public String notifyOption;
        @AuraEnabled
        public String urgYn;
        @AuraEnabled
        public String sbmDt;
        @AuraEnabled
        public String timeZone;
        @AuraEnabled
        public String docMngSaveCode;
        @AuraEnabled
        public String subject;
        @AuraEnabled
        public String sbmLang;
        @AuraEnabled
        public String importantYn;
        @AuraEnabled
        public String apInfId;
        @AuraEnabled
        public String serverlocation;

        @AuraEnabled
        public List<Aplns> aplns;
        @AuraEnabled
        public List<attachments> attachments;
    }

    public class Attachments{
        @AuraEnabled
        public String contentType{get;set;}
        @AuraEnabled
        public String fileName{get;set;}
        @AuraEnabled
        public String contents{get;set;}
        public Attachments(String contentType, String fileName, String contents){
            this.contentType = contentType;
            this.fileName = fileName;
            this.contents = contents;
        }
    }
    public class Aplns{
        @AuraEnabled
        public String epId{get;set;}
        @AuraEnabled
        public String userId{get;set;}
        @AuraEnabled
        public String emailAddress{get;set;}
        @AuraEnabled
        public String seq{get;set;}
        @AuraEnabled
        public String role{get;set;}
        @AuraEnabled
        public String aplnStatsCode{get;set;}
        @AuraEnabled
        public String arbPmtYn{get;set;}
        @AuraEnabled
        public String contentsMdfyPmtYn{get;set;}
        @AuraEnabled
        public String aplnMdfyPmtYn;
        @AuraEnabled
        public String opinion;

        public Aplns(String epId, String userId, String emailAddress, String seq, String role, String aplnStatsCode, String arbPmtYn, String contentsMdfyPmtYn, String aplnMdfyPmtYn, String opinion){
            this.epId = epId;
            this.userId = userId;
            this.emailAddress = emailAddress;
            this.seq = seq;
            this.role = role;
            this.aplnStatsCode = aplnStatsCode;
            this.arbPmtYn = arbPmtYn;
            this.contentsMdfyPmtYn = contentsMdfyPmtYn;
            this.aplnMdfyPmtYn = aplnMdfyPmtYn;
            this.opinion = opinion;
        }
    }
    public class OutputClass{
        @AuraEnabled
        public String result;
    }
}