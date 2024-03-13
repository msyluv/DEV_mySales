/**
* @description       : Test Class of Batch_SendTXPManpowerInfo(IF-184)
* @author            : vikrant.ks@samsung.com
* @group             : 
* @last modified on  : 2023-12-05
* @last modified by  : vikrant.ks@samsung.com 
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2023-12-05   vikrant.ks@samsung.com   Initial Version(MySales 374) 
**/
@isTest(SeeAllData=false)
public class Batch_SendTXPManpowerInfo_Test {
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
        
        TXPmanpower__c txpTemp      = new TXPmanpower__c();
        txpTemp.Opportunity__c      = Opportunity1.Id;
        txpTemp.BOCode__c           = Opportunity1.OpportunityCode__c;
        txpTemp.companycode__c      = 'T100';
        txpTemp.ProposalPMNo__c     = '12345';
        txpTemp.ProposalPMStatus__c = 'ASSGNREQ';
        txpTemp.ProposalPMStDt__c   = Date.valueOf('2023-1-8');
        txpTemp.ProposalPMEdDt__c   = Date.valueOf('2023-12-31');
        txpTemp.ExecutionPMNo__c    = '12345';
        txpTemp.ExecutionPMStatus__c= 'ASSGNEND';
        txpTemp.ExecutionPMStDt__c  = Date.valueOf('2023-10-1');
        txpTemp.ExecutionPMEdDt__c  = Date.valueOf('2024-2-3');
        txpTemp.ProposalPMPlan__c   = 'Y';
        txpTemp.ExecutionPMPlan__c  = 'Y';
        txpTemp.P_Projectcode__c    = '09643';
        txpTemp.E_Projectcode__c    = '123567';
        
        upsert txpTemp;
        System.debug('txpTemp'+txpTemp);
    }
    @isTest
    public static void TXPManpowerInputInfoTest_1(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        
        String oppID = [Select Id from Opportunity Limit 1].Id;
        Set<String> BoList = new Set<String>{oppID};
            
		Batch_SendTXPManpowerInfo Batch_SendTXPInfo = new Batch_SendTXPManpowerInfo();
        Batch_SendTXPInfo.BoIdList = BoList;
		DataBase.executeBatch(Batch_SendTXPInfo, 200); 
        
        Test.stopTest();
    }
}