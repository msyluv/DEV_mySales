/**
* @description       : 
* @author            : sarthak.j1@samsung.com
* @group             : 
* @last modified on  : 01-08-2024
* @last modified by  : sarthak.j1@samsung.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   2022-11-2   sarthak.j1@samsung.com     Initial Version 
**/
@isTest
public class knoxCalenderControllerTest {
    
    static User u;
	static Account acc;
	static AccountPlan__c accPlan;
	static Opportunity pastOpp;
    static Opportunity futureOpp;
	static Opportunity_Activity__c pastOpptyAct;
    static Opportunity_Activity__c futureOpptyAct;

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
		Event ev = new Event(Subject='Test', StartDateTime=system.now(), EndDateTime=system.now(), OwnerId=u.Id);
		insert ev;

		Task tsk = new Task(Subject='Test', ActivityDate=system.today(), OwnerId=u.Id);
		insert tsk;

		acc = new Account(Name = 'Test Account');
		insert acc;

		accPlan = new AccountPlan__c(
			AccountId__c = acc.Id,
			Name = 'Test Account Plan',
			StartDateTime__c = System.now(),
			OwnerId = u.Id
		);
		insert accPlan;

		pastOpp = new Opportunity(
			Name = 'Test Opportunity', 
			OwnerId = u.Id,
			StageName = 'Z01',
			CloseDate = System.today().addDays(-1)
		);
		insert pastOpp;
        
        futureOpp = new Opportunity(
			Name = 'Test Opportunity', 
			OwnerId = u.Id,
			StageName = 'Z01',
			CloseDate = System.today()
		);
		insert futureOpp;

		pastOpptyAct = new Opportunity_Activity__c(
			WhatId__c = pastOpp.Id,
			EndDate__c = System.today().addDays(-1),
            ExtID__c = pastOpp.Id + '_' + pastOpp.StageName
		);
		insert pastOpptyAct;
        
        futureOpptyAct = new Opportunity_Activity__c(
			WhatId__c = futureOpp.Id,
			StartDate__c = System.today(),
            ExtID__c = futureOpp.Id + '_' + futureOpp.StageName
		);
		insert futureOpptyAct;
	}
    
    @isTest
    public static void knoxCalenderControllerTest_1(){
        String sYear = String.valueOf(system.today().year());
		String sMonth = String.valueOf(system.today().month());
		String sDate = system.now().format('yyyy-MM-dd');
		String jsonObj = '{"Event":true,"Task":true,"AcctPlan":true,"OpptyAct":true}';
        Test.startTest();
        system.runAs (u) {
            Test.setMock(HttpCalloutMock.class, new IF_Callout_SampleMock());
            knoxCalenderController.monthSetting();
            knoxCalenderController.getMyActivities(sYear, sMonth, jsonObj, false);
            knoxCalenderController.getTodayActivities(sDate, jsonObj, false);
            knoxCalenderController.getTodayActivities((system.now()-1).format('yyyy-MM-dd'), jsonObj, false);
            //knoxCalenderController.getKnoxSchedules();
            //knoxCalenderController.getAsnycjobStatus('test123');
        	}
        Test.stopTest();
    	}
    }