/**
* @description       : Create IF_Monitoring record BO with No-Role-User owner. 
* @author            : saurav.k@partner.samsung.com
* @group             : 
* @last modified on  : 05-10-2023
* @last modified by  : saurav.k@partner.samsung.com
* Modifications Log 
* Ver   Date         Author                        Modification
* 1.0   05-10-2023  saurav.k@partner.samsung.com   Initial Version(MySales -189)

**/

@isTest()
public class Batch_MonitoringInsertBasisonBO_test {
    static RecordType RT_OPPTY_HQ = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
    @testSetup
    static void setup() {
        Profile prof = [select id from profile where name LIKE '%System Administrator%' limit 1];
        User user = new User();
        user.firstName = 'test158757';
        user.lastName = 'test24834';
        user.profileId = prof.id;
        user.username = 'test158757@test.com';
        user.email = 'test@test.com';
        user.UserRoleId = Null;
        user.IsActive = true;
        user.Title = 'title';
        user.Alias = 'alias';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'en_US';
        insert user;
        
       
         Profile prof1 = [select id from profile where name LIKE '%System Administrator%' limit 1];
        User usernew = new user();
        usernew.firstName = 'test1587576766';
        usernew.lastName = 'test2483454556';
        usernew.profileId = prof1.id;
        usernew.username = 'test15875788@test.com';
        usernew.email = 'test@test.com';
        usernew.UserRoleId = Null;
        usernew.IsActive = false;
        usernew.Title = 'title';
        usernew.Alias = 'alias';
        usernew.TimeZoneSidKey = 'America/Los_Angeles';
        usernew.EmailEncodingKey = 'UTF-8';
        usernew.LanguageLocaleKey = 'en_US';
        usernew.LocaleSidKey = 'en_US';
        usernew.UserRoleId = Null;
        insert usernew;
        User u = [select id from User where IsActive = false AND UserRoleId != Null limit 1];
        
        Account acc = new Account( 
            Name = 'Test Account',
            MDGCheck__c = true
        );
        insert acc;
        Opportunity   opptyHQ = new Opportunity(
            Name = 'Test Opportunity',
            RecordTypeId = RT_OPPTY_HQ.Id,
            //ProposalPM_User__c = migUser.Id, 
            MigData__c = True,  
            StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today(),
            AccountId = acc.Id,
            cLeadID__c = NULL,
            ownerId = user.Id
            
        );
        insert opptyHQ;
        Opportunity   opptyHQ1 = new Opportunity(
            Name = 'Test Opportunity',
            RecordTypeId = RT_OPPTY_HQ.Id,
           // ProposalPM_User__c = migUser.Id, 
            MigData__c = True,  
            StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today(),
            AccountId = acc.Id,
            cLeadID__c = NULL,
            ownerId = usernew.Id
            
        );
        insert opptyHQ1;
        Opportunity   opptyHQ2 = new Opportunity(
            Name = 'Test Opportunity',
            RecordTypeId = RT_OPPTY_HQ.Id,
            //ProposalPM_User__c = migUser.Id, 
            MigData__c = True,  
            StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today(),
            AccountId = acc.Id,
            cLeadID__c = NULL,
            ownerId = u.Id
            
        );
        insert opptyHQ2;
    }
    @isTest static void test() {
        Test.startTest();        
        Database.executeBatch(new Batch_MonitoringInsertBasisonBO());
        Test.stopTest();
        
    }
}