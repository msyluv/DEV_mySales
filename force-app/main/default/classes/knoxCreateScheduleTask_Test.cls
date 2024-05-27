/**
    * @description       : Test Class for knoxCreateScheduleTask 
    * @author            : waris.m@samsung.com
    * @group             : 
    * @last modified on  : 2024-05-23
    * @last modified by  : waris.m@samsung.com 
    * Modifications Log 
    * Ver   Date         Author                      Modification
    * 1.0   2024-05-23   waris.m@samsung.com   Initial Version for MYSALES-264
    **/

        @isTest(SeeAllData=false)
        public class knoxCreateScheduleTask_Test {
            static User systemAdminUser1;
            static Employee__c emp1;
            static Task tsk;
        @isTest
        static void knoxCreateScheduleTest(){
            emp1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'EPID1');
                systemAdminUser1 = Utils_TestDataFactory.createUserFull(
                        Utils_TestDataFactory.getProfile('System Administrator')
                        , emp1.EvMailAddr__c
                        , emp1.EvUniqID__c);
            
            String calendarId = 'caleandarId';
                tsk = new Task(
                    OwnerId = systemAdminUser1.Id
                    , Subject = 'task 1'
                    , CalendarId__c = calendarId
                    , Knox_Schedule_ID__c ='1233344444444434'
                    , ActivityDate = system.today()
                    , Description = 'task1'

                );
                
                insert tsk;
                System.debug('Task '+tsk.Id);
                Test.startTest();
                System.debug('Task '+tsk.Id);
                Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
                System.enqueueJob(new knoxCreateScheduleTask(tsk.Id));
                Test.stopTest();

        }

    }