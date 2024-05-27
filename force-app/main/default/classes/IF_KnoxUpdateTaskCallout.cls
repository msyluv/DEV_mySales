public class IF_KnoxUpdateTaskCallout implements Database.AllowsCallouts{

    @future(callout=true)
    public static void doCalloutSendingUpdatedTasktoknox(String newTask){
        String APEX_CLASS   = 'IF_KnoxUpdateTaskCallout';
        String METHOD_NAME  = 'doCalloutSendingUpdatedTasktoknox';
        String INTERFACE_ID = 'IF-195';
        String guId = IF_KnoxChatSendController.generateUid();

        IF_Log log = new IF_Log();
        
        Task taskObj = [Select id,
                            Knox_Calendar_Id__c, 
                            Knox_Schedule_ID__c, 
                            Subject, 
                            ActivityDate,
                            CreatedDate,
                            Description,
                            OwnerId,
                            Owner.Email,
                            PrivateTask__c 
                       From Task 
                      Where id =: newTask];

        system.debug('listofTasks________' + taskObj);
        
        List<String> userEmail = UserInfo.getUserEmail().split('@');
        String userId = userEmail[0];

        User loginUser = [Select Id, CalendarID__c, Task_CalendarId__c, FederationIdentifier from User Where Id=:UserInfo.getUserId()];

        String userTimeZone = String.valueOf(UserInfo.getTimeZone());
        IF_Callout call = new IF_Callout(INTERFACE_ID);

        IF_KnoxCalendar inputObj = new IF_KnoxCalendar();
                                  
        inputObj.invitedYn = null;
        inputObj.subject = taskObj.Subject;                    
        inputObj.originalStartTime = null;
        inputObj.originalScheduleId = null;
        inputObj.priority= null;//task.Priority;                                       
        inputObj.userId = userId;       
        inputObj.sendMailYn = null;
        inputObj.calendarId = String.valueof(taskObj.Knox_Calendar_Id__c);
        inputObj.contentsType = null;
        inputObj.contents = String.valueof(taskObj.Description);
        system.debug('descptionfrommysales'+taskObj.Description);

        inputObj.authority = 'ONE'; 
        inputObj.contentsCharset = null;
        inputObj.allDayYn = 'Y';
        inputObj.recurrence = null;
        inputObj.place = '';
        inputObj.Outclass = taskObj.PrivateTask__c ? 'PRIVATE' : 'PUBLIC';
        inputObj.scheduleId = null;
        inputObj.placeCode = null;
        inputObj.recurrenceModType ='ALL';
                
        IF_KnoxCalendar.TaskAttendees attendees = new IF_KnoxCalendar.TaskAttendees();
        attendees.sourceType = 'EMPLOYEE';
        attendees.displayName = null;//'Saurav Sankhyan/Sr Developer/Global Solution Part/SDSI';
        attendees.replyStatus = 'ACCEPTED';
        attendees.type = 'CHAIR';
        attendees.userId = loginUser.FederationIdentifier;
        attendees.email = taskObj.Owner.Email;
        attendees.seq = 0;

        inputObj.attendees.add(attendees);

        IF_KnoxCalendar.KnoxTime sTime = new IF_KnoxCalendar.KnoxTime();
        sTime.xdate = dateTimeToDateString(taskObj.ActivityDate);  
        sTime.knoxDateTime = datetimeToString_ISO8601(taskObj.CreatedDate);                
        sTime.timeZone = userTimeZone;    

        inputObj.startTime = sTime;

        IF_KnoxCalendar.KnoxTime eTime = new IF_KnoxCalendar.KnoxTime();
        eTime.xdate =  dateTimeToDateString(taskObj.ActivityDate);  
        eTime.knoxDateTime = datetimeToString_ISO8601(taskObj.CreatedDate); 
        eTime.timeZone = userTimeZone;

        inputObj.endTime = eTime;
              
        String jsonBody = JSON.serialize(inputObj);
        system.debug('IF-195jsonbody'+ jsonBody);

        jsonBody = jsonBody.Replace('knoxDateTime','DateTime');
        jsonBody = jsonBody.Replace('xdate','date');
        jsonBody = jsonBody.Replace('outclass','class');
        system.debug('Demand Response jsonBody : '+ jsonBody);

        String urlParam = '/' + taskObj.Knox_Calendar_Id__c + '/schedules/' + taskObj.Knox_Schedule_ID__c + '/update' +'?userId='+ userId +'&'+ 'recurrenceModType=ONE';        
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