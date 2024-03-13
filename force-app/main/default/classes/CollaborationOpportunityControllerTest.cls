/**
 * @description       : 
 * @author            : jiiiiii.park@partner.samsung.com.sds.dev
 * @group             : 
 * @last modified on  : 2021-01-25
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   2020-11-26   jiiiiii.park@partner.samsung.com.sds.dev   Initial Version
**/
@isTest
public class CollaborationOpportunityControllerTest {
    static User user;
    static Account old_acc;
    static Account new_acc;
    static Company__c hqCompany;
    static CostCenter__c costCenter;
    static Opportunity originOppty;
    static Opportunity subOppty;
    static Opportunity_Activity__c opptyAct;

    static{
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
        list<User> lu = new list<User>();
        user = new User(Alias = 'standt1', Email='user0001@samsung.com', 
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', EvKostl__c  = 'T100-12430',
                    UserName='user0001@samsung.com');
        insert user;

        RecordType mdgRcdType = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType WHERE SobjectType = 'Account' AND IsActive = TRUE AND Name LIKE '%MDG%'];
        old_acc = new Account(
            Name = 'Test old Account',
            AccountNumber = 'T100-00',
            RecordTypeId = mdgRcdType.Id,
            MDGCheck__c = true
        );
        insert old_acc;

        new_acc = new Account(
            Name = 'Test new Account'
        );
        insert new_acc;

        hqCompany = new Company__c(
            Name = 'Test HQ Company',
            CompanyCode__c = 'T100'
        );
        insert hqCompany;

        costCenter = new CostCenter__c(
            Name = 'Test Cost Center',
            Company__c = hqCompany.Id,
            CostCenter__c   = 'T100-12430',
            ZZCheck__c = true
        );
        insert costCenter;

        RecordType hqRcdType = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'HQ'];
        originOppty = new Opportunity(
            Name = 'Test Opportunity', 
            RecordTypeId = hqRcdType.Id,
            SalesDepartment__c = costCenter.Id,
            AccountId = old_acc.Id,
			OwnerId = user.Id,
            StageName = 'Z01',
            CurrencyIsoCode = 'USD',
            Type = 'New Business',
            LeadSource = 'Other',
			CloseDate = System.today()
        );
        insert originOppty;
        
        subOppty = new Opportunity(
            Name = 'Test Sub Opportunity', 
            AccountId = old_acc.Id,
			OwnerId = user.Id,
            StageName = 'Z01',
            Type = 'New Business',
            LeadSource = 'Other',
            CloseDate = System.today(),
            CollaborationBOId__c = originOppty.Id
        );
        insert subOppty;

        opptyAct = new Opportunity_Activity__c(
            WhatId__c = subOppty.Id,
            TransactionName__c = 'ZP21',
            Status__c = 'Completed',
            ExtID__c = originOppty.Id + '_' + originOppty.StageName
        );
        insert opptyAct;
    }

    @isTest static void test_method_1() {
        Test.startTest();
        CollaborationOpportunityController.collaborationCheck(originOppty.Id);
		Test.stopTest();
    }

    @isTest static void test_method_2() {
        Test.startTest();
        originOppty.StageName = 'Z05';
        update originOppty;
        CollaborationOpportunityController.collaborationCheck(originOppty.Id);
		Test.stopTest();
    }

    @isTest static void test_method_3() {
        Test.startTest();
        CollaborationOpportunityController.collaborationCheck(subOppty.Id);
		Test.stopTest();
    }

    @isTest static void test_method_4() {
        Test.startTest();
        subOppty.CollaborationBOId__c = null;
        update subOppty;
        CollaborationOpportunityController.collaborationCheck(subOppty.Id);
		Test.stopTest();
    }

    @isTest static void test_method_5(){
        Test.startTest();
        CollaborationOpportunityController.saveCollaboration(originOppty.Id, user.Id);
		Test.stopTest();
    }
}