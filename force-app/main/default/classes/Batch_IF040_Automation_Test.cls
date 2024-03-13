/**
* @description       : 
* @author            : vikrant.ks@samsung.com
* @group             : 
* @last modified on  : 2023-12-21
* @last modified by  : vikrant.ks@samsung.com 
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2023-12-21   vikrant.ks@samsung.com   Initial Version
**/
@isTest(SeeAllData=false)
public class Batch_IF040_Automation_Test {
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
        
        Opportunity_Activity__c opptyAct_ZP21 = new Opportunity_Activity__c(
            Status__c='In Progress'
            , DueDate__c=System.today()
            , WhatId__c=Opportunity1.Id
            , TransactionName__c ='ZP21'
            , Index__c=2
            , Description__c = 'TEST, opptyAct_ZP21, DescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescription~~!!'
        );
        
        insert opptyAct_ZP21;
        
        
        Master_Service__c master_service = new Master_Service__c(
            Name = 'Test Master Service',
            Code__c = '20000026'
        );
        insert master_service;
        
        
        Master_Solution__c master_solution = new Master_Solution__c(
            Name = 'Test Master Solution',
            Code__c = '30000135'
        );
        insert master_solution;
        
         BizAttribute__c master_attribute = new BizAttribute__c(
            Name = 'Test Master Attribute',
            Code__c = 'S109'
        );
        insert master_attribute;
        
        SvcSolBizAttr__c svcSolBizAttr =  new SvcSolBizAttr__c(
            BizAttribute__c = master_attribute.Id,
            BusinessType__c = 'TI',
            Solution__c = master_solution.Id,
            WBSClass__c = 'SM',
            PSType__c = 'SM1',
            Use__c = true
        );
        insert svcSolBizAttr;
        
       Service__c service = new Service__c(
            Opportunity__c = Opportunity1.Id,
            sService__c = master_service.Id,
            sDeliveryDepartment__c = insertCostCenter.Id,
            sSalesDepartment__c  = insertCostCenter.Id,
            ItemNumber__c = 10,
            Changed__c = true,
            sDeletionFlag__c = false
        );
        insert service;
        
        Solution__c solution = new Solution__c(
            Opportunity__c = Opportunity1.Id,
            Service__c = service.Id,
            sBizAttribute__c = master_attribute.Id,
            sSolution__c = master_solution.Id,
            sPSType__c = svcSolBizAttr.PsType__c,
            sWBSClass__c = svcSolBizAttr.WBSClass__c,
            sBusinessType__c = svcSolBizAttr.BusinessType__c,
            Changed__c = true,
            sDeletionFlag__c = false,
            SendSAP__c = true
        );
        insert solution;

        MigOppCode__c  migOppCd = new MigOppCode__c(
            Name               = Opportunity1.Id
            ,OpportunityCode__c = Opportunity1.OpportunityCode__c
            ,InterfaceId__c     = 'IF-040'
        );
        insert migOppCd;
        
    }
    @isTest
    public static void Batch_IF040_AutomationTest_1(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        DataBase.executeBatch(new Batch_IF040_Automation(), 1);
        
        Test.stopTest();
    }
}