public class IF_KnoxUpdateTaskCallout implements Database.AllowsCallouts{
  @future(callout=true)
    Public  Static  void doCalloutSendingUpdatedTasktoknox(String newTask){
        String APEX_CLASS   = 'IF_KnoxUpdateTaskController';
        String METHOD_NAME_190  = 'doCalloutSendingUpdatedTaskInfo';
        String INTERFACE_ID_190 = 'IF-195';
        Map<String,Object> resMap = new Map<String,Object>();
        IF_Log log = new IF_Log();
        String guId = '';
        //IF_Callout call;
        String jsonBody = '';
        HttpResponse res;
        guId= IF_KnoxChatSendController.generateUid();
        // try{
        List<Task> tasklist = [select id,Knox_Calendar_Id__c, Knox_Schedule_ID__c, Subject, ActivityDate,CreatedDate,Description,OwnerId,Owner.Email  from Task where id =: newTask];

        system.debug('listofTasks________' + tasklist);
        List<InputClass_190> input190List = new  List<InputClass_190>();
        String UserEmail = USerINfo.getUserEmail();
        List<String> parts = UserEmail.split('@');
        String userName = parts[0];
        User loginUser = [Select Id,CalendarID__c,Task_CalendarId__c,FederationIdentifier from User Where Id=:UserINfo.getUserId()];
        String userTimeZone = String.valueOf(UserInfo.getTimeZone());
        IF_Callout call = new IF_Callout(INTERFACE_ID_190);
        InputClass_190 input190 = new InputClass_190();
        InputHeader inputData = new InputHeader();
        if(tasklist.Size()>0){
            for(Task task: tasklist){                    
                input190.invitedYn = null;
                input190.subject = task.Subject;                    
                taskAttendes ta = new taskAttendes();
                ta.sourceType = 'EMPLOYEE';
                ta.displayName = null;//'Saurav Sankhyan/Sr Developer/Global Solution Part/SDSI';
                ta.replyStatus = 'ACCEPTED';
                ta.type = 'CHAIR';
                ta.userId = loginUser.FederationIdentifier;
                ta.email = task.Owner.Email;
                ta.seq = 0;
                input190.attendees.add(ta);
                input190.originalStartTime = null;
                input190.originalScheduleId = null;
                input190.priority= null;//task.Priority;                                       
                input190.userId = userName;       
                input190.sendMailYn = null;
                input190.calendarId = String.valueof(task.Knox_Calendar_Id__c);
                input190.contentsType = null;
                system.debug('descptionfrommysales'+task.Description);
                input190.contents = String.valueof(task.Description);
                input190.authority = 'ONE'; 
                input190.contentsCharset = null;
                input190.allDayYn = 'Y';
               // StartDate-----
          
                    input190.recurrence = null;
                starttheTime sTime = new starttheTime();
                sTime.xdate = dateTimeToDateString(task.ActivityDate);  

                //sTime.sDateTime = event.StartDateTime;
                sTime.sDateTime = datetimeToString_ISO8601(task.CreatedDate);                

                sTime.timeZone = userTimeZone;    
                input190.startTime = sTime;
                // StartDate----- 
                // EndDate-------               
                endtTheTime eTime = new endtTheTime();
               eTime.xdate =  dateTimeToDateString(task.ActivityDate);  
               // eTime.xdate =  event.IsAllDayEvent  ? dateTimeToDateString(event.EndDateTime) : '';

               // eTime.eDateTime = event.EndDateTime;
                eTime.eDateTime = datetimeToString_ISO8601(task.CreatedDate);  

                eTime.timeZone = userTimeZone;
                input190.endTime = eTime;
                // EndDate-------
                input190.place = '';
                input190.Outclass = 'PUBLIC';
                input190.scheduleId = null;
                input190.placeCode = null;
              //  input190.recurrenceModType ='ONE';
                input190.recurrenceModType ='ALL';
                // input190.scheduleId = 'SCH202308080419111245154833'; 
                if(task.Knox_Schedule_ID__c!= Null){
               //    String knoxschid = event.Knox_Schedule_ID__c; 
             // String knoxorgid = knoxschid.substring(0,27);
            // inputData.userKnoxCalendarId = knoxorgid;
                 inputData.userKnoxCalendarId= task.Knox_Schedule_ID__c;
                 inputData.mysalesknoxCalendarId = task.Knox_Calendar_Id__c;
                }             
            }
        }        
        jsonBody = JSON.serialize(input190);
        system.debug('IF-195jsonbody'+ jsonBody);
        jsonBody = jsonBody.Replace('xdate','date');
        jsonBody = jsonBody.Replace('sDateTime','DateTime');
        jsonBody = jsonBody.Replace('eDateTime','DateTime');
        jsonBody = jsonBody.Replace('Outclass','class');
        system.debug('Demand Response jsonBody : '+ jsonBody);
    //    String urlParam = '?userId='+ userName+'&'+'calendarId='+loginUser.CalendarID__c+'&'+'scheduleId='+inputData.userKnoxCalendarId+'&'+'recurrenceModType=ONE';        
        String urlParam = '?userId='+ userName+'&'+'calendarId='+inputData.mysalesknoxCalendarId+'&'+'scheduleId='+inputData.userKnoxCalendarId+'&'+'recurrenceModType=ONE';        
        resMap = call.httpKnoxCallout(jsonBody, urlParam);
        res = (HttpResponse)resMap.get('HttpResponse');
        System.debug('request : '+resMap.get('Request')); 
        System.debug('response : '+resMap.get('Response'));
        IF_Log.InterfaceLog ifLog;
        ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_190, guId, APEX_CLASS, METHOD_NAME_190, String.valueOf(input190List), String.valueOf(resMap.get('Response')));
        ID iFLogId = log.createLog2(ifLog);
        system.debug('iFLogId **' + iFLogId);
        System.debug('After input190List'+input190List); 
        
        /* } catch(Exception e){
system.debug('Exception e occur' + e.getMessage());
IF_Log.InterfaceLog ifLog;
ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_190, guId, APEX_CLASS, METHOD_NAME_190, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')),e);
ID iFLogId = log.createLog2(ifLog);
system.debug('iFLogId **' + iFLogId);
return   false;   
}*/ 
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
    public class InputClass_190{                
        public String Task_Assigned_To;
        public String Task_Assign_Email;
        //Knox Calender Creation
        public String invitedYn;//knox Body Starting
        public String subject;       
        public String originalStartTime;
        public String originalScheduleId;        
        public String placeCode;
        public String userId;
        public String sendMailYn;
        //public String recurrence;
        public String calendarId;
        public String contentsType;
        public String contents;
        public String authority;
        public starttheTime startTime = new starttheTime();
        public String contentsCharset;
        public String allDayYn;
        public endtTheTime endTime = new endtTheTime();
        public String place;
        public String Outclass;//Name Issue
        public String scheduleId;
        public String priority;
        public List<taskAttendes> attendees = new List<taskAttendes>();
        public String recurrenceModType;
        public recurrencer recurrence = new recurrencer();
    }
    public class recurrencer{
        public String condition;
        public String freqInterval;
        public String endType;
         public String freq;
        public String count;
        public String lunarYn;
        public string until;
        public String exceptions;
       
    }
    public class starttheTime{
       // public Date xdate;
        public String xdate;
      //  public DateTime sDateTime;
        public String sDateTime;
        public String timeZone;
    }
    public class endtTheTime{
       //public Date xdate;
        public String xdate;

     //   public DateTime eDateTime;
           public String eDateTime;

        public String timeZone;
    }
    public class taskAttendes{
        public String sourceType;
        public String displayName;
        public String replyStatus;
        public String type;
        public String userId;
        public String email;
        public integer seq;
    }
    public class InputHeader{
        public String userKnoxCalendarId;
        public String mysalesknoxCalendarId;
    }
}