@isTest
public class TaskTrigger_Test {
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
        salesRepHqUser1.Synchronize_task__c = true;
        update salesRepHqUser1;

        // 임직원 및 User Setting
        emp2 = Utils_TestDataFactory.createEmployee('TestEmp2', 'EPID2');
        salesRepLogiUser1 = Utils_TestDataFactory.createUserFull(
                Utils_TestDataFactory.getProfile('Sales Rep.(Logi)')
                , emp2.EvMailAddr__c
                , emp2.EvUniqID__c);

        String calendarId = 'caleandarId';
        List<Task> TaskList = new List<Task>();
        
        datetime startDate = Datetime.newInstance(2020, 21 , 01, 00, 00, 00);
        datetime endDate = Datetime.newInstance(2020, 21 , 01, 01, 00, 00);
        Task tsk = new Task(
            OwnerId = salesRepHqUser1.Id
            , Subject = 'task 1'
            , CalendarId__c = calendarId
            , Knox_Schedule_ID__c ='1233344444444434'
            , ActivityDate = system.today()
            , Description = 'task1'

        );
        TaskList.add(tsk);

        Task tsk1 = new Task(
            OwnerId = salesRepHqUser1.Id
           , Subject = 'task 2'
            , CalendarId__c = calendarId
            , Knox_Schedule_ID__c ='1233344444444435'
            , ActivityDate = system.today()
            , Description = 'task2'

        );
        TaskList.add(tsk1);



        insert TaskList;
       
        
    }

    @isTest
    static void TaskTriggerTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        System.runAs(salesRepHqUser1) {
            
           
           
          //delete evt;

        }
        Test.stopTest();
    }

 
   
    @isTest
    static void eventTriggerHelperUpdateTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        System.runAs(salesRepHqUser1) {

            List<Task> taskList = [select id,Knox_Calendar_Id__c, Knox_Schedule_ID__c, Subject, ActivityDate,CreatedDate,Description from Task];
           system.debug('taskList-->'+taskList);
             taskList[0].Subject  = 'testsubject';
             update taskList;
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
            List<Task> taskList = [select id,Knox_Calendar_Id__c, Knox_Schedule_ID__c, Subject, ActivityDate,CreatedDate,Description from Task];
            system.debug('taskListdel'+taskList);
           // List<Event> eventList = [SELECT Id, Subject, StartDateTime, EndDateTime, Description, ScheduleId__c, CalendarId__c, IsAllDayEvent FROM Event where Subject = 'Event 2' limit 1];
            //system.debug('eventlistdel'+eventList);
         // delete  taskList;
         //   System.enqueueJob(new EventTriggerHelper.EventKnoxDeleteScheduleQueue(eventList, emp1) );
        }
        Test.stopTest();
    } 


}