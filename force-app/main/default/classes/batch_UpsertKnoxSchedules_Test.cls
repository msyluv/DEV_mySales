@isTest
public class batch_UpsertKnoxSchedules_Test {

    @TestSetup
    static void setData(){
        
        Event e = new Event();
        e.Subject = 'Meeting01';
        e.StartDateTime = Date.valueOf('2023-12-19T16:30:00+09:00');
        e.EndDateTime = Date.valueOf('2023-12-19T17:00:00+09:00');
        e.Location = 'Korea';
        e.Description ='Test1';
        e.ActivityDateTime = Date.valueof('2023-12-19T17:00:00+09:00');
        e.Type = 'CHAIR';
        e.Knox_Schedule_ID__c = 'SCH202312180702227266826011';
        e.DurationInMinutes = 0;
        e.IsAllDayEvent = false;
        
        insert e;

        Event indiaEvent = new Event();
        indiaEvent.Subject = 'Meeting01';
        indiaEvent.Location = 'India';
        indiaEvent.Description ='Test1';
        indiaEvent.ActivityDateTime = Date.valueof('2023-12-19T17:00:00+07:00');
        indiaEvent.Type = 'CHAIR';
        indiaEvent.DurationInMinutes = 0;
        indiaEvent.IsAllDayEvent = false;
        indiaEvent.Knox_Schedule_ID__c = 'SCH202312180702227266826013';
        indiaEvent.StartDateTime = Date.valueOf('2023-12-19T16:30:00+07:00');
        indiaEvent.EndDateTime = Date.valueOf('2023-12-19T17:00:00+07:00');

        insert indiaEvent;

        Event allDayEvent = new Event();
        allDayEvent.Subject = 'Meeting01';
        allDayEvent.StartDateTime = Date.valueOf('2024-05-22T00:00:00+00:00');
        allDayEvent.EndDateTime = Date.valueOf('2024-05-22T00:00:00+00:00');
        allDayEvent.Location = 'Korea';
        allDayEvent.Description ='Test1';
        allDayEvent.ActivityDateTime = Date.valueof('2024-05-22T00:00:00+00:00');
        allDayEvent.Type = 'CHAIR';
        allDayEvent.Knox_Schedule_ID__c = 'SCH202312180702227266826014';
        allDayEvent.DurationInMinutes = 1440;
        allDayEvent.IsAllDayEvent = true;

        insert allDayEvent;

        Task taskObj = new Task();

        taskObj.Knox_Schedule_ID__c = 'SCH202312180702227266826011';
        taskObj.Subject = 'test';
        taskObj.Description = 'test';
        taskObj.PrivateTask__c = false;
        taskObj.ActivityDate = Date.valueof('2024-04-25');

        insert taskObj;
    }

    @isTest
    static void testBatchUpsertSchedule(){
        
        Map<String,String> startDateTimeMap = new Map<String,String>();
        startDateTimeMap.put('SCH202312180702227266826011','2023-12-19T16:30:00+09:00');
        startDateTimeMap.put('SCH202312180702227266826012','2023-12-19T16:30:00+09:00');


        List<String> knoxScheduleIdList = new List<String>();
        knoxScheduleIdList.add('SCH202312180702227266826011');
        knoxScheduleIdList.add('SCH202312180702227266826012');

        Map<String,String> startDateMap = new Map<String,String>{'SCH202312180702227266826011' => '2023-12-19',
                                                                 'SCH202312180702227266826012' => '2023-12-19'};

        Map<String,String> endDateMap = new  Map<String,String>{'SCH202312180702227266826011' => '2023-12-19', 
                                                                'SCH202312180702227266826012' => '2023-12-19'};

        Map<String,String> endDateTimeMap = new Map<String,String>{'SCH202312180702227266826011' => '2023-12-19T16:30:00+09:00', 
                                                                   'SCH202312180702227266826012' => '2023-12-19T16:30:00+09:00'};


        IF_KnoxCalendar tempObj = new IF_KnoxCalendar();
        
        tempObj.allDayYn = 'N';
        tempObj.authority = 'ALL';
        tempObj.calendarId = 'CAL202312141037198851625229';
        tempObj.outclass = 'PUBLIC';
        tempObj.contents = 'test1';
        tempObj.contentsType = 'MIME';
        tempObj.invitedYn = 'N';
        tempObj.scheduleId = 'SCH202312180702227266826011';

        User userObj = [SELECT id,
                               Synchronize_task__c,
                               Task_CalendarId__c,
                               FederationIdentifier 
                          FROM user 
                         WHERE id =: UserInfo.getUserId()];

        tempObj.userId = userObj.FederationIdentifier;


        IF_KnoxCalendar.KnoxTime timeObj = new IF_KnoxCalendar.KnoxTime();
        timeObj.knoxDateTime = '2023-12-19T17:00:00+09:00';
        timeObj.timeZone = 'Asia/Seoul';

        tempObj.endTime = timeObj;

        tempObj.startTime = timeObj;

        IF_KnoxCalendar.TaskAttendees attendee = new IF_KnoxCalendar.TaskAttendees();

        attendee.sourceType = 'EMPLOYEE';
        attendee.displayName = 'Divyam Gupta/Engineer/Global Solution Part/SDSI';
        attendee.replyStatus = 'ACCEPTED';
        attendee.type = 'CHAIR';
        

        attendee.userId = userObj.FederationIdentifier;
        attendee.email = 'divyam.gupta@stage.samsung.com';
        attendee.seq = 0;

        tempObj.attendees.add(attendee);


        Map<String, IF_KnoxCalendar> knoxScheduleMap = new Map<String, IF_KnoxCalendar>();
        knoxScheduleMap.put('SCH202312180702227266826011', tempObj);

        tempObj.scheduleId = 'SCH202312180702227266826012';
        knoxScheduleMap.put('SCH202312180702227266826012', tempObj);
        
        Test.startTest();
        
        batch_UpsertKnoxSchedules upsertObject = new batch_UpsertKnoxSchedules(knoxScheduleMap, endDateTimeMap, endDateMap, knoxScheduleIdList, startDateTimeMap, startDateMap);
        Id batchJobId = Database.executeBatch(upsertObject);
        
        Test.stopTest();
    }

    @isTest
    static void testDifferentTimeZoneSchedule(){
        
        Map<String,String> startDateTimeMap = new Map<String,String>();
        startDateTimeMap.put('SCH202312180702227266826013','2023-12-19T16:30:00+07:00');


        List<String> knoxScheduleIdList = new List<String>();
        knoxScheduleIdList.add('SCH202312180702227266826013');

        Map<String,String> startDateMap = new Map<String,String>{'SCH202312180702227266826013' => '2023-12-19'};

        Map<String,String> endDateMap = new  Map<String,String>{'SCH202312180702227266826013' => '2023-12-19'};

        Map<String,String> endDateTimeMap = new Map<String,String>{'SCH202312180702227266826013' => '2023-12-19T17:00:00+07:00'};


        IF_KnoxCalendar tempObj = new IF_KnoxCalendar();
        
        tempObj.allDayYn = 'N';
        tempObj.authority = 'ALL';
        tempObj.calendarId = 'CAL202312141037198851625229';
        tempObj.outclass = 'PRIVATE';
        tempObj.contents = 'test1';
        tempObj.contentsType = 'MIME';
        tempObj.invitedYn = 'N';
        tempObj.scheduleId = 'SCH202312180702227266826013';

        User userObj = [SELECT id,
                               Synchronize_task__c,
                               Task_CalendarId__c,
                               FederationIdentifier 
                          FROM user 
                         WHERE id =: UserInfo.getUserId()];

        tempObj.userId = userObj.FederationIdentifier;


        IF_KnoxCalendar.KnoxTime startTimeObj = new IF_KnoxCalendar.KnoxTime();
        startTimeObj.knoxDateTime = '2023-12-19T16:30:00+07:00';
        startTimeObj.timeZone = 'Asia/Kolkata"';

    
        tempObj.startTime = startTimeObj;

        IF_KnoxCalendar.KnoxTime endTimeObj = new IF_KnoxCalendar.KnoxTime();
        endTimeObj.knoxDateTime = '2023-12-19T17:00:00+07:00';
        endTimeObj.timeZone = 'Asia/Kolkata"';
        tempObj.endTime = endTimeObj;

        IF_KnoxCalendar.TaskAttendees attendee = new IF_KnoxCalendar.TaskAttendees();

        attendee.sourceType = 'EMPLOYEE';
        attendee.displayName = 'Divyam Gupta/Engineer/Global Solution Part/SDSI';
        attendee.replyStatus = 'ACCEPTED';
        attendee.type = 'CHAIR';
        

        attendee.userId = userObj.FederationIdentifier;
        attendee.email = 'divyam.gupta@stage.samsung.com';
        attendee.seq = 0;

        tempObj.attendees.add(attendee);

        tempObj.recurrence = null;

        Map<String, IF_KnoxCalendar> knoxScheduleMap = new Map<String, IF_KnoxCalendar>();
        knoxScheduleMap.put('SCH202312180702227266826013', tempObj);

        
        Test.startTest();
        
        batch_UpsertKnoxSchedules upsertObject = new batch_UpsertKnoxSchedules(knoxScheduleMap, endDateTimeMap, endDateMap, knoxScheduleIdList, startDateTimeMap, startDateMap);
        Id batchJobId = Database.executeBatch(upsertObject);
        
        Test.stopTest();
    }
}