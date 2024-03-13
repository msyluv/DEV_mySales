/**
 * @description       : Test Class for massDeleteOppYearlyRevenueSchedule
 * @author            : d.ashish@samsung.com
 * @group             : 
 * @last modified on  : 02-21-2024
 * @last modified by  : d.ashish@samsung.com
 * Modifications Log 
 * Ver   Date         Author            		Modification
 * 1.0   02-21-2024   d.ashish@samsung.com     Initial Version(MySales -450)
**/
@isTest
public class massDeleteOppYearlyRevenueScheduleTest {


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
            , Node2__c          = System.Label.YearlyRevenueScheduleNote2//'T100S4'//'T100SB'
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
            cRevenueEndDate__c = tDate.addMonths(2),
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
        
           Yearly_Revenue_Schedule__c  yrsObj = new Yearly_Revenue_Schedule__c(name = 'Yearly Revenue for '+ opptyHQ1.cRevenueStartDate__c.year(), ContractYearDate__c = opptyHQ1.cRevenueStartDate__c, OpportunityId__c =opptyHQ1.Id,M3__c= 10, M5__c = 10 ,M6__c= 10 );
           
        insert yrsObj;
    }
    
    
    @isTest static void testMassDel() {        
        Test.startTest();
        Integer i1 = [SELECT COUNT() FROM Yearly_Revenue_Schedule__c];
        System.debug('Total Record Count of ORS object : '+i1);
        massDeleteOppYearlyRevenueSchedule objMDR = new massDeleteOppYearlyRevenueSchedule();
        Database.executeBatch( objMDR );
        Test.stopTest();
        Integer i = [SELECT COUNT() FROM Yearly_Revenue_Schedule__c];
        System.debug('Total Record Count of ORS object : '+ i);
        Assert.areEqual( 0, [ SELECT COUNT() FROM Yearly_Revenue_Schedule__c ] );        
    }
}