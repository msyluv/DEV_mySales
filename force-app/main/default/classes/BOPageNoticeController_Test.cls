@istest
public class BOPageNoticeController_Test {
    static RecordType rcdType_Acc_MDG;
    static RecordType rcdType_Oppty_HQ;
    static Account acc_1;
    static Company__c comp_SDS;
    static CostCenter__c cc_1;
    static Opportunity oppty_HQ_1_HQ;
    static Opportunity oppty_HQ_2_HQ;
    static {
        rcdType_Acc_MDG = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'MDG' Limit 1];
        rcdType_Oppty_HQ = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
        acc_1 = new Account(
            Name = 'Test Account 1',
            RecordTypeId = rcdType_Acc_MDG.Id,
            MDGCheck__c = true
        );
        insert acc_1;
        
        List<Company__c> compList = new List<Company__c>();
        comp_SDS = new Company__c(
            Name = 'Samsung SDS',
            CompanyCode__c = 'T100',
            Country__c = 'KR',
            EPCompanyCode__c = 'C60'
        );
        compList.add(comp_SDS);
        insert compList;
        
        List<CostCenter__c> ccList = new List<CostCenter__c>();
        cc_1 = new CostCenter__c(
            Name = 'Test Cost Center 1', 
            Company__c = comp_SDS.Id, 
            CompanyCode__c = 'T100', 
            CostCenter__c = 'T100-12345'
        );
        ccList.add(cc_1);
        insert ccList;
        
        List<Opportunity> insert_OpptyList = new List<Opportunity>();
        oppty_HQ_1_HQ = new Opportunity(
            Name = 'Test Opportunity 1 HQ',
            RecordTypeId = rcdType_Oppty_HQ.Id,
            CurrencyIsoCode = 'USD',
            Amount = 5000000, 
            CloseDate = Date.today(), 
            StageName = 'Z01',
            BusinessType__c = 'TI',
            AccountId = acc_1.Id, 
            cOriginAcc__c = acc_1.Id, 
            SalesDepartment__c = cc_1.Id,
            CspMspType__c = 'CSP',
            CMEntAlertCnt__c = 0,
            KRWNoticeCnt__c =0
            
        );
        oppty_HQ_2_HQ = new Opportunity(
            Name = 'Test Opportunity 2 HQ',
            RecordTypeId = rcdType_Oppty_HQ.Id,
            CurrencyIsoCode = 'USD',
            Amount = 5000000, 
            CloseDate = Date.today(), 
            StageName = 'Z01',
            BusinessType__c = 'TI',
            AccountId = acc_1.Id, 
            cOriginAcc__c = acc_1.Id, 
            SalesDepartment__c = cc_1.Id,
            CspMspType__c = 'CSP',
            CMEntAlertCnt__c = 0,
            KRWNoticeCnt__c =0,
            Opportunity_Review_VRB_Type_Confirm__c = '30',
            Opportunity_Review_Confirm__c = true
            );
        
        insert_OpptyList.add(oppty_HQ_1_HQ);
        insert_OpptyList.add(oppty_HQ_2_HQ);
        insert insert_OpptyList;
        
    }
    
    @isTest
    private static void Test_BOPageNoticeController() { 
        Test.startTest();
        
        BOPageNoticeController.getCMEnterAlertMsg(oppty_HQ_1_HQ.Id);
        Test.stopTest();
    }
    
    @isTest
    private static void Test_BOPageNoticeControllerChangeAccount() { 
        Test.startTest();
        Opportunity opp = [Select id,Is_change_Account__c from opportunity where id =: oppty_HQ_1_HQ.Id];
        opp.Is_change_Account__c = true;
        update opp;
        Opportunity_Activity__c opActivity = new Opportunity_Activity__c(WhatId__c = opp.Id , TransactionName__c = 'ZP21');
        insert opActivity;
        BOPageNoticeController.getCMEnterAlertMsg(opp.Id);
        Test.stopTest();
    }
    
    @isTest
    private static void Test_BOPageNoticeControllerChangeAccount1() { 
        Test.startTest();
        Opportunity opp = [Select id,Is_change_Account__c from opportunity where id =: oppty_HQ_2_HQ.Id];
        opp.Is_change_Account__c = true;
        update opp;
        Opportunity_Activity__c opActivity = new Opportunity_Activity__c(WhatId__c = opp.Id , TransactionName__c = 'ZP21');
        insert opActivity;
        BOPageNoticeController.getCMEnterAlertMsg(opp.Id);
        Test.stopTest();
    }
}