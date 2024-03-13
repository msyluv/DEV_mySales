/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2020-11-18
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-11-18   younghoon.kim@dkbmc.com   Initial Version
**/
@isTest
private class CustomCalendarController_Test {
    static User user;
    static Id userRoleId;
    static String json_String;
    static Event event;
    static Task task;
    static Account account;
    static AccountPlan__c accPlan;
    static Opportunity oppty;
    static Opportunity_Activity__c opptyAct;

    static{
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
        list<User> lu = new list<User>();
        user = new User(Alias = 'standt1', Email='user0001@samsung.com', 
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                    UserName='user0001@samsung.com');
        insert user;

        Date firstDayOfMonth = System.today().toStartOfMonth();
        Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
        String firstDay = firstDayOfMonth.year()  + '-' + firstDayOfMonth.month() + '-0' + firstDayOfMonth.day();
        String lastDay = lastDayOfMonth.year()  + '-' + lastDayOfMonth.month() + '-' + lastDayOfMonth.day();

        UserRole ur = [SELECT Id, Name, ParentRoleId FROM UserRole WHERE ParentRoleId = null LIMIT 1];
        userRoleId = ur.Id;

        json_String =  '{"startDate" : "' + firstDay + '"';
        json_String += ' ,"endDate" : "' + lastDay + '"';
        json_String += ' ,"firstCall" : true';
        json_String += ' ,"hasCompleteField" : false';
        json_String += ' ,"fieldComplete" : ""';
        json_String += ' ,"isRoleId" : true';
        json_String += ' ,"ids" : ["' + ur.Id + '"]';
        json_String += ' ,"className" : ""';
        json_String += ' ,"editable" : false';
        json_String += ' ,"useUrl" : false';
        json_String += ' ,"color" : "lightblue"';
        json_String += ' ,"backgroundColor" : ""';
        json_String += ' ,"borderColor" : ""';
        json_String += ' ,"textColor" : "#000000"';
        json_String += ' ,"types" : ["Event","Task","Account Plan","Opportunity Activity"]}';

        event = new Event(
            Subject = 'Test Event',
            StartDateTime = firstDayOfMonth,
            EndDateTime = firstDayOfMonth.addDays(10)
        );
        insert event;

        task = new Task(
            Subject = 'Test Task',
            ActivityDate = firstDayOfMonth
        );
        insert task;

        account = new Account(
            Name = 'Test Account'
        );
        insert account;

        accPlan = new AccountPlan__c(
            Name = 'Test Account Plan',
            AccountId__c = account.Id,
            StartDateTime__c = firstDayOfMonth,
            EndDateTime__c = lastDayOfMonth
        );
        insert accPlan;

        oppty = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Z01',
            CloseDate = firstDayOfMonth
        );
        insert oppty;

        opptyAct = new Opportunity_Activity__c(
            WhatId__c = oppty.Id,
            StartDate__c = firstDayOfMonth,
            EndDate__c = lastDayOfMonth
        );
        insert opptyAct;
    }
	@IsTest
	private static void test_Method_1() {
        Test.startTest();
        CustomCalendarController.fetchAllEvents();
        System.runAs(user){
            CustomCalendarController.getUserRoleId();
            
            user.UserRoleId = userRoleId;
            update user;
            CustomCalendarController.getUserRoleId();
        }
        CustomCalendarController.getUserRoles(userRoleId, true);
        CustomCalendarController.getRandomColor();
        CustomCalendarController.convertDateToDateTime(Date.today());
        Test.stopTest();
    }

    @IsTest
	private static void test_Method_2() {
        Test.startTest();
        CustomCalendarController.getCalendarEvents(json_String);
        Test.stopTest();
    }

    @IsTest
	private static void test_Method_3() {
        Test.startTest();
        Test.stopTest();
    }
}