public class knoxCreateScheduleQuableClass implements Queueable, Database.AllowsCallouts {
	public boolean isCheck = false;    
    public String eventId;
    public knoxCreateScheduleQuableClass(String newTask){        
        this.eventId = newTask;
        
    }
    public void execute(QueueableContext context) { 
        IF_Log ifLog = new IF_Log();
        IF_Log.InterfaceLog interfaceLog;
        String APEX_CLASS   = 'IF_KnoxTaskCallOutAPIController';
        String METHOD_NAME_190  = 'doCalloutSendingTaskInfo';
        String INTERFACE_ID_190 = 'IF-073';
        Map<String,Object> resMap = new Map<String,Object>();
       // IF_Log log = new IF_Log();
        String guId = '';
        IF_Callout call;
        String jsonBody = '';
        HttpResponse res;
        call = new IF_Callout(INTERFACE_ID_190);
        guId= IF_KnoxChatSendController.generateUid();
        
        List<Event> listofEvents =[SELECT Id,Subject,ActivityDate,StartDateTime,EndDateTime,OwnerId,Owner.Email,Location,Description,IsAllDayEvent FROM Event WHERE Id =:eventId];
        system.debug('listofTasks________' + listofEvents);            
        String UserEmail = USerINfo.getUserEmail();
        List<String> parts = UserEmail.split('@');
        String userName = parts[0];
        User loginUser = [Select Id,CalendarID__c,FederationIdentifier from User Where Id=:UserINfo.getUserId()];
        String userTimeZone = String.valueOf(UserInfo.getTimeZone());        
        InputClass InputParam = New InputClass();
        InputParam.System_ID = null;
        InputParam.calendarId = loginUser.CalendarID__c;
        InputParam.userId = userName;           
        ScheduleInfo scheduleInfo = New ScheduleInfo();
        try {
        if(listofEvents != Null){
            for(Event event: listofEvents){
                scheduleInfo.invitedYn = null;
                scheduleInfo.subject = event.Subject;
                scheduleInfo.originalStartTime = null;
                scheduleInfo.originalScheduleId = null;
                scheduleInfo.priority = '5';
                scheduleInfo.userId = userName;
                scheduleInfo.sendMailYn = null;
                scheduleInfo.recurrence = null;
                scheduleInfo.calendarId = loginUser.CalendarID__c; //'CALM230315081100C6N7454';//loginUser.CalendarID__c;
                //scheduleInfo.scheduleId = null;
                scheduleInfo.contentsType = 'Text';
                scheduleInfo.contents = event.Description;
                scheduleInfo.authority = 'ALL';
                scheduleInfo.contentsCharset = 'UTF-8';
                scheduleInfo.allDayYn = event.IsAllDayEvent ? 'Y' : 'N';  
                scheduleInfo.place = event.Location;
                scheduleInfo.class_SFDC = 'PUBLIC';
                scheduleInfo.placeCode = event.Location;
                //StartTime---Start------                
                TimeTable startTime = new TimeTable();   
                startTime.date_SFDC = dateTimeToDateString(event.StartDateTime);  
                //startTime.date_SFDC = event.IsAllDayEvent  ? dateTimeToDateString(event.StartDateTime) : '';               
                startTime.dateTime_SFDC = !event.IsAllDayEvent ? datetimeToString_ISO8601(event.StartDateTime) : '';                 
                startTime.timeZone =  userTimeZone;    
                scheduleInfo.startTime = startTime;
				//StartTime-----End----                 
                TimeTable endTime = new TimeTable();
               // endTime.date_SFDC = event.IsAllDayEvent  ? dateTimeToDateString(event.EndDateTime) : '';  
                endTime.date_SFDC = dateTimeToDateString(event.EndDateTime);               
                endTime.dateTime_SFDC = !event.IsAllDayEvent ? datetimeToString_ISO8601(event.EndDateTime) : '';                
                endTime.timeZone =  userTimeZone;    
                scheduleInfo.endTime = endTime;
                scheduleInfo.Attendees = Null;
               /* Attendees ownerAttendee = New Attendees();
                ownerAttendee.sourceType = 'EMPLOYEE';
                ownerAttendee.replyStatus = 'ACCEPTED';
                ownerAttendee.type = 'CHAIR';
                ownerAttendee.userId = loginUser.FederationIdentifier;      // EP ID 
                ownerAttendee.seq = '0';
                ScheduleInfo.attendees.add(ownerAttendee);*/
            }
        }
        inputParam.ScheduleInfo = scheduleInfo;
        system.debug('inputParam.ScheduleInfo_________' + inputParam.ScheduleInfo);
        jsonBody = JSON.serialize(inputParam);              
        resMap = call.httpKnoxCallout(jsonBody,'');
        system.debug('resMap===>'+resMap);
        HttpResponse response = (HttpResponse)resMap.get('HttpResponse');
        System.debug('request : '+resMap.get('Request')); 
        System.debug('response : '+resMap.get('Response'));
        String jsonResponse = response.getBody();
            system.debug('Jsonresonsecoming-->'+jsonResponse);
                //String temp2 = s.replaceAll('"','');

        String s;
                String s1;
             String KnoxcalendarId ='';
          if(response.getStatusCode() == 200){
              String scheduleId;
               Map<String,object> jssone = new Map<String,object>();
                 Map<String,Object> jsonMap = (Map<String,object>)JSON.deserializeUntyped(jsonResponse);
                    system.debug('objMap____' + jsonMap.get('data'));
                    // Map<String,Object> jsonMap1 = (Map<String,object>)JSON.deserializeUntyped(seriallse);
                    //system.debug('objMap1____' + jsonMap.get('objMap1____'));
                    //[SJOSHI]Start
                    
                    Map<String,Object> dMap = (Map<String,Object>) jsonMap.get('data');
                    if(dMap != null){
                          scheduleId = (String) dMap.get('scheduleId');
                          KnoxcalendarId = (String) dMap.get('calendarId');                      }
              		System.debug('SJOSHI>>'+scheduleId);
                    //[SJOSHI]End

                
           
        //String temp2 = s.replaceAll('"','');
         String temp2 = scheduleId;

        System.debug('temp2_________ '+ temp2); 
        Event e = [Select Id,Knox_Schedule_ID__c FROM Event WHERE ID =: eventId];        
        e.Knox_Schedule_ID__c = temp2;
        e.Knox_Calendar_Id__c = KnoxcalendarId;
		isCheck = true;        
        if(temp2 != Null &&  String.isNotBlank(temp2)){
            update e;
        }
                     interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID_190, guId, APEX_CLASS, METHOD_NAME_190, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));

          }
                   else {
                 List<String> errList = new List<String>();
               
                 interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID_190, guId, APEX_CLASS, METHOD_NAME_190, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')),errList);
             }
  
        }
        catch (Exception e){
                ifLog.addLog('Exception : ' + e.getMessage());
                // errorMsgList.add('Exception : ' + e.getMessage());           
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID_190, guId, APEX_CLASS, METHOD_NAME_190, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')), e);          
         }
                     ifLog.createLog(interfaceLog); 

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
    
     public class InputClass{       
        public String System_ID;       
        public String calendarId;        
        public String userId;                
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
         public String attendees;
        //@AuraEnabled
        //public String scheduleId;
       // @AuraEnabled
        //public List<Attendees> attendees;
        @AuraEnabled
        public TimeTable startTime;
        @AuraEnabled
        public TimeTable endTime;
    }
    public class TimeTable{
        @AuraEnabled
        public String date_SFDC;
        @AuraEnabled
        public String dateTime_SFDC;
        @AuraEnabled
        public String timeZone;
    }
    public class InputHeader{
    public String userKnoxCalendarId;
    }
}