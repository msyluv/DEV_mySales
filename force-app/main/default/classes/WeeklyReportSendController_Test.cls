/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-01-25
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-01-25   younghoon.kim@dkbmc.com   Initial Version
**/
@isTest
private class WeeklyReportSendController_Test {
    static User user;
    static Account acc;
    static Company__c hqCompany;
    static CostCenter__c costCenter;
    static Opportunity oppty;
    static WeeklyReport__c wp;
    
    static {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
        list<User> lu = new list<User>();
        user = new User(Alias = 'standt1', Email='user0001@samsung.com', 
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                    UserName='user0001@samsung.com');
        insert user;

        RecordType mdgRcdType = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType WHERE SobjectType = 'Account' AND Name = 'MDG'];
        acc = new Account(
            Name = 'Test old Account',
            AccountNumber = 'T100-00',
            RecordTypeId = mdgRcdType.Id,
            MDGCheck__c = true
        );
        insert acc;

        hqCompany = new Company__c(
            Name = 'Test HQ Company',
            CompanyCode__c = 'T100'
        );
        insert hqCompany;

        costCenter = new CostCenter__c(
            Name = 'Test Cost Center',
            Company__c = hqCompany.Id
        );
        insert costCenter;

        RecordType hqRcdType = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'HQ'];
        oppty = new Opportunity(
            Name = 'Test Opportunity', 
            RecordTypeId = hqRcdType.Id,
            SalesDepartment__c = costCenter.Id,
            AccountId = acc.Id,
			OwnerId = user.Id,
            StageName = 'Z01',
            Type = 'New Business',
            LeadSource = 'Other',
			CloseDate = System.today()
        );
        insert oppty;
        
        wp = new WeeklyReport__c(
            Name = 'Test Weekly Report', 
            ReportingDate__c = Date.today()
        );
        insert wp;
    }

    @isTest static void test_method_1(){
        Test.startTest();
        WeeklyReportSendController.sendWeeklyReport(wp.Id);
        Test.stopTest();
    }
    
    @isTest static void test_method_2(){
        Test.startTest();
        wp.Opportunity__c = oppty.Id;
        update wp;
        WeeklyReportSendController.sendWeeklyReport(wp.Id);
        Test.stopTest();
    }
    
    @isTest static void test_method_3(){
        Test.startTest();
        wp.Opportunity__c = oppty.Id;
        wp.Contents__c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        update wp;
        
        WeeklyReportSendController.sendWeeklyReport(wp.Id);
        Test.stopTest();
    }
}