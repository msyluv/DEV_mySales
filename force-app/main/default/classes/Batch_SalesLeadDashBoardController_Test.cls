/**
 * @author            : younghoon.kim@dkbmc.com
 * @description       : [IF-152] Batch_SalesLeadDashBoardController의 테스트 코드
 * @last modified on  : 2022-02-25
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2022-02-21   younghoon.kim@dkbmc.com  Initial Version
**/
@isTest
private class Batch_SalesLeadDashBoardController_Test {
    static Account acc;
    static Opportunity oppty;
    static Lead lead;
    static Sales_Lead__c sLead;

    static RecordType RT_OPPTY_HQ = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];

    static {
        Account acc = new Account( 
            Name = 'Test Account',
            MDGCheck__c = true
        );
        insert acc;

        oppty = new Opportunity(
            Name = 'Test Opportunity',
            RecordTypeId = RT_OPPTY_HQ.Id,
            StageName = 'Z02',
            CloseDate = Date.today(),
            AccountId = acc.Id
        );
        insert oppty;

        lead = new Lead(
            LastName = 'TestLead', 
            PersonalInfoAgreement__c = true, 
            Company='TestCompany'
        );
        insert lead;

        sLead = new Sales_Lead__c(
            Name = 'TestSalesLead', 
            LeadStage__c = 'Hot',
            Lead__c = lead.Id, 
            Amount__c = 5000, 
            AccountId__c = acc.Id,
            CloseDate__c = Date.today().addDays(1),  
            RevenueEndDate__c = Date.today().addDays(3), 
            RevenueStartDate__c = Date.today().addDays(2),
            Budget__c = true,
            Authority__c = true,
            LeadChannel__c = 'Marketing Lead Converted',
            OpportunityName__c = oppty.Id
        );
        insert sLead;
    }

    @isTest
    public static void UpdateUserInfoTest_1(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        DataBase.executeBatch(new Batch_SalesLeadDashBoardController(), 200);
        Test.stopTest();
    }
}