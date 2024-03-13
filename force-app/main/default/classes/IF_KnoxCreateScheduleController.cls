/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 12-29-2020
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   11-30-2020   soohong0.kim@partner.samsung.com   Initial Version
**/

public class IF_KnoxCreateScheduleController {
    private static final String INTERFACE_ID = 'IF-073';
    private static final String APEX_CLASS   = 'IF_KnoxCreateScheduleController';
    private static final String METHOD_NAME  = 'createSchedule';
    
    @AuraEnabled
    public static Map<String,Object> createSchedule(InputClass input){
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
            system.debug('scheduleid___' + returnMap.get('scheduleId'));
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
        public String System_ID;
        @AuraEnabled
        public String calendarId;
        @AuraEnabled
        public String userId;
        
        @AuraEnabled
        public ScheduleInfo scheduleInfo;
    }
    public class ScheduleInfo{
        @AuraEnabled
        public String invitedYn;
        @AuraEnabled
        public String subject;
        @AuraEnabled
        public String originalStartTime;
        @AuraEnabled
        public String originalScheduleId;
        @AuraEnabled
        public String priority;
        @AuraEnabled
        public String userId;
        @AuraEnabled
        public String sendMailYn;
        @AuraEnabled
        public String recurrence;
        @AuraEnabled
        public String calendarId;
        @AuraEnabled
        public String contentsType;
        @AuraEnabled
        public String contents;
        @AuraEnabled
        public String authority;
        @AuraEnabled
        public String contentsCharset;
        @AuraEnabled
        public String allDayYn;
        @AuraEnabled
        public String place;
        @AuraEnabled
        public String class_SFDC;
        @AuraEnabled
        public String placeCode;

        @AuraEnabled
        public List<Attendees> attendees;
        @AuraEnabled
        public TimeTable startTime;
        @AuraEnabled
        public TimeTable endTime;
    }
    public class Attendees{
        @AuraEnabled
        public String sourceType;
        @AuraEnabled
        public String replyStatus;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String userId;
        @AuraEnabled
        public String seq;
    }
    public class TimeTable{
        @AuraEnabled
        public String date_SFDC;
        @AuraEnabled
        public String dateTime_SFDC;
        @AuraEnabled
        public String timeZone;
    }

}