/**
* @description       : Rest API Callout to Interact 
* @author            : saurav.k@partner.samsung.com
* @group             : 

* @last modified on  : 05/14/2024
* @last modified by  : sbest.han@samsung.com
* Modifications Log 
* Ver   Date         Author                          Modification
* 1.0   04/08/2023   saurav.k@partner.samsung.com    Initial Version
* 1.1   05/14/2024   sbest.han@samsung.com           Modify entire source code because of SIIS modification including refactoring
**/
public class IF_KnoxUpdateTaskController implements Database.AllowsCallouts {
    
    @future(callout=true)
    public static void doCalloutSendingUpdatedTaskInfo(String newEvent){
        String APEX_CLASS   = 'IF_KnoxUpdateTaskController';
        String METHOD_NAME  = 'doCalloutSendingUpdatedTaskInfo';
        String INTERFACE_ID = 'IF-195';
        String guId = IF_KnoxChatSendController.generateUid();
        
        Event eventObj = [SELECT Id,
                                 Subject,
                                 ActivityDate,
                                 StartDateTime,
                                 EndDateTime,
                                 OwnerId,
                                 Owner.Email,
                                 Knox_Schedule_ID__c,
                                 Location,Description,
                                 IsAllDayEvent,
                                 Isrecurrence__c,
                                 recurrence_con__c,
                                 Frequence__c,
                                 freqInterval__c,
                                 EndType__c,
                                 Count_rec__c,
                                 Until_RecurrenceDate__c,
                                 Knox_Calendar_Id__c,
                                 IsPrivate 
                            FROM Event 
                           WHERE Id =:newEvent];

        system.debug('eventObj________' + eventObj);

        List<String> userEmail = UserInfo.getUserEmail().split('@');
        String userId = userEmail[0];
        
        User loginUser = [SELECT Id,
                                 CalendarID__c,
                                 FederationIdentifier 
                            FROM User 
                           WHERE Id=:UserInfo.getUserId()];

        IF_Callout call = new IF_Callout(INTERFACE_ID);

        IF_KnoxCalendar inputObj = new IF_KnoxCalendar();
                   
        inputObj.invitedYn = null;
        system.debug('eventsub'+eventObj.Subject);
        inputObj.subject = eventObj.Subject;                    
        inputObj.originalStartTime = null;
        inputObj.originalScheduleId = null;
        inputObj.priority= null;//task.Priority;                                       
        inputObj.userId = userId;       
        inputObj.sendMailYn = null;
        inputObj.calendarId = String.valueof(eventObj.Knox_Calendar_Id__c);
        inputObj.contentsType = null;
        system.debug('descptionfrommysales'+eventObj.Description);
        inputObj.contents = String.valueof(eventObj.Description);
        inputObj.authority = 'ONE'; 
        inputObj.contentsCharset = null;
        inputObj.allDayYn = eventObj.IsAllDayEvent ? 'Y' : 'N';

        inputObj.place = eventObj.Location;
        inputObj.Outclass = eventObj.IsPrivate ? 'PRIVATE' : 'PUBLIC';
        inputObj.scheduleId = null;
        inputObj.placeCode = null;      
        inputObj.recurrenceModType ='ALL';
               
        IF_KnoxCalendar.TaskAttendees attendees = new IF_KnoxCalendar.TaskAttendees();
        attendees.sourceType = 'EMPLOYEE';
        attendees.displayName = null;//'Saurav Sankhyan/Sr Developer/Global Solution Part/SDSI';
        attendees.replyStatus = 'ACCEPTED';
        attendees.type = 'CHAIR';
        attendees.userId = loginUser.FederationIdentifier;
        attendees.email = eventObj.Owner.Email;
        attendees.seq = 0;

        inputObj.attendees.add(attendees);

        if(eventObj.Isrecurrence__c == true){
            IF_KnoxCalendar.Recurrence recurObj = new IF_KnoxCalendar.Recurrence();
                
            recurObj.condition = eventObj.recurrence_con__c;
            recurObj.freqInterval = eventObj.Frequence__c;
            recurObj.endType = eventObj.EndType__c;
            recurObj.freq = eventObj.Frequence__c;
            recurObj.count = String.valueof(eventObj.Count_rec__c);
            recurObj.lunarYn = 'N';

            if(eventObj.Until_RecurrenceDate__c !=''){
               recurObj.until = eventObj.Until_RecurrenceDate__c;
            }

            inputObj.recurrence = recurObj;
        }else {
            inputObj.recurrence = null;
        }

        String userTimeZone = String.valueOf(UserInfo.getTimeZone());

        IF_KnoxCalendar.KnoxTime sTime = new IF_KnoxCalendar.KnoxTime();
        sTime.xdate = eventObj.IsAllDayEvent ? dateTimeToDateString(eventObj.StartDateTime) : String.valueof(eventObj.ActivityDate);
        sTime.knoxDateTime = !eventObj.IsAllDayEvent ? datetimeToString_ISO8601(eventObj.StartDateTime) : '';  
        sTime.timeZone = userTimeZone;    

        inputObj.startTime = sTime;
        
        IF_KnoxCalendar.KnoxTime eTime = new IF_KnoxCalendar.KnoxTime();
        eTime.xdate =  eventObj.IsAllDayEvent  ? dateTimeToDateString(eventObj.EndDateTime) : String.valueof(eventObj.ActivityDate);
        eTime.knoxDateTime = !eventObj.IsAllDayEvent ? datetimeToString_ISO8601(eventObj.EndDateTime) : '';  
        eTime.timeZone = userTimeZone;
                
        inputObj.endTime = eTime;

        String jsonBody = JSON.serialize(inputObj);
        system.debug('IF-195jsonbody'+ jsonBody);

        jsonBody = jsonBody.Replace('knoxDateTime','dateTime');
        jsonBody = jsonBody.Replace('xdate','date');
        jsonBody = jsonBody.Replace('outclass','class');
        system.debug('Demand Response jsonBody : '+ jsonBody);

        IF_Log log = new IF_Log();
        String urlParam = '/' + eventObj.Knox_Calendar_Id__c + '/schedules/' + eventObj.Knox_Schedule_ID__c + '/update' +'?userId='+ userId +'&'+ 'recurrenceModType=ONE';        
        
        Map<String,Object> resMap = call.httpKnoxCallout(jsonBody, urlParam);
        HttpResponse res = (HttpResponse) resMap.get('HttpResponse');
        System.debug('request : '+resMap.get('Request')); 
        System.debug('response : '+resMap.get('Response'));

        IF_Log.InterfaceLog ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
        ID iFLogId = log.createLog2(ifLog);
        system.debug('iFLogId **' + iFLogId);
        
    }

     public static String datetimeToString_ISO8601(Datetime dt){
        String datetimeString_ISO8601 = '';

        String timeZoneDisplayName = UserInfo.getTimeZone().getDisplayName();               // (GMT+09:00) Korean Standard Time (Asia/Seoul)
        String timeOffset = timeZoneDisplayName.removeStart('(GMT').substringBefore(')');   // +09:00

        datetimeString_ISO8601 = dt.format('yyyy-MM-dd\'T\'HH:mm:ss') + timeOffset;
        return datetimeString_ISO8601;
    }

    public static String dateTimeToDateString(Datetime dt){
        if(dt == null) return null;
        String strDate = (dt + '').substring(0, 10);
        return strDate;
    }
}