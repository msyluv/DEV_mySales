/**
 * @author            : younghoon.kim@dkbmc.com
 * @description       : [IF-151] Batch_UserLoginHistoryController의 테스트 코드
 * @last modified on  : 2022-04-14
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2022-01-21   younghoon.kim@dkbmc.com  Initial Version
**/
@isTest(SeeAllData=false)
private class Batch_UserLoginHistoryController_Test {
    static User user1;

    static {
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name = '시스템 관리자' OR Name = 'System Administrator'];
        user1 = new User(
            Alias = 'testUser',
            Email = 'TestEmp2@samsung.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            EmployeeNumber = 'AC100000',
            TimeZoneSidKey = 'Asia/Seoul',
            ProfileId = profile.Id,
            UserName = 'TestEmp2@samsung.com',
            FederationIdentifier = 'EPID2',
            CompanyCode__c = 'T100'
        );
        insert user1;
    }

    @isTest
    public static void UpdateUserInfoTest_1(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        System.runAs(user1){
            DataBase.executeBatch(new Batch_UserLoginHistoryController(), 200);
        }
        Test.stopTest();
    }
}