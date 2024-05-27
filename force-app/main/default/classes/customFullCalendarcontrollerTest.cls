/**
        * @description       : Test Class for customFullCalendarcontroller 
        * @author            : waris.m@samsung.com
        * @group             : 
        * @last modified on  : 2024-05-24
        * @last modified by  : waris.m@samsung.com 
        * Modifications Log 
        * Ver   Date         Author                      Modification
        * 1.0   2024-05-24   waris.m@samsung.com   Initial Version for MYSALES-264
        **/
    @isTest
    public class customFullCalendarcontrollerTest {

        
        static User u;
        static Account acc;
        static AccountPlan__c accPlan;
        static Opportunity pastOpp;
        static Opportunity futureOpp;
        static Opportunity_Activity__c pastOpptyAct;
        static Opportunity_Activity__c futureOpptyAct;
        static  Map<String,List<Object>>  eve;
        static List<Task> taskList;  // Added by Waris
        static Task tsk;            // Added by Waris
        static Integer eventCount; //Added by Waris
        static String calenderListStatus;
        static String knoxSchedule;
        static AsyncApexJob apexJob;
        static Datetime dateTimeNow;
        static Datetime dateTimeCheck;
        static User u1;
        static String sysncTask;
        static String deleteEvent;
        static String deleteTask;
        static Id eventId;
         static Id taskId;
        static {
            
            
            user admin = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            system.runAs (admin) {
                Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
                list<User> lu = new list<User>();
                u = new User(Alias = 'standt1', Email='user0001@samsung.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                            UserName='user0001@samsung.com');
                insert u;
            }
            Event ev = new Event(Subject='Test', StartDateTime=system.now(), EndDateTime=system.now(), OwnerId=u.Id,IsAllDayEvent=false);
            insert ev;
           // eventId=ev.Id;
        String calendarId = 'caleandarId';
        tsk = new Task(
                OwnerId = u.Id
                , Subject = 'task 1'
                , CalendarId__c = calendarId
                , Knox_Schedule_ID__c ='1233344444444434'
                , ActivityDate = system.today()
                , Description = 'task1'

            );
            
            insert tsk;

        }
        
        @isTest
        public static void knoxCalenderControllerTest_1(){
        Test.startTest();
            system.runAs (u) {
                Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
                eve=customFullCalendarcontroller.getAllEvendata();
                taskList=customFullCalendarcontroller.gettaskdata();
                eventCount=customFullCalendarcontroller.geteventcount();
                calenderListStatus=customFullCalendarcontroller.getcalendarlist();
                knoxSchedule=customFullCalendarcontroller.getKnoxSchedules();
                dateTimeNow=Datetime.now();
                dateTimeCheck=customFullCalendarcontroller.getWeekdate(dateTimeNow);
                u1=customFullCalendarcontroller.getuserdetail();
                u1=customFullCalendarcontroller.synctaskuserrec(false);
               // sysncTask=customFullCalendarcontroller.synctaskcaltoknox();
                deleteEvent=customFullCalendarcontroller.deleteEventData(eventId);
                deleteTask=customFullCalendarcontroller.deleteTaskData(taskId);

            }
        Test.stopTest();
        }
    }