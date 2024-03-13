/**
 * @description       : 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-03-31
 * @last modified by  : hj.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2020-12-08   hj.lee@dkbmc.com   Initial Version
**/
public class EventTriggerHelper implements Queueable, Database.AllowsCallouts {
    @testVisible
    private static Boolean doChainJob = !Test.isRunningTest();

    public List<Event> eventList; 
    public Map<Id, Event> eventMap;
    public TriggerOperation triggerType;
    public Employee__c emp;

    public static Boolean isPassed = false;

    public EventTriggerHelper() { }

    public EventTriggerHelper(List<Event> eventList, Map<Id, Event> eventMap, TriggerOperation triggerType, Employee__c emp) {
        this.eventList = eventList;
        this.eventMap = eventMap;
        this.triggerType = triggerType;
        this.emp = emp;
    }

    public void execute(QueueableContext context) {
        System.debug('─────────────────────────────────────────────────────────────');
        System.debug('triggerType : ' + triggerType);
        System.debug('─────────────────────────────────────────────────────────────');
        switch on triggerType {
            when AFTER_INSERT {
                getEventCalendarId();   // Chain Queue Job
            }
            when AFTER_UPDATE {
                if(doChainJob) System.enqueueJob(new EventKnoxUpdateScheduleQueue(eventList, eventMap, emp));

            }
            when AFTER_DELETE {
                if(doChainJob) System.enqueueJob(new EventKnoxDeleteScheduleQueue(eventList, emp));
                
            }
        }
    }

    
    /**
     * CREATE-1. [Call Out] Knox 캘린더 조회 (IF_KnoxGetCalendarsController)
     */
    public void getEventCalendarId() {
        Map<String, Object> eventMap = new Map<String, Object>();
        for(Event evt : eventList) {
            String knoxId = emp.EvMailAddr__c.split('@')[0];
            IF_KnoxGetCalendarsController.InputClass input_calendar = new IF_KnoxGetCalendarsController.InputClass();
            input_calendar.userId = knoxId;

            Map<String, Object> output_calendar = (Map<String, Object>)IF_KnoxGetCalendarsController.getCalendars(input_calendar);
            system.debug('## output_calendar : ' +  output_calendar);

            Integer statusCode = Integer.valueOf(output_calendar.get('statusCode'));
            String result = String.valueOf(output_calendar.get('result'));
            List<Object> calendarList = (List<Object>)output_calendar.get('data');
            String calendarId = '';

            if(statusCode >= 300 || result != 'success') {
                continue;
            }
            
            if(calendarList == null) {
                continue;
            }

            // 기본 캘린더 ('seq':'0') 찾기
            for(Object calendar : calendarList) {
                Map<String, Object> caleandarMap = (Map<String, Object>)calendar;
                if( (String)caleandarMap.get('seq') == '0') {
                    calendarId = (String)caleandarMap.get('calendarId');
                    break;
                }
            }
            // calendarId, knoxId Data 
            Map<String, String> eventInfoMap = new Map<String, String>(); 
            eventInfoMap.put('calendarId', calendarId);
            eventInfoMap.put('knoxId', knoxId);

            eventMap.put(evt.Id, eventInfoMap);
        }

        if(doChainJob && eventList.size() > 0) {
            System.enqueueJob(new EventKnoxCreateScheduleQueue(eventList, eventMap));
        }
    }


    /**
     * CREATE-2. [Call Out] Knox 일정 등록 요청 (IF_KnoxCreateScheduleController)
    **/
    public class EventKnoxCreateScheduleQueue implements Queueable, Database.AllowsCallouts {
        public List<Event> eventList;
        public Map<String, Object> eventMap;
        public EventKnoxCreateScheduleQueue(List<Event> eventList, Map<String, Object> eventMap) {
            this.eventList = eventList;
            this.eventMap = eventMap;
        }
        public void execute(QueueableContext context) {
      
            List<Event> updateEventList = new List<Event>();
            for(Event evt : eventList) {
                Map<String, String> eventInfoMap = (Map<String, String>)eventMap.get(evt.Id);
                if(eventInfoMap == null) continue;

                String calendarId = eventInfoMap.get('calendarId');
                String knoxId = eventInfoMap.get('knoxId');
            
                IF_KnoxCreateScheduleController.InputClass inputParam = new IF_KnoxCreateScheduleController.InputClass();
                InputParam.System_ID = null;
                InputParam.calendarId = calendarId;
                InputParam.userId = knoxId;

                IF_KnoxCreateScheduleController.ScheduleInfo scheduleInfo = new IF_KnoxCreateScheduleController.ScheduleInfo();
                scheduleInfo.invitedYn = '';
                scheduleInfo.subject = evt.Subject;
                scheduleInfo.originalStartTime = '';
                scheduleInfo.originalScheduleId = '';
                scheduleInfo.priority = '5';
                scheduleInfo.userId = knoxId;
                scheduleInfo.sendMailYn = '';
                scheduleInfo.recurrence = '';
                scheduleInfo.calendarId = calendarId;
                scheduleInfo.contentsType = 'Text';
                scheduleInfo.contents = evt.Description;
                scheduleInfo.authority = '';
                scheduleInfo.contentsCharset = 'UTF-8';
                scheduleInfo.allDayYn = evt.IsAllDayEvent ? 'Y' : 'N';  
                scheduleInfo.place = '';
                scheduleInfo.class_SFDC = '';
                scheduleInfo.placeCode = '';

                // Time Setting
                String userTimeZone = String.valueOf(UserInfo.getTimeZone());

                //  date	    날짜 yyyy-MM-dd (하루종일 일정의 경우만 입력)
                //  dateTime	날짜시간 yyyy-MM-ddTHH:mm:ssTZD (ISO8601)
                IF_KnoxCreateScheduleController.TimeTable startTime = new IF_KnoxCreateScheduleController.TimeTable();
                startTime.date_SFDC     = evt.IsAllDayEvent  ? EventTriggerHelper.dateTimeToDateString(evt.StartDateTime) : '';
                startTime.dateTime_SFDC = !evt.IsAllDayEvent ? EventTriggerHelper.datetimeToString_ISO8601(evt.StartDateTime) : ''; // 2018-08-09T12:00:00+09:00
                startTime.timeZone = userTimeZone;
                
                IF_KnoxCreateScheduleController.TimeTable endTime = new IF_KnoxCreateScheduleController.TimeTable();
                endTime.date_SFDC     = evt.IsAllDayEvent  ? EventTriggerHelper.dateTimeToDateString(evt.EndDateTime)  : '';
                endTime.dateTime_SFDC = !evt.IsAllDayEvent ? EventTriggerHelper.datetimeToString_ISO8601(evt.EndDateTime): ''; // 2018-08-09T12:00:00+09:00
                endTime.timeZone = userTimeZone;
                
                scheduleInfo.startTime = startTime;
                scheduleInfo.endTime = endTime;
                
                // scheduleInfo.attendees = null; // 참석자 리스트는 일정 수정 시 insert
                inputParam.ScheduleInfo = scheduleInfo;

                Map<String,Object> output = (Map<String,Object>)IF_KnoxCreateScheduleController.createSchedule(InputParam);
                // System.debug('output ' + output);
                
                String outputResult = (String)output.get('result');
                if(outputResult == 'success') {
                    Map<String, Object> outputData = (Map<String, Object>)output.get('data');
                    String scheduleId = (String)outputData.get('scheduleId');
                    
                    // Event ReadOnly 이므로 새로운 Event를 생성하여 Update List 에 넣어줌
                    Event cloneEvent = new Event();
                    cloneEvent.Id = evt.Id;
                    cloneEvent.CalendarId__c = calendarId;
                    cloneEvent.ScheduleId__c = scheduleId;
                    updateEventList.add(cloneEvent);
                }else {
                    // 에러처리
                }
            }

            if(doChainJob && updateEventList.size() > 0)  {
                system.enqueueJob(new EventUpdateScheuldeIdQueue(updateEventList));
            }
        }
    }

    /**
     * CREATE-3. [DML] Event Update Knox Schedule Id 
     */
    public class EventUpdateScheuldeIdQueue implements Queueable {
        public List<Event> updateList;
        public EventUpdateScheuldeIdQueue(List<Event> updateList) {
            this.updateList = updateList;
        }
        public void execute(QueueableContext context) {
            update updateList;
        }
    }

    /**
     * UPDATE-1. [Call Out] Knox 일정 수정
     */
    public class EventKnoxUpdateScheduleQueue implements Queueable, Database.AllowsCallouts {
        public List<Event> newList;
        public Map<Id, Event> eventMap;
        public Employee__c emp;

        public EventKnoxUpdateScheduleQueue(List<Event> newList, Map<Id, Event> eventMap, Employee__c emp) {
            this.newList = newList;
            this.eventMap = eventMap;
            this.emp = emp;
        }

        public void execute(QueueableContext context) {
            List<Event> updateEventList = new List<Event>();
            for(Event evt : newList) {

                system.debug('# EventKnoxUpdateScheduleQueue');
                system.debug('# newList.size: ' + newList.size());
                
                Event oldEvt = eventMap.get(evt.Id);
                Boolean isCreateTransaction = String.isBlank(oldEvt.ScheduleId__c) && !String.isBlank(evt.ScheduleId__c);  // Insert 에서 이루어지는 Event Update Pass

                if(isCreateTransaction)  {
                    system.debug(' Knox Schedule Update PASS ');
                    
                } else if ( String.isBlank(evt.ScheduleId__c) ) {
                    system.debug(' Knox Schedule Update PASS ');

                } else {
                    String knoxId = emp.EvMailAddr__c.split('@')[0];
                    IF_KnoxUpdateScheduleController.InputClass inputParam = new IF_KnoxUpdateScheduleController.InputClass();
                    InputParam.System_ID = null;
                    InputParam.calendarId = evt.CalendarId__c;
                    InputParam.scheduleId = evt.ScheduleId__c;
                    InputParam.recurrenceModType = 'ONE';
                    InputParam.userId = knoxId;

                    IF_KnoxUpdateScheduleController.ScheduleInfo scheduleInfo = new IF_KnoxUpdateScheduleController.ScheduleInfo();
                    scheduleInfo.invitedYn = '';
                    scheduleInfo.subject = evt.Subject;
                    scheduleInfo.originalStartTime = '';
                    scheduleInfo.originalScheduleId = '';
                    scheduleInfo.priority = '5';
                    scheduleInfo.userId = knoxId;
                    scheduleInfo.sendMailYn = '';
                    scheduleInfo.recurrence = '';
                    scheduleInfo.calendarId = evt.CalendarId__c;
                    scheduleInfo.contentsType = 'Text';
                    scheduleInfo.contents = evt.Description;
                    scheduleInfo.authority = '';
                    scheduleInfo.contentsCharset = 'UTF-8';
                    scheduleInfo.allDayYn = evt.IsAllDayEvent ? 'Y' : 'N';  
                    scheduleInfo.place = '';
                    scheduleInfo.class_SFDC = '';
                    scheduleInfo.placeCode = '';

                    // ───────────────────────────── Time Setting
                    String userTimeZone = String.valueOf(UserInfo.getTimeZone());

                    IF_KnoxUpdateScheduleController.TimeTable startTime = new IF_KnoxUpdateScheduleController.TimeTable();
                    startTime.date_SFDC     = evt.IsAllDayEvent  ? EventTriggerHelper.dateTimeToDateString(evt.StartDateTime) : '';     // 2018-08-09
                    startTime.dateTime_SFDC = !evt.IsAllDayEvent ? EventTriggerHelper.datetimeToString_ISO8601(evt.StartDateTime) : ''; // 2018-08-09T12:00:00+09:00
                    startTime.timeZone = userTimeZone;
                    
                    IF_KnoxUpdateScheduleController.TimeTable endTime = new IF_KnoxUpdateScheduleController.TimeTable();
                    endTime.date_SFDC     = evt.IsAllDayEvent  ? EventTriggerHelper.dateTimeToDateString(evt.EndDateTime) : '';      // 2018-08-09
                    endTime.dateTime_SFDC = !evt.IsAllDayEvent ? EventTriggerHelper.datetimeToString_ISO8601(evt.EndDateTime)  : ''; // 2018-08-09T12:00:00+09:00
                    endTime.timeZone = userTimeZone;

                    scheduleInfo.startTime = startTime;
                    scheduleInfo.endTime = endTime;
                    
                    // ───────────────────────────── 참석자 리스트
                    List<IF_KnoxUpdateScheduleController.Attendees> attendees = new List<IF_KnoxUpdateScheduleController.Attendees>();
                    // 작성자 본인 추가
                    IF_KnoxUpdateScheduleController.Attendees ownerAttendee = new IF_KnoxUpdateScheduleController.Attendees();
                    ownerAttendee.sourceType = 'EMPLOYEE';
                    ownerAttendee.replyStatus = 'ACCEPTED';
                    ownerAttendee.type = 'CHAIR';
                    ownerAttendee.userId = emp.EvUniqID__c;      // EP ID 
                    ownerAttendee.seq = '0';
                    attendees.add(ownerAttendee);

                    // 이벤트 참석자 추가
                    IF_KnoxUpdateScheduleController.Attendees eventAttendee = new IF_KnoxUpdateScheduleController.Attendees();
                    List<EventRelation> eventAttendeeList = [
                        SELECT  Id, RelationId, Relation.Name, RespondedDate, Response, Status 
                        FROM    EventRelation 
                        WHERE   EventId = :evt.Id 
                            AND Relation.Type = 'User'
                        ORDER BY CreatedDate ASC
                    ];
                    Set<Id> attendeeUserIdSet = new Set<Id>();

                    for(EventRelation er : eventAttendeeList) {
                        attendeeUserIdSet.add(er.RelationId);
                    }
                    List<User> attendeeList = [
                        SELECT  Id, FederationIdentifier 
                        FROM    User
                        WHERE   Id IN :attendeeUserIdSet
                            AND FederationIdentifier != ''
                    ];
                    Integer attendeeNo = 1;
                    for(User attendeeUser : attendeeList) {
                        eventAttendee = new IF_KnoxUpdateScheduleController.Attendees();
                        eventAttendee.sourceType = 'EMPLOYEE';
                        eventAttendee.replyStatus = 'NEEDS_ACTION';     // 상태 [NEEDS_ACTION, ACCEPTED, DECLINED, TENTATIVE, OCCUPIED]
                        eventAttendee.type = 'REQ_PARTICIPANT';         // 참석자 타입   [REQ_PARTICIPANT, OPT_PARTICIPANT, NON_PARTICIPANT]
                        eventAttendee.userId = attendeeUser.FederationIdentifier;
                        eventAttendee.seq = String.valueOf(attendeeNo++);

                        attendees.add(eventAttendee);
                    }

                    // "attendees": [
                    //           {
                    //     "sourceType": "EMPLOYEE",
                    //     "replyStatus": "ACCEPTED",
                    //     "type": "CHAIR",
                    //     "userId": "R020218102320C601014",
                    //     "seq": "0"
                    // },

                    // ]
                    // ───────────────────────────── /참석자 리스트

                    scheduleInfo.attendees = attendees;
                    inputParam.scheduleInfo = scheduleInfo;

                    Map<String,Object> output = (Map<String,Object>)IF_KnoxUpdateScheduleController.updateSchedule(InputParam);
                    // System.debug('output ' + output);
                    String outputResult = (String)output.get('result');
                    if(outputResult == 'success') {
                        List<Object> outputData = (List<Object>)output.get('data');
                        
                    
                    }else {
                        // 에러처리

                    }
                }
            }
        }
    }

    /**
     * DELETE-1. [Call Out] Knox 일정 삭제
     */
    public class EventKnoxDeleteScheduleQueue implements Queueable, Database.AllowsCallouts {
        public List<Event> eventList;
        public Employee__c emp;

        public EventKnoxDeleteScheduleQueue(List<Event> eventList, Employee__c emp) {
            this.eventList = eventList;
            this.emp = emp;
        }

        public void execute(QueueableContext context) {
            for(Event evt : eventList) {
                if(String.isBlank(evt.CalendarId__c) || String.isBlank(evt.ScheduleId__c)) {
                    continue;
                }
                
                IF_KnoxDeleteScheduleController.InputClass inputParam = new IF_KnoxDeleteScheduleController.InputClass();
                inputParam.calendarId = evt.CalendarId__c;
                inputParam.scheduleId = evt.ScheduleId__c;
                inputParam.userId = emp.EvMailAddr__c.split('@')[0];

                Map<String, Object> output = (Map<String, Object>)IF_KnoxDeleteScheduleController.deleteSchedule(inputParam);
                String outputResult = (String)output.get('result');
                if(outputResult == 'success') {
                    Map<String, Object> outputData = (Map<String, Object>)output.get('data');
                  
                }else {
                    // 에러처리
                    
                }
            }
        }

    }

    /**
     * Datetime 을 ISO8601 String 으로 변환  
     * ex) 2018-08-09T12:00:00+09:00 : User Local Time(String format 변환시 자동 변경)+UserTimeOffset
     */
    public static String datetimeToString_ISO8601(Datetime dt){
        String datetimeString_ISO8601 = '';

        String timeZoneDisplayName = UserInfo.getTimeZone().getDisplayName();               // (GMT+09:00) Korean Standard Time (Asia/Seoul)
        String timeOffset = timeZoneDisplayName.removeStart('(GMT').substringBefore(')');   // +09:00

        datetimeString_ISO8601 = dt.format('yyyy-MM-dd\'T\'HH:mm:ss') + timeOffset;
        return datetimeString_ISO8601;
    }
    
    /**
     * Datetime의 Date 부분만 String 으로 반환 (User Local Time 적용하지 않음)
     * 2021-03-30 00:00:00 → 2021-03-30
     */
    public static String dateTimeToDateString(Datetime dt){
        if(dt == null) return null;
        String strDate = (dt + '').substring(0, 10);
        return strDate;
    }

}