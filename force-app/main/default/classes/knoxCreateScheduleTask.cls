/**
        * @description       : Controller Class for customFullCalendar LWC 
        * @author            : divyam.gupta@samsung.com
        * @group             : 
        * @last modified on  : 2024-05-24
        * @last modified by  : divyam.gupta@samsung.com
        * Modifications Log 
        * Ver   Date         Author                      Modification
        * 1.0   2024-05-24   divyam.gupta@samsung.com   Initial Version for MYSALES-264
        **/
public class knoxCreateScheduleTask implements Queueable,Database.AllowsCallouts {
    
    public String taskid;
    public knoxCreateScheduleTask(String taskid){        
        this.taskid = taskid;
        
    }    

    public void execute(QueueableContext context){
        IF_Log ifLog = new IF_Log();
        IF_Log.InterfaceLog interfaceLog;

        String APEX_CLASS   = 'IF_KnoxTaskCallOutAPIController';
        String METHOD_NAME  = 'doCalloutSendingTaskInfo';
        String INTERFACE_ID = 'IF-193';

        Map<String,Object> resMap = new Map<String,Object>();
       
        String guId = IF_KnoxChatSendController.generateUid();
        IF_Callout call = new IF_Callout(INTERFACE_ID);
        
        Task taskObj = [SELECT Id,
                               Knox_Calendar_Id__c,
                               Taskalertmsg__c, 
                               Knox_Schedule_ID__c, 
                               Subject, 
                               ActivityDate,
                               CreatedDate,
                               Description,
                               OwnerId,
                               Owner.Email,
                               PrivateTask__c 
                          FROM Task
                         WHERE id =: taskid];


        List<String> userEmail = UserInfo.getUserEmail().split('@');
        String userId = userEmail[0];

        User loginUser = [SELECT Id,
                                 CalendarID__c,
                                 FederationIdentifier,
                                 Task_CalendarId__c 
                            FROM User 
                           WHERE Id=:UserInfo.getUserId()];

        String userTimeZone = String.valueOf(UserInfo.getTimeZone());        

        try {

                IF_KnoxCalendar scheduleInfo = new IF_KnoxCalendar();

                scheduleInfo.invitedYn = null;
                scheduleInfo.subject = taskObj.Subject;
                scheduleInfo.originalStartTime = null;
                scheduleInfo.originalScheduleId = null;
                scheduleInfo.priority = '5';
                scheduleInfo.userId = userId;
                scheduleInfo.sendMailYn = null;
                scheduleInfo.recurrence = null;
                scheduleInfo.calendarId = loginUser.Task_CalendarId__c; //'CALM230315081100C6N7454';//loginUser.CalendarID__c;
                
                scheduleInfo.contentsType = 'Text';
                scheduleInfo.contents = taskObj.Description;
                scheduleInfo.authority = 'ALL';
                scheduleInfo.contentsCharset = 'UTF-8';
                scheduleInfo.allDayYn = 'Y';  
                scheduleInfo.place = '';

                scheduleInfo.outClass = taskObj.PrivateTask__c ? 'PRIVATE' : 'PUBLIC';
                scheduleInfo.placeCode = '';
                
                IF_KnoxCalendar.KnoxTime startTime = new IF_KnoxCalendar.KnoxTime();   

                startTime.xdate = dateTimeToDateString(taskObj.ActivityDate);  
                startTime.knoxDateTime = datetimeToString_ISO8601(taskObj.CreatedDate);                 
                startTime.timeZone =  userTimeZone;    

                scheduleInfo.startTime = startTime;

				//StartTime-----End----                 
                IF_KnoxCalendar.KnoxTime endTime = new IF_KnoxCalendar.KnoxTime();
               
                endTime.xdate = dateTimeToDateString(taskObj.ActivityDate);               
                endTime.knoxDateTime = datetimeToString_ISO8601(taskObj.CreatedDate);                
                endTime.timeZone = userTimeZone;    

                scheduleInfo.endTime = endTime;
                
                system.debug('ScheduleInfo_________' + scheduleInfo);
                String jsonBody = JSON.serialize(scheduleInfo);  
                jsonBody = jsonBody.replace('knoxDateTime', 'dateTime');
                jsonBody = jsonBody.replace('xdate', 'date');
                jsonBody = jsonBody.replace('outclass', 'class');

                String urlParam = '/' + loginUser.Task_CalendarId__c + '/schedules/create?userId=' + userId;
                resMap = call.httpKnoxCallout(jsonBody,urlParam);
                system.debug('resMap===>'+resMap);

                HttpResponse response = (HttpResponse)resMap.get('HttpResponse');
                System.debug('request : '+resMap.get('Request')); 
                System.debug('response : '+resMap.get('Response'));

                String jsonResponse = response.getBody();
                system.debug('Jsonresonsecoming-->'+jsonResponse);
                
                
                if(response.getStatusCode() == 200){
                    String knoxCalendarId;
                    String scheduleId;
                    Map<String,Object> jsonMap = (Map<String,object>) JSON.deserializeUntyped(jsonResponse);
             
                    if(jsonMap != null){
                        scheduleId = (String) jsonMap.get('scheduleId');
                        knoxCalendarId = (String) jsonMap.get('calendarId');                      }
              		    System.debug('SJOSHI>>'+scheduleId);
                    
                        
                        taskObj.Knox_Schedule_ID__c = scheduleId;
                        taskObj.Knox_Calendar_Id__c = knoxCalendarId;

                        if(scheduleId != null &&  String.isNotBlank(scheduleId)){
                            update taskObj;
                        }

                        interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));

                    } else {
                        List<String> errList = new List<String>();
                        taskObj.Taskalertmsg__c =true;
                        update taskObj;
                        interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')),errList);
                    }
        } catch (Exception e){
                ifLog.addLog('Exception : ' + e.getMessage());
                // errorMsgList.add('Exception : ' + e.getMessage());           
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')), e);          
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