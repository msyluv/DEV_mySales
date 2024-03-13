/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-01-26
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-12-09   younghoon.kim@dkbmc.com   Initial Version
**/
@isTest
private class CollaborationOpptySearchControllerTest {
    static User user;
    static Account acc;
    static Opportunity oppty;

    static {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
        list<User> lu = new list<User>();
        user = new User(Alias = 'standt1', Email='user0001@samsung.com', 
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                    UserName='user0001@samsung.com');
        insert user;

        RecordType mdgRcdType = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType WHERE SobjectType = 'Account' AND IsActive = TRUE AND Name LIKE '%MDG%'];
        acc = new Account(
            Name = 'Collaboration Test Account',
            RecordTypeId = mdgRcdType.Id,
            MDGCheck__c = true
        );
        insert acc;

        oppty = new Opportunity(
            Name = 'Test Opportunity', 
            OwnerId = user.Id,
            AccountId = acc.Id,
            StageName = 'Z01',
            Type = 'New Business',
            LeadSource = 'Other',
            CloseDate = System.today()
        );
        insert oppty;
    }
    @isTest static void test_method_1() {
        Test.startTest();
        CollaborationOpptySearchController.init();
		Test.stopTest();
    }

    @isTest static void test_method_2() {
        Test.startTest();
        CollaborationOpptySearchController.getCollaboOpptyInfo(50, 0, 'Z01','SDS-TESTCODE','TESTOPPTYNAME');
		Test.stopTest();
    }

    @isTest static void test_method_3() {
        Test.startTest();
        CollaborationOpptySearchController.getSelectedOppty(oppty.Id);
		Test.stopTest();
    }
}