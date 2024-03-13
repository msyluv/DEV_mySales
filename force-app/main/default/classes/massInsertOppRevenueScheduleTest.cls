/**
 * @description       : 
 * @author            : aditya.r2@samsung.com
 * @group             : 
 * @last modified on  : 07-24-2023
 * @last modified by  : aditya.r2@samsung.com
 * Modifications Log 
 * Ver   Date         Author            		Modification
 * 1.0   07-23-2023   aditya.r2@samsung.com     Initial Version
**/
@isTest
public class massInsertOppRevenueScheduleTest {

    @testSetup static void setup() {
        
        Date tDate = Date.today();
        RecordType RT_OPPTY_HQ = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
        Account acc = new Account( 
            Name = 'Test Account',
            MDGCheck__c = true
        );
        insert acc;
        
        CostCenter__c costCenterHQ = new CostCenter__c(
            Name                = '기술전략팀(T100-11331)'
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T100'
            , CostCenterName__c = '기술전략팀'
            , CostCenter__c     = 'T100-11331'
            , Node1__c          = 'T100'
            , Node2__c          = System.Label.RevenueScheduleNote2 //'T100SB'//'T100S4'
            , Node3__c          = 'T100SB1'
            , Node4__c          = 'T100SB13'
            , Node5__c          = 'T100SB131'            
            , ZZCheck__c        = true
            , Text2__c			= '솔루션사업부'//'클라우드서비스사업부'
        );
        insert costCenterHQ;
        
        Opportunity opptyHQ1 = new Opportunity(
            Name = 'Test Opportunity',
            RecordTypeId = RT_OPPTY_HQ.Id,
            CurrencyIsoCode = 'KRW',
            Amount = 10000,
            cRevenueStartDate__c = tDate,
            cRevenueEndDate__c = tDate.addMonths(1),
            CspMspType__c = 'CSP', 
            OtherCSP__c = 'CSP1',
            MSP_Amount__c = 200,
            StageName = 'Z01',
            cPrimarySalesDepartment__c = costCenterHQ.Id,
            SalesDepartment__c = costCenterHQ.Id,
            CloseDate = Date.today(),
            AccountId = acc.Id,
            cOriginAcc__c = acc.Id,
            cLeadID__c = NULL
        );
        insert opptyHQ1;
        
    }
    
    
    @isTest static void testMassInsert() {        
        Test.startTest();
        massInsertOppRevenueSchedule objMDR = new massInsertOppRevenueSchedule();
        Database.executeBatch( objMDR );
        Test.stopTest();
        Assert.areEqual( 2, [ SELECT COUNT() FROM RevenueScheduleOpportunity__c ] );        
    }
    
}