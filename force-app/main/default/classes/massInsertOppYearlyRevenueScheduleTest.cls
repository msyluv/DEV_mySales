/**
 * @description       : Test Class for massInsertOppYearlyRevenueSchedule
 * @author            : d.ashish@samsung.com
 * @group             : 
 * @last modified on  : 02-21-2024
 * @last modified by  : d.ashish@samsung.com
 * Modifications Log 
 * Ver   Date         Author            		Modification
 * 1.0   02-21-2024   d.ashish@samsung.com     Initial Version(MySales -450)
**/
@isTest
public class massInsertOppYearlyRevenueScheduleTest {

    @testSetup static void setup() {
        
        Date tDate = Date.today();
        RecordType RT_OPPTY_HQ = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
        Account acc = new Account( 
            Name = 'Test Account',
            MDGCheck__c = true
        );
        insert acc;
        Company__c cmp = new Company__c(
                Name = 'comp',
                CompanyCode__c = 'T302'
            );
            insert cmp;
        
        CostCenter__c costCenterHQ = new CostCenter__c(
            Name                = '기술전략팀(T302-11331)'
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T302'
            , CostCenterName__c = '기술전략팀'
            , CostCenter__c     = 'T302-11331'
            , Node1__c          = 'T302'
            , Node2__c          = System.Label.YearlyRevenueScheduleNote2 //'T100SB'//'T100S4'
            , Node3__c          = 'T302SB1'
            , Node4__c          = 'T302SB13'
            , Node5__c          = 'T302SB131'            
            , ZZCheck__c        = true
            , Text2__c			= '솔루션사업부'//'클라우드서비스사업부'
            , Company__c = cmp.Id
        );
        insert costCenterHQ;
        
        Opportunity opptyHQ1 = new Opportunity(
            Name = 'Test Opportunity',
            RecordTypeId = RT_OPPTY_HQ.Id,
            CurrencyIsoCode = 'KRW',
            Amount = 10000,
            //CompanyCode__c = 'T100',
            cRevenueStartDate__c = tDate,
            cRevenueEndDate__c = tDate.addMonths(13),
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
        
        Delivery_Probabiliy__c del = new Delivery_Probabiliy__c(name = 'test', Opportunity__c = opptyHQ1.Id);
        insert del;
        
        delete [select id FROM Yearly_Revenue_Schedule__c where OpportunityId__c =: opptyHQ1.id];
        
    }
    
    
    @isTest static void testMassInsert() {        
        Test.startTest();
        massInsertOppYearlyRevenueSchedule objMDR = new massInsertOppYearlyRevenueSchedule();
        Database.executeBatch( objMDR );
        Test.stopTest();
        //Assert.areEqual( 2, [ SELECT COUNT() FROM Yearly_Revenue_Schedule__c ] );        
    }
}