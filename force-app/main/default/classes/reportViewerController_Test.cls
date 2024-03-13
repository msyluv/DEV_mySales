/**
* @description       : Test Class of reportViewerController
* @author            : vikrant.ks@samsung.com
* @group             : 
* @last modified on  : 2023-08-10
* @last modified by  : vikrant.ks@samsung.com 
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2023-08-10   vikrant.ks@samsung.com   Initial Version(MySales 271) 
**/
@isTest(SeeAllData=false)
public class reportViewerController_Test {
    @TestSetup
    static void setData(){
    	Id rdType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('MDG').getRecordTypeId();
        Account acc = new Account (
        Name = 'Test1234',AccountNumber='A2999999',RecordTypeId = rdType, MDGCheck__c = true, mLoevm__c = false);
        insert acc;
        Organization__c org = new Organization__c();
        insert org;
        RecordType RT_OPPTY_HQ   = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
        
        User u = [Select Id,ProfileId from User Where Profile.Name = 'Sales Rep.(HQ)' AND isActive = true Limit 1];
        System.debug('User: '+u);
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
                    , Text4__c      = 'G-CSP Pro-Serv.팀'
                    , Company__c    = insertCompany.Id
                );
        insert insertCostCenter;     
        System.debug('CostCenter: '+insertCostCenter);
        
        Opportunity Opportunity1 = new Opportunity(
            Name = 'MySales',
            CurrencyIsoCode='EUR',
            OpportunityCode__c='SDS-22131801',
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
            SalesDepartment__c= insertCostCenter.Id,
            cPrimarySalesDepartment__c = insertCostCenter.Id
            );

            insert Opportunity1;
        
        RevenueScheduleOpportunity__c RevOpp = new RevenueScheduleOpportunity__c();
        RevOpp.Revenue__c = 1000000;
        RevOpp.ScheduleDate__c = Date.today();
        RevOpp.CurrencyIsoCode = 'KRW';
        RevOpp.Parent__c = Opportunity1.Id;
        insert RevOpp;
        
    }
    @isTest
    public static void reportViewerControllerTest_1(){
        
        Test.startTest();

        reportViewerController.ReportController();
        
        Test.stopTest();
    }
}