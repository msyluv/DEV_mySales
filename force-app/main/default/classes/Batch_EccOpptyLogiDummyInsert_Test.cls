/**
 * @description       : 
 * @author            : zenith21c@test.com
 * @group             : 
 * @last modified on  : 11-18-2021
 * @last modified by  : zenith21c@test.com
**/
@isTest
public class Batch_EccOpptyLogiDummyInsert_Test {
    @TestSetup
    static void setup(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
        User user = new User(Alias = 'standt1', Email='user0001@samsung.com', 
                     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                     LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                     UserName='user0001@samsung.com');
        insert user;

        RecordType mdgRcdType = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType WHERE SobjectType = 'Account' AND IsActive = TRUE AND Name LIKE '%MDG%'];
        Account acc = new Account(
            Name = 'Collaboration Test Account',
            RecordTypeId = mdgRcdType.Id,
            MDGCheck__c = true
        );
        insert acc;

        Opportunity oppty = new Opportunity(
            Name = 'Test Opportunity', 
            OwnerId = user.Id,
            AccountId = acc.Id,
            StageName = 'Z01',
            Type = 'New Business',
            LeadSource = 'Other',
            CloseDate = System.today(),
            MigData__c = false
        );
        insert oppty;
    }

    static testMethod  void testBatch1() {
        Test.startTest();

        Batch_EccOpptyLogiDummyInsert batch = new Batch_EccOpptyLogiDummyInsert();
        Database.executeBatch(batch, 1);

        Test.stopTest();
    }
}