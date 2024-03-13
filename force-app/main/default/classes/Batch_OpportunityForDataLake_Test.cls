/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-07-09
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-07-09   younghoon.kim@dkbmc.com   Initial Version
**/
@isTest
public class Batch_OpportunityForDataLake_Test {
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
            CloseDate = System.today()
        );
        insert oppty;
    }

    static testMethod  void testBatch1() {
        Test.startTest();

        Batch_OpportunityForDataLake batch = new Batch_OpportunityForDataLake();
        Database.executeBatch(batch, 200);

        Test.stopTest();
    }
}