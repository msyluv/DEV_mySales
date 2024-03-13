/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-01-20
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-01-20   younghoon.kim@dkbmc.com   Initial Version
**/
@isTest
private class Batch_UserActiveChangeController_Test {
    static Employee__c testEmp1;
    static Employee__c testEmp2;
    static Employee__c testEmp3;
    static Employee__c testEmp4;

    static User testUser1;
    static User testUser2;
    static User testUser3;
    static User testUser4;

    static{
        List<Employee__c> empList = new List<Employee__c>();

        testEmp1 = new Employee__c(
            Name = 'Test Employee 1', 
            EvStatus__c = '2',
            EvUniqID__c = 'TEST_EVID_1'
        );
        empList.add(testEmp1);

        testEmp2 = new Employee__c(
            Name = 'Test Employee 2', 
            EvStatus__c = '3',
            EvUniqID__c = 'TEST_EVID_2'
        );
        empList.add(testEmp2);

        testEmp3 = new Employee__c(
            Name = 'Test Employee 3', 
            EvStatus__c = '5', 
            EvUniqID__c = 'TEST_EVID_3'
        );
        empList.add(testEmp3);

        testEmp4 = new Employee__c(
            Name = 'Test Employee 4', 
            EvStatus__c = '6', 
            EvUniqID__c = 'TEST_EVID_4'
        );
        empList.add(testEmp4);

        if(empList.size() > 0) insert empList;

        List<User> userList = new List<User>();

        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];

        testUser1 = new User(
            Alias='user1', 
            Email='testUser1@samsung.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = adminProfile.Id, 
            TimeZoneSidKey='Asia/Seoul', 
            UserName='testUser1@samsung.com', 
            FederationIdentifier='TEST_EVID_1'
        );
        userList.add(testUser1);

        testUser2 = new User(
            Alias='user2', 
            Email='testUser2@samsung.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = adminProfile.Id, 
            TimeZoneSidKey='Asia/Seoul', 
            UserName='testUser2@samsung.com', 
            FederationIdentifier='TEST_EVID_2'
        );
        userList.add(testUser2);

        testUser3 = new User(
            Alias='user3', 
            Email='testUser3@samsung.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = adminProfile.Id, 
            TimeZoneSidKey='Asia/Seoul', 
            UserName='testUser3@samsung.com', 
            FederationIdentifier='TEST_EVID_3'
        );
        userList.add(testUser3);

        testUser4 = new User(
            Alias='user4', 
            Email='testUser4@samsung.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = adminProfile.Id, 
            TimeZoneSidKey='Asia/Seoul', 
            UserName='testUser4@samsung.com', 
            FederationIdentifier='TEST_EVID_4'
        );
        userList.add(testUser4);

        if(userList.size() > 0) insert userList;
    }

    @isTest static void test_method_1() {
        Test.startTest();

        Database.executeBatch(new Batch_UserActiveChangeController(), 2000);

		Test.stopTest();
    }
}