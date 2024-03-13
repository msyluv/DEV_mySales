/**
 * @description       : 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 01-21-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2021-01-19   hj.lee@dkbmc.com   Initial Version
**/
@isTest
public class EventTrigger_Test {
    static User salesRepHqUser1;
    static User salesRepLogiUser1;
    static Employee__c emp1;
    static Employee__c emp2;

    static{
        // [Trigger Switch Setting ] Default Org Switch Setup
        TriggerSwitch__c trSwitch_default = new TriggerSwitch__c();
        insert trSwitch_default;


        // 임직원 및 User Setting
        emp1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'EPID1');
        salesRepHqUser1 = Utils_TestDataFactory.createUserFull(
                Utils_TestDataFactory.getProfile('Sales Rep.(HQ)')
                , emp1.EvMailAddr__c
                , emp1.EvUniqID__c);

        // 임직원 및 User Setting
        emp2 = Utils_TestDataFactory.createEmployee('TestEmp2', 'EPID2');
        salesRepLogiUser1 = Utils_TestDataFactory.createUserFull(
                Utils_TestDataFactory.getProfile('Sales Rep.(Logi)')
                , emp2.EvMailAddr__c
                , emp2.EvUniqID__c);

        String calendarId = 'caleandarId';
        List<Event> eventList = new List<Event>();
        
        datetime startDate = Datetime.newInstance(2020, 21 , 01, 00, 00, 00);
        datetime endDate = Datetime.newInstance(2020, 21 , 01, 01, 00, 00);
        Event evt = new Event(
            OwnerId = salesRepHqUser1.Id
            , Subject = 'Event 1'
            , StartDateTime = startDate
            , EndDateTime = endDate
            , DurationInMinutes = 60
            , CalendarId__c = calendarId
            , ScheduleId__c = 'ScheduleId1'
            , IsAllDayEvent = false,
             Knox_Schedule_ID__c ='1233344444444434'

        );
        eventList.add(evt);

        Event evt2 = new Event(
            OwnerId = salesRepHqUser1.Id
            , Subject = 'Event 2'
            , StartDateTime = startDate
            , EndDateTime = endDate
            , DurationInMinutes = 60
            , CalendarId__c = calendarId
            , ScheduleId__c = 'ScheduleId1'
            , IsAllDayEvent = false,
             Knox_Schedule_ID__c ='1233344444444444'

        );
        eventList.add(evt2);

        Event evt3 = new Event(
            OwnerId = salesRepHqUser1.Id
            , Subject = 'Event 3'
            , StartDateTime = startDate
            , EndDateTime = endDate
            , DurationInMinutes = 60
            , CalendarId__c = calendarId
            , ScheduleId__c = 'ScheduleId1'
            , IsAllDayEvent = false,
              Knox_Schedule_ID__c ='1233344444444484'

        );
        eventList.add(evt3);

        insert eventList;
       
        
    }

    @isTest
    static void eventTriggerTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        System.runAs(salesRepHqUser1) {
            
            Event evt = new Event();
            evt.Subject = 'Event 1';
            evt.StartDateTime = Datetime.newInstance(2020, 21 , 01, 00, 00, 00);
            evt.EndDateTime = Datetime.newInstance(2020, 21 , 01, 01, 00, 00);
            evt.DurationInMinutes = 60;
            evt.IsAllDayEvent = false;
            evt.Knox_Schedule_ID__c ='123334444444444';

            insert evt;
           
           update evt;
           
          //delete evt;

        }
        Test.stopTest();
    }

 
    @isTest
    static void eventTriggerHelperCreateTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        System.runAs(salesRepHqUser1) {


            
            
            List<Event> eventList = [SELECT Id, Subject, StartDateTime, EndDateTime, Description, ScheduleId__c, CalendarId__c,IsIF_152__c, IsAllDayEvent FROM Event limit 1];
            system.debug('eventlist-->'+eventList);
             eventList[0].Subject  = 'testsubject';
             eventList[0].IsIF_152__c = true;
             update eventList;
            /**
             Map<String, String> eventInfoMap = new Map<String, String>(); 
            eventInfoMap.put('calendarId', 'test');
            eventInfoMap.put('knoxId', 'test');
            

            Map<String, Object> eventMap = new Map<String, Object>();
            eventMap.put(eventList[0].id, eventInfoMap);


            System.enqueueJob(new EventTriggerHelper.EventKnoxCreateScheduleQueue(eventList, eventMap) );
               **/
        }
        Test.stopTest();
    }
    
   
    @isTest
    static void eventTriggerHelperUpdateTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        System.runAs(salesRepHqUser1) {

            List<Event> eventList = [SELECT Id, Subject, StartDateTime, EndDateTime, Description, ScheduleId__c, CalendarId__c, IsAllDayEvent FROM Event];
            system.debug('eventlist-->'+eventList);
             eventList[0].Subject  = 'testsubject';
             eventList[0].IsIF_152__c = false;
             update eventList;
            //Map<Id, Event> eventMap = new Map<Id, Event>(eventList);

            //System.enqueueJob(new EventTriggerHelper.EventKnoxUpdateScheduleQueue(eventList, eventMap, emp1) );
        }
        Test.stopTest();
    }
   
    @isTest
    static void eventTriggerHelperDeleteTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        System.runAs(salesRepHqUser1) {

            List<Event> eventList = [SELECT Id, Subject, StartDateTime, EndDateTime, Description, ScheduleId__c, CalendarId__c, IsAllDayEvent FROM Event where Subject = 'Event 2' limit 1];
            system.debug('eventlistdel'+eventList);
          // delete  eventList;
         //   System.enqueueJob(new EventTriggerHelper.EventKnoxDeleteScheduleQueue(eventList, emp1) );
        }
        Test.stopTest();
    } 

}