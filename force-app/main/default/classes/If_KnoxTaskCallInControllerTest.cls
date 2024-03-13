/**
* @description       : 
* @author            : atul.k1@samsung.com
* @group             : 
* @last modified on  : 2022-11-2
* @last modified by  : atul.k1@samsung.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   2022-11-2    atul.k1@samsung.com       Initial Version 
*       2024-02-02   sarthak.j1@samsung.com    Test class changes for code coverage
**/
@IsTest(SeeAllData=true)
public class If_KnoxTaskCallInControllerTest {
    @isTest
    public static void If_KnoxTaskCallInControllerTest_1(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        If_KnoxTaskCallInController.getknoxcalendarList();
        Test.stopTest();
    }
     @isTest
    public static void If_KnoxTaskCallInControllerTest_2(){
        Test.startTest();
        If_KnoxTaskCallInController.getknoxcalendarList();
        Test.stopTest();
    }
    @isTest
    public static void IF_KnoxTaskCallOutAPIControllerTest_1(){
        List<Task> listofTasks =[SELECT Id,Subject,ActivityDate,CompletedDateTime,OwnerId,Owner.Email FROM Task Limit 1];
        set<ID> tsID = new Set<ID>();
        for(Task eachts : listofTasks){
            tsID.add(eachts.Id);
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_SampleMock());
        //IF_KnoxTaskCallOutAPIController.doCalloutSendingTaskInfo(tsID);
        Test.stopTest();
    }  
    @isTest
    public static void IF_KnoxTaskCallOutAPIControllerTest_2(){
        List<Task> listofTasks =[SELECT Id,Subject,ActivityDate,CompletedDateTime,OwnerId,Owner.Email FROM Task Limit 1];
        set<ID> tsID = new Set<ID>();
        for(Task eachts : listofTasks){
            tsID.add(eachts.Id);
        }
        
        // SJOSHI: Start
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
        User u = new User(Alias = 'testUser', Email = 'testUser@abc.com', EmailEncodingKey = 'UTF-8', 
                          LastName = 'testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', 
                          ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles', UserName = 'tu@abc.com');
        //User myTestUser = UserFactory.createTestUser();
        // SJOSHI: End
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_SampleMock());
        //IF_KnoxTaskCallOutAPIController.doCalloutCreatemySalesKnoxCalender(); --> [SJOSHI: commented out due to error]
        // SJOSHI: Start
        List<Event> listofEvents =[SELECT Id,Subject,ActivityDate,StartDateTime,EndDateTime,OwnerId,Owner.Email,Knox_Schedule_ID__c,Location,Description,IsAllDayEvent FROM Event LIMIT 1];
        System.runAs(u){
            IF_KnoxTaskCallOutAPIController.doCalloutCreatemySalesKnoxCalender(listofEvents[0].Id);
        }
        // SJOSHI: End
        Test.stopTest();
    } 
     @isTest
    public static void if_KnoxTaskListCallInControllerTest_1(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        if_KnoxTaskListCallInController.getknoxScheduleList();
        Test.stopTest();
    }
     @isTest
    public static void IF_KnoxUpdateTaskControllerTest_1(){
        List<Task> listofTasks =[SELECT Id,Subject,ActivityDate,CompletedDateTime,OwnerId,Owner.Email FROM Task Limit 1];
        set<ID> tsID = new Set<ID>();
        for(Task eachts : listofTasks){
            tsID.add(eachts.Id);
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_SampleMock());
       // IF_KnoxUpdateTaskController.doCalloutSendingUpdatedTaskInfo(tsID);
       // SJOSHI: Start
       List<Event> listofEvents =[SELECT Id,Subject,ActivityDate,StartDateTime,EndDateTime,OwnerId,Owner.Email,Knox_Schedule_ID__c,Location,Description,IsAllDayEvent FROM Event LIMIT 1];
       IF_KnoxUpdateTaskController.doCalloutSendingUpdatedTaskInfo(listofEvents[0].Id);   
       // SJOSHI: End
        Test.stopTest();
    } 
     @isTest
    public static void IF_DeleteKnoxScheduleCalloutControllerTest_1(){
       String knoxschID =[SELECT Id,Subject,ActivityDate,CompletedDateTime,OwnerId,Owner.Email,Knox_Schedule_ID__c FROM Task where Knox_Schedule_ID__c != null Limit 1].Knox_Schedule_ID__c;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_SampleMock());
        IF_DeleteKnoxScheduleCalloutController.deleteSingleknoxSchedule(knoxschID);
        Test.stopTest();
    } 
    @isTest
    public static void IF_DeleteKnoxScheduleCalloutControllerTest_2(){
       String knoxschID =[SELECT Id,Subject,ActivityDate,CompletedDateTime,OwnerId,Owner.Email,Knox_Schedule_ID__c FROM Task where Knox_Schedule_ID__c != null Limit 1].Knox_Schedule_ID__c;
        Test.startTest();
        IF_DeleteKnoxScheduleCalloutController.deleteSingleknoxSchedule(knoxschID);
        Test.stopTest();
    } 
    @isTest
    public static void if_KnoxSingletaskCallControllerTest_1(){
        // SJOSHI: Start
        List<Event> listofEvents =[SELECT Id,Subject,ActivityDate,StartDateTime,EndDateTime,OwnerId,Owner.Email,Knox_Schedule_ID__c,Location,Description,IsAllDayEvent FROM Event LIMIT 1];
        set<ID> evID = new Set<ID>();
        string eventid;
        for(Event eachev : listofEvents){
            evID.add(eachev.Id);
            eventid = eachev.id;
        }
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
        User u = new User(Alias = 'testUser', Email = 'testUser@abc.com', EmailEncodingKey = 'UTF-8', 
                          LastName = 'testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', 
                          ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles', UserName = 'tu@abc.com');
        //User myTestUser = UserFactory.createTestUser();
        // SJOSHI: End
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_SampleMock());
        //IF_KnoxTaskCallOutAPIController.doCalloutCreatemySalesKnoxCalender(); --> [SJOSHI: commented out due to error]
        // SJOSHI: Start
        
        System.runAs(u){
           List<Object> if194List = if_KnoxSingletaskCallController.getSingleknoxSchedule(eventid);
        }
        // SJOSHI: End
        Test.stopTest();
    }
}