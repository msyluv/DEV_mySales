public class knoxCreateScheduleQuableClass implements Queueable, Database.AllowsCallouts {
	public boolean isCheck = false;    
    public String eventId;

    public knoxCreateScheduleQuableClass(String newTask){        
        this.eventId = newTask;
        
    }

    public void execute(QueueableContext context) { 
        IF_Log ifLog = new IF_Log();
        IF_Log.InterfaceLog interfaceLog;
        String APEX_CLASS   = 'KnoxCreateScheduleQuableClass';
        String METHOD_NAME  = 'excute';
        String INTERFACE_ID = 'IF-193';
        Map<String,Object> resMap = new Map<String,Object>();
       String guId = IF_KnoxChatSendController.generateUid();
        
        HttpResponse res;
        IF_Callout call = new IF_Callout(INTERFACE_ID);
        
        
        Event eventObj =[SELECT Id,
                                Subject,
                                ActivityDate,
                                StartDateTime,
                                EndDateTime,
                                OwnerId,
                                Owner.Email,Location,
                                Description,
                                IsAllDayEvent,
                                IsPrivate 
                           FROM Event 
                          WHERE Id =:eventId];

        system.debug('eventObj________' + eventObj);            

        List<String> userEmail = UserInfo.getUserEmail().split('@');
        String userId = userEmail[0];

        User loginUser = [SELECT Id,
                                 CalendarID__c,
                                 FederationIdentifier 
                            FROM User 
                           WHERE Id=:UserInfo.getUserId()];

        String userTimeZone = String.valueOf(UserInfo.getTimeZone());        

        IF_KnoxCalendar scheduleInfo = New IF_KnoxCalendar();

        try {
                if(eventObj != null) {
                    scheduleInfo.invitedYn = null;
                    scheduleInfo.subject = eventObj.Subject;
                    scheduleInfo.originalStartTime = null;
                    scheduleInfo.originalScheduleId = null;
                    scheduleInfo.priority = '5';
                    scheduleInfo.userId = userId;
                    scheduleInfo.sendMailYn = null;
                    scheduleInfo.recurrence = null;
                    scheduleInfo.calendarId = loginUser.CalendarID__c; //'CALM230315081100C6N7454';//loginUser.CalendarID__c;
                        
                    scheduleInfo.contentsType = 'Text';
                    scheduleInfo.contents = eventObj.Description;
                    scheduleInfo.authority = 'ALL';
                    scheduleInfo.contentsCharset = 'UTF-8';
                    scheduleInfo.allDayYn = eventObj.IsAllDayEvent ? 'Y' : 'N';  
                    scheduleInfo.place = eventObj.Location;
                    
                    scheduleInfo.outClass = eventObj.IsPrivate ? 'PRIVATE' : 'PUBLIC';
                    scheduleInfo.placeCode = eventObj.Location;
                                
                    scheduleInfo.startTime.xdate = dateTimeToDateString(eventObj.StartDateTime);  
                    scheduleInfo.startTime.knoxDateTime = !eventObj.IsAllDayEvent ? datetimeToString_ISO8601(eventObj.StartDateTime) : '';                 
                    scheduleInfo.startTime.timeZone =  userTimeZone;            
                    
                    scheduleInfo.endTime.xdate = dateTimeToDateString(eventObj.EndDateTime);               
                    scheduleInfo.endTime.knoxDateTime = !eventObj.IsAllDayEvent ? datetimeToString_ISO8601(eventObj.EndDateTime) : '';                
                    scheduleInfo.endTime.timeZone =  userTimeZone;    

                    scheduleInfo.attendees = null;
                }

                system.debug('ScheduleInfo_________' + scheduleInfo);

                String jsonBody = JSON.serialize(scheduleInfo);              
                jsonBody = jsonBody.replace('knoxDateTime', 'dateTime');
                jsonBody = jsonBody.replace('xdate', 'date');
                jsonBody = jsonBody.replace('outclass', 'class');
                system.debug('jsonBody_________' + jsonBody);
                
                String urlParam = '/' + loginUser.CalendarID__c + '/schedules/create?userId=' + userId;

                resMap = call.httpKnoxCallout(jsonBody, urlParam);
                system.debug('resMap===>'+resMap);
                HttpResponse response = (HttpResponse)resMap.get('HttpResponse');
                System.debug('request : '+resMap.get('Request')); 
                System.debug('response : '+resMap.get('Response'));
                String jsonResponse = response.getBody();
                system.debug('Jsonresonsecoming-->'+jsonResponse);


                if(response.getStatusCode() == 200){
                    String scheduleId;
                    String knoxCalendarId ='';

                    Map<String,Object> jsonMap = (Map<String,object>)JSON.deserializeUntyped(jsonResponse);
                    system.debug('jsonMap____' + jsonMap);
                            
                    //[SJOSHI]Start
                            
                    if(jsonMap != null){
                        scheduleId = (String) jsonMap.get('scheduleId');
                        knoxCalendarId = (String) jsonMap.get('calendarId');                      
                    }

                    System.debug('SJOSHI>>'+scheduleId);
                    //[SJOSHI]End
                    
                    Event e = [SELECT Id,
                                      Knox_Schedule_ID__c,
                                      Knox_Calendar_Id__c 
                                 FROM Event 
                                WHERE ID =: eventId];        

                    e.Knox_Schedule_ID__c = scheduleId;
                    e.Knox_Calendar_Id__c = knoxCalendarId;
                    isCheck = true;        

                    if(scheduleId != null &&  String.isNotBlank(scheduleId)){
                        update e;
                    }

                    interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));

                } else {
                    List<String> errList = new List<String>();
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
    
}