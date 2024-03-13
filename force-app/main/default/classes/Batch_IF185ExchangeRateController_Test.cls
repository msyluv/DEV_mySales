/**
 * @description       : Test Class of Batch_IF185ExchangeRateController
 * @author            : vikrant.ks@samsung.com
 * @group             : 
 * @last modified on  : 2023-10-10
 * @last modified by  : vikrant.ks@samsung.com 
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2023-10-10   vikrant.ks@samsung.com   Initial Version(MySales 317)
**/
@isTest
public class Batch_IF185ExchangeRateController_Test{
    @TestSetup
    static void setData(){
    	Id rdType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('MDG').getRecordTypeId();
        Account acc = new Account (
        Name = 'Test1234',AccountNumber='A2999999',RecordTypeId = rdType, MDGCheck__c = true, mLoevm__c = false);
        insert acc;
        Organization__c org = new Organization__c();
        insert org;
        RecordType RT_OPPTY_HQ   = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
        
        Company__c insertCompany = new Company__c (
            Name                = 'T100 - Name'
            , CompanyCode__c    = 'T100'
            , EPCompanyCode__c  = 'EP1'
            , CurrencyIsoCode   = 'KRW'
            , Country__c        = 'Korea, Republic of'
        );
        insert insertCompany;
		System.debug('Company: '+insertCompany);
        
        CostCenter__c insertCostCenter = new CostCenter__c(
                    Name                = '기술전략팀(T100-11331)'
                    , CurrencyIsoCode   = 'KRW'
                    , CompanyCode__c    = 'T100'
                    , CostCenterName__c = '기술전략팀'
                    , CostCenter__c     = 'T100-11331'
                    , Node1__c          = 'T100'
                    , Node2__c          = 'T100SB'
                    , Node3__c          = 'T100SB1'
                    , Node4__c          = 'T100SB13'
                    , Node5__c          = 'T100SB131'
            		, ZZCheck__c        = true
            		, Text2__c      = '클라우드서비스사업부'
                    , Company__c        = insertCompany.Id
                );
        insert insertCostCenter;     
        System.debug('CostCenter: '+insertCostCenter);
        
        Opportunity Opportunity1 = new Opportunity(
            Name = 'MySales',
            CurrencyIsoCode='EUR',
            OpportunityCode__c='SDS-22001260',
            StageName= 'Z03',
            CspMspType__c = 'CSP',
            Amount = 78,
            AccountId = acc.id,
            SalesOrganization__c = org.id,
            DeliveryOrganization__c = org.id,
            CloseDate = System.today().addDays(5),
            OpportunityStatus__c='E0003',
            CMBizType__c='CSP_SCP',
            RecordTypeId = RT_OPPTY_HQ.Id,
            SalesDepartment__c= insertCostCenter.Id 
            );
        
        insert Opportunity1;
        
        OpportunityAmt__c oppAmt = new OpportunityAmt__c();
        oppAmt.OpportunityCode__c = 'SDS-22001260';
        oppAmt.CompanyCode__c = 'T100';
        oppAmt.Version__c = 'S001';
        oppAmt.Closedate__c = Date.today();
        oppAmt.TotalAmt__c = 1000000;
        oppAmt.Currency__c = 'INR';
        oppAmt.DiffAmt__c = 1000000;
        oppAmt.TotalAmtLoc__c = 1000000;
        oppAmt.CurrencyLoc__c = 'KRW';
        oppAmt.DiffAmtLoc__c = 1000000;
        oppAmt.Rateyn__c = 'N';
        oppAmt.Opportunity__c = Opportunity1.Id;
        
        insert oppAmt;
    }
    @isTest
    public static void Test_Batch_IF185ExchangeRateController(){
        Test.startTest();
        DataBase.executeBatch(new Batch_IF185ExchangeRateController());
        Test.stopTest();
    } 
}