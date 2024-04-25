public class knoxCreateScheduleTask implements Queueable,Database.AllowsCallouts {
    
 public String taskid;
    public knoxCreateScheduleTask(String taskid){        
        this.taskid = taskid;
        
    }    
     public void execute(QueueableContext context){
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
        Task tasklist = [select id,Knox_Calendar_Id__c,Taskalertmsg__c, Knox_Schedule_ID__c, Subject, ActivityDate,CreatedDate,Description,OwnerId,Owner.Email  from Task where id =: taskid];

        String UserEmail = USerINfo.getUserEmail();
        List<String> parts = UserEmail.split('@');
        String userName = parts[0];
        User loginUser = [Select Id,CalendarID__c,FederationIdentifier,Task_CalendarId__c from User Where Id=:UserINfo.getUserId()];
        String userTimeZone = String.valueOf(UserInfo.getTimeZone());        
        InputClass InputParam = New InputClass();
        InputParam.System_ID = null;
        InputParam.calendarId = loginUser.Task_CalendarId__c;
        InputParam.userId = userName;    
         try {
      //  List<ScheduleInfoout> sceduleinfolist = new List<ScheduleInfoout>();
         ScheduleInfo scheduleInfo = new ScheduleInfo();
                scheduleInfo.invitedYn = null;
                scheduleInfo.subject = tasklist.Subject;
                scheduleInfo.originalStartTime = null;
                scheduleInfo.originalScheduleId = null;
                scheduleInfo.priority = '5';
                scheduleInfo.userId = userName;
                scheduleInfo.sendMailYn = null;
                scheduleInfo.recurrence = null;
                scheduleInfo.calendarId = loginUser.Task_CalendarId__c; //'CALM230315081100C6N7454';//loginUser.CalendarID__c;
                //scheduleInfo.scheduleId = null;
                scheduleInfo.contentsType = 'Text';
                scheduleInfo.contents = tasklist.Description;
                scheduleInfo.authority = 'ALL';
                scheduleInfo.contentsCharset = 'UTF-8';
                scheduleInfo.allDayYn = 'Y';  
                scheduleInfo.place = '';
                scheduleInfo.class_SFDC = 'PUBLIC';
                scheduleInfo.placeCode = '';
                //StartTime---Start------                
                TimeTable startTime = new TimeTable();   
                startTime.date_SFDC = dateTimeToDateString(tasklist.ActivityDate);  
                //startTime.date_SFDC = event.IsAllDayEvent  ? dateTimeToDateString(event.StartDateTime) : '';               
                startTime.dateTime_SFDC =datetimeToString_ISO8601(tasklist.CreatedDate);                 
                startTime.timeZone =  userTimeZone;    
                scheduleInfo.startTime = startTime;
				//StartTime-----End----                 
                TimeTable endTime = new TimeTable();
               // endTime.date_SFDC = event.IsAllDayEvent  ? dateTimeToDateString(event.EndDateTime) : '';  
                endTime.date_SFDC = dateTimeToDateString(tasklist.ActivityDate);               
                endTime.dateTime_SFDC =datetimeToString_ISO8601(tasklist.CreatedDate);                
                endTime.timeZone =  userTimeZone;    
                scheduleInfo.endTime = endTime;
                scheduleInfo.Attendees = Null;
                //sceduleinfolist.add(scheduleInfo);
               /* Attendees ownerAttendee = New Attendees();
                ownerAttendee.sourceType = 'EMPLOYEE';
                ownerAttendee.replyStatus = 'ACCEPTED';
                ownerAttendee.type = 'CHAIR';
                ownerAttendee.userId = loginUser.FederationIdentifier;      // EP ID 
                ownerAttendee.seq = '0';
                ScheduleInfo.attendees.add(ownerAttendee);*/
            
        inputParam.scheduleInfo = scheduleInfo;
        system.debug('ScheduleInfo_________' + inputParam.scheduleInfo);
        jsonBody = JSON.serialize(inputParam);  
       //  jsonBody = jsonBody.Replace('date_SFDC','date');
         //  jsonBody = jsonBody.Replace('dateTime_SFDC','dateTime');

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
             Map<String,Object> jsonMap = (Map<String,object>)JSON.deserializeUntyped(jsonResponse);

             // Map<String,Object> deserailse = (Map<String,Object>)JSON.deserializeUntyped(jsonResponse);

             //  Map<String,object> jsonMap = new Map<String,object>();
                     /* 	List<Object> jsonMap = new List<Object>();

               for(Object inst : (List<object>)deserailse.get('data')){
        	jsonMap.add((Map<String,object>)inst);
        	}
              system.debug('Jsoncomingtask'+jsonMap); */

              //   Map<String,Object> jsonMap = (Map<String,object>)JSON.deserializeUntyped(jsonResponse);
                   // system.debug('objMap____' + jsonMap.get('data'));
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
       // Event e = [Select Id,Knox_Schedule_ID__c FROM Event WHERE ID =: eventId];        
        tasklist.Knox_Schedule_ID__c = temp2;
        tasklist.Knox_Calendar_Id__c = KnoxcalendarId;
        if(temp2 != Null &&  String.isNotBlank(temp2)){
           update tasklist;
        }
       interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID_190, guId, APEX_CLASS, METHOD_NAME_190, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));

          }
             else {
                 List<String> errList = new List<String>();
                 tasklist.Taskalertmsg__c =true;
                 update tasklist;
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
       // public List<ScheduleInfoout> ScheduleInfo;
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