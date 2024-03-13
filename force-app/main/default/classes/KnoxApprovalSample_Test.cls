/**
 * @description       : 
 * @author            : dongyoung.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-03-19
 * @last modified by  : Junghwa.Kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-03-19   dongyoung.kim@dkbmc.com   Initial Version
**/
@isTest
public class KnoxApprovalSample_Test {

    static List<Opportunity> opptyList;
    static List<Opportunity_Activity__c> opptyActList;
    // [S] ZP32
    static Opportunity zp32_oppty_1;
    static Opportunity zp32_oppty_2;
    static Opportunity_Activity__c zp32_opptyAct_1;
    static Opportunity_Activity__c zp32_opptyAct_2;
    static Opportunity_Activity__c zp32_opptyAct_3;
    static Opportunity_Activity__c zp32_opptyAct_4;
    // [E] ZP32

    // [S] ZP62
    static Opportunity zp62_oppty_0;
    static Opportunity zp62_oppty_1;
    static Opportunity zp62_oppty_2;
    static Opportunity zp62_oppty_3;
    static Opportunity_Activity__c zp62_opptyAct_1;
    static Opportunity_Activity__c zp62_opptyAct_2;
    static Opportunity_Activity__c zp62_opptyAct_3;
    // [E] ZP62

    // [S] ZP82
    static Opportunity zp82_oppty_1;
    static Opportunity_Activity__c zp82_opptyAct_1;
    static Opportunity zp82_oppty_2;
    static Opportunity_Activity__c zp82_opptyAct_2;
    static Opportunity zp82_oppty_3;
    static Opportunity_Activity__c zp82_opptyAct_3;
    static Opportunity zp82_oppty_4;
    static Opportunity_Activity__c zp82_opptyAct_4;
    static Opportunity zp82_oppty_5;
    static Opportunity_Activity__c zp82_opptyAct_5;
    static Opportunity zp82_oppty_6;
    static Opportunity_Activity__c zp82_opptyAct_6;
    static Opportunity zp82_oppty_7;
    static Opportunity_Activity__c zp82_opptyAct_7;
    static Opportunity zp82_oppty_8;
    static Opportunity_Activity__c zp82_opptyAct_8;
    static Project__c project;
    // [E] ZP82

    // [S] ZPZ1
    static Opportunity zpz1_oppty_1;
    static Opportunity zpz1_oppty_2;
    static Opportunity_Activity__c zpz1_opptyAct_1;
    static Opportunity_Activity__c zpz1_opptyAct_2;
    // [E] ZPZ1

    // [S] ZPZ2
    static Opportunity zpz2_oppty_1;
    static Opportunity zpz2_oppty_2;
    static Opportunity zpz2_oppty_3;
    static Opportunity zpz2_oppty_4;
    static Opportunity_Activity__c zpz2_opptyAct_1;
    static Opportunity_Activity__c zpz2_opptyAct_2;
    static Opportunity_Activity__c zpz2_opptyAct_3;
    static Opportunity_Activity__c zpz2_opptyAct_4;
    // [E] ZPZ2

    // [S] ZPZ3
    static Opportunity zpz3_oppty_1;
    static Opportunity_Activity__c zpz3_opptyAct_1;
    // [E] ZPZ3

    // [S] ZPG1
    static Opportunity zpg1_oppty_1;
    static Opportunity_Activity__c zpg1_opptyAct_1;
    // [E] ZPG1

    static Biz_Review__c bizReview_cost_y;
    static Biz_Review__c bizReview_cost_n;
    static Biz_Review__c bizReview_cost_a;
    static Biz_Review__c bizReview_cost_b;
    static Biz_Review__c bizReview_cost_c;

    static String EV_EXIST;
    static Integer status;

    static {
        // [Trigger Switch Setting ] Default Org Switch Setup
        TriggerSwitch__c trSwitch_default = new TriggerSwitch__c(
            All__c = true,
            Opportunity__c = true,
            OpportunityActivity__c = true
        );
        insert trSwitch_default;

        RecordType RT_OPPTY_HQ   = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
        Company__c company = new Company__c();
        company.Name = 'test';
        company.CompanyCode__c = 'T100';
        insert company;

        CostCenter__c cCenter = new CostCenter__c();
        cCenter.CostCenter__c = 'test12';
        cCenter.Company__c = company.id;
        insert cCenter;

        Company__c company1 = new Company__c();
        company1.Name = 'test';
        company1.CompanyCode__c = '';
        insert company1;

        CostCenter__c cCenter1 = new CostCenter__c();
        cCenter1.CostCenter__c = 'test123';
        cCenter1.Company__c = company1.id;
        insert cCenter1;

        opptyList = new List<Opportunity>();
        opptyActList = new List<Opportunity_Activity__c>();

        // [S] Opportunity
        zp32_oppty_1 = new Opportunity(
            Name = 'Test Oppty for zp32',
            StageName = 'Z01',
            CloseDate = Date.today(),
            RecordTypeId = RT_OPPTY_HQ.Id
        );
        opptyList.add(zp32_oppty_1);

        zp32_oppty_2 = new Opportunity(
            Name = 'Test Oppty for zp32',
            StageName = 'Z01',
            CloseDate = Date.today(),
            RecordTypeId = RT_OPPTY_HQ.Id
        );
        opptyList.add(zp32_oppty_2);

        zp62_oppty_0 = new Opportunity(
            Name = 'Test Oppty for zp62',
            StageName = 'Z01',
            CloseDate = Date.today(),
            DealBreak__c = false,
            SalesDepartment__c = cCenter1.Id,
            RecordTypeId = RT_OPPTY_HQ.Id
        );
        opptyList.add(zp62_oppty_0);

        zp62_oppty_1 = new Opportunity(
            Name = 'Test Oppty for zp62',
            StageName = 'Z01',
            CloseDate = Date.today(),
            DealBreak__c = false,
            SalesDepartment__c = cCenter.Id,
            RecordTypeId = RT_OPPTY_HQ.Id
        );
        opptyList.add(zp62_oppty_1);

        zp62_oppty_2 = new Opportunity(
            Name = 'Test Oppty for zp62',
            StageName = 'Z01',
            CloseDate = Date.today(),
            DealBreak__c = true,
            BusinessType__c = 'TI',
            RecordTypeId = RT_OPPTY_HQ.Id
        );
        opptyList.add(zp62_oppty_2);

        zp62_oppty_3 = new Opportunity(
            Name = 'Test Oppty for zp62',
            StageName = 'Z01',
            CloseDate = Date.today(),
            DealBreak__c = true,
            BusinessType__c = 'TI',
            RecordTypeId = RT_OPPTY_HQ.Id
        );
        opptyList.add(zp62_oppty_3);


        zp82_oppty_1 = new Opportunity(
            Name = 'Test Oppty for zp82',
            StageName = 'Z01',
            CloseDate = Date.today(),
            DealBreak__c = false,
            RecordTypeId = RT_OPPTY_HQ.Id
        );
        opptyList.add(zp82_oppty_1);

        zp82_oppty_2 = new Opportunity(
            Name = 'Test Oppty for zp82',
            StageName = 'Z01',
            CloseDate = Date.today(),
            DealBreak__c = true,
            BusinessType__c = 'TI',
            RecordTypeId = RT_OPPTY_HQ.Id
        );
        opptyList.add(zp82_oppty_2);

        zp82_oppty_3 = new Opportunity(
            Name = 'Test Oppty for zp82',
            StageName = 'Z05',
            CloseDate = Date.today(),
            DealBreak__c = true,
            BusinessType__c = 'TI',
            RecordTypeId = RT_OPPTY_HQ.Id
        );
        opptyList.add(zp82_oppty_3);

        zp82_oppty_4 = new Opportunity(
            Name = 'Test Oppty for zp82',
            StageName = 'Z05',
            CloseDate = Date.today(),
            DealBreak__c = false,
            BusinessType__c = 'TD',
            RecordTypeId = RT_OPPTY_HQ.Id
        );
        opptyList.add(zp82_oppty_4);
        
        zp82_oppty_5 = new Opportunity(
            Name = 'Test Oppty for zp82',
            StageName = 'Z01',
            CloseDate = Date.today(),
            DealBreak__c = false,
            BusinessType__c = 'TI',
            RecordTypeId = RT_OPPTY_HQ.Id
        );
        opptyList.add(zp82_oppty_5);
        
        zp82_oppty_6 = new Opportunity(
            Name = 'Test Oppty for zp82',
            StageName = 'Z01',
            CloseDate = Date.today(),
            DealBreak__c = false,
            BusinessType__c = 'TD',
            RecordTypeId = RT_OPPTY_HQ.Id
        );
        opptyList.add(zp82_oppty_6);

        zpz1_oppty_1 = new Opportunity(
            Name = 'Test Oppty for zpz1',
            StageName = 'Z01',
            CloseDate = Date.today(),
            RecordTypeId = RT_OPPTY_HQ.Id
        );
        opptyList.add(zpz1_oppty_1);

        
        zpz1_oppty_2 = new Opportunity(
            Name = 'Test Oppty for zpz1',
            RecordTypeId = RT_OPPTY_HQ.Id,
            StageName = 'Z06',
            CloseDate = Date.today(),
            LostReasonLogistics__c = 'A1Z0000005A010'
        );
        opptyList.add(zpz1_oppty_2);

        zpz2_oppty_1 = new Opportunity(
            Name = 'Test Oppty for zpz2',
            StageName = 'Z01',
            CloseDate = Date.today(),
            RecordTypeId = RT_OPPTY_HQ.Id
        );
        opptyList.add(zpz2_oppty_1);

        zpz2_oppty_2 = new Opportunity(
            Name = 'Test Oppty for zpz2',
            StageName = 'Z01',
            CloseDate = Date.today(),
            BusinessType__c = 'TI',
            RecordTypeId = RT_OPPTY_HQ.Id
        );
        opptyList.add(zpz2_oppty_2);

        zpz2_oppty_3 = new Opportunity(
            Name = 'Test Oppty for zpz2',
            StageName = 'Z01',
            CloseDate = Date.today(),
            BusinessType__c = 'TS',
            RecordTypeId = RT_OPPTY_HQ.Id
        );
        opptyList.add(zpz2_oppty_3);

        zpz2_oppty_4 = new Opportunity(
            Name = 'Test Oppty for zpz2',
            StageName = 'Z01',
            CloseDate = Date.today(),
            BusinessType__c = 'TD',
            RecordTypeId = RT_OPPTY_HQ.Id
        );
        opptyList.add(zpz2_oppty_4);
        

        zpz3_oppty_1 = new Opportunity(
            Name = 'Test Oppty for zpz3',
            StageName = 'Z01',
            CloseDate = Date.today(),
            RecordTypeId = RT_OPPTY_HQ.Id
        );
        opptyList.add(zpz3_oppty_1);

        zpg1_oppty_1 = new Opportunity(
            Name = 'Test Oppty for zpg1',
            StageName = 'Z01',
            CloseDate = Date.today(),
            RecordTypeId = RT_OPPTY_HQ.Id
            );
        opptyList.add(zpg1_oppty_1);
        
        insert opptyList;

        zp82_oppty_3.CollaborationBOId__c = zp82_oppty_2.Id;
        zp82_oppty_4.CollaborationBOId__c = zp82_oppty_3.Id;
        update zp82_oppty_3;
        update zp82_oppty_4;

        // [E] Opportunity

        // [S] Opportunity Activity
        zp32_opptyAct_1 = new Opportunity_Activity__c(
            Status__c = 'In Progress', 
            TransactionName__c= 'ZP32',
            WhatId__c = zp32_oppty_1.Id,
            ExtID__c = zp32_oppty_1.Id + '_ZP32'
        );
        opptyActList.add(zp32_opptyAct_1);

        zp32_opptyAct_2 = new Opportunity_Activity__c(
            Status__c = 'Completed', 
            TransactionName__c= 'ZP32',
            WhatId__c = zp32_oppty_2.Id,
            ExtID__c = zp32_oppty_2.Id + '_ZP32'
        );
        opptyActList.add(zp32_opptyAct_2);

        zp32_opptyAct_3 = new Opportunity_Activity__c(
            Status__c = 'Not Started', 
            TransactionName__c= 'ZP32',
            WhatId__c = zp32_oppty_2.Id,
            ExtID__c = zp32_oppty_2.Id + '_ZP32'
        );
        opptyActList.add(zp32_opptyAct_3);

        zp32_opptyAct_4 = new Opportunity_Activity__c(
            Status__c = 'N/A', 
            TransactionName__c= 'ZP32',
            WhatId__c = zp32_oppty_2.Id,
            ExtID__c = zp32_oppty_2.Id + '_ZP32'
        );
        opptyActList.add(zp32_opptyAct_4);

        
        zp62_opptyAct_1 = new Opportunity_Activity__c(
            Status__c = 'Completed', 
            TransactionName__c= 'ZP62',
            WhatId__c = zp62_oppty_1.Id,
            ExtID__c = zp62_oppty_1.Id + '_ZP62'
        );
        opptyActList.add(zp62_opptyAct_1);

        zp62_opptyAct_2 = new Opportunity_Activity__c(
            Status__c = 'Completed', 
            TransactionName__c= 'ZP62',
            WhatId__c = zp62_oppty_2.Id,
            ExtID__c = zp62_oppty_2.Id + '_ZP62'
        );
        opptyActList.add(zp62_opptyAct_2);

        zp62_opptyAct_3 = new Opportunity_Activity__c(
            Status__c = 'Completed', 
            TransactionName__c= 'ZP62',
            WhatId__c = zp62_oppty_3.Id,
            ExtID__c = zp62_oppty_3.Id + '_ZP62'
        );
        opptyActList.add(zp62_opptyAct_3);


        zp82_opptyAct_1 = new Opportunity_Activity__c(
            Status__c = 'Completed', 
            TransactionName__c= 'ZP82',
            WhatId__c = zp82_oppty_1.Id,
            ExtID__c = zp82_oppty_1.Id + '_ZP82'
        );
        opptyActList.add(zp82_opptyAct_1);

        zp82_opptyAct_2 = new Opportunity_Activity__c(
            Status__c = 'Completed', 
            TransactionName__c= 'ZP82',
            WhatId__c = zp82_oppty_2.Id,
            ExtID__c = zp82_oppty_2.Id + '_ZP82'
        );
        opptyActList.add(zp82_opptyAct_2);

        zp82_opptyAct_3 = new Opportunity_Activity__c(
            Status__c = 'Completed', 
            TransactionName__c= 'ZP82',
            WhatId__c = zp82_oppty_3.Id,
            ExtID__c = zp82_oppty_3.Id + '_ZP82'
        );
        opptyActList.add(zp82_opptyAct_3);

        zp82_opptyAct_4 = new Opportunity_Activity__c(
            Status__c = 'Completed', 
            TransactionName__c= 'ZP82',
            WhatId__c = zp82_oppty_4.Id,
            ExtID__c = zp82_oppty_4.Id + '_ZP82'
        );
        opptyActList.add(zp82_opptyAct_4);
        
        
        zp82_opptyAct_5 = new Opportunity_Activity__c(
            Status__c = 'Completed', 
            TransactionName__c= 'ZP82',
            WhatId__c = zp82_oppty_5.Id,
            ExtID__c = zp82_oppty_5.Id + '_ZP82'
        );
        opptyActList.add(zp82_opptyAct_5);
        
        zp82_opptyAct_6 = new Opportunity_Activity__c(
            Status__c = 'Completed', 
            TransactionName__c= 'ZP82',
            WhatId__c = zp82_oppty_6.Id,
            ExtID__c = zp82_oppty_6.Id + '_ZP82'
        );
        opptyActList.add(zp82_opptyAct_6);

        zpz1_opptyAct_1 = new Opportunity_Activity__c(
            Status__c = 'Completed', 
            TransactionName__c= 'ZPZ1',
            WhatId__c = zpz1_oppty_1.Id,
            ExtID__c = zpz1_oppty_1.Id + '_ZPZ1'
        );
        opptyActList.add(zpz1_opptyAct_1);

        zpz1_opptyAct_2 = new Opportunity_Activity__c(
            Status__c = 'Completed', 
            TransactionName__c= 'ZPZ1',
            WhatId__c = zpz1_oppty_2.Id,
            ExtID__c = zpz1_oppty_2.Id + '_ZPZ1'
        );
        opptyActList.add(zpz1_opptyAct_2);

        zpz2_opptyAct_1 = new Opportunity_Activity__c(
            Status__c = 'Completed', 
            TransactionName__c= 'ZPZ2',
            WhatId__c = zpz2_oppty_1.Id,
            ExtID__c = zpz2_oppty_1.Id + '_ZPZ2'
        );
        opptyActList.add(zpz2_opptyAct_1);

        zpz2_opptyAct_2 = new Opportunity_Activity__c(
            Status__c = 'Completed', 
            TransactionName__c= 'ZPZ2',
            WhatId__c = zpz2_oppty_2.Id,
            ExtID__c = zpz2_oppty_2.Id + '_ZPZ2'
        );
        opptyActList.add(zpz2_opptyAct_2);

        zpz2_opptyAct_3 = new Opportunity_Activity__c(
            Status__c = 'Completed', 
            TransactionName__c= 'ZPZ2',
            WhatId__c = zpz2_oppty_3.Id,
            ExtID__c = zpz2_oppty_3.Id + '_ZPZ2'
        );
        opptyActList.add(zpz2_opptyAct_3);

        zpz2_opptyAct_4 = new Opportunity_Activity__c(
            Status__c = 'Completed', 
            TransactionName__c= 'ZPZ2',
            WhatId__c = zpz2_oppty_4.Id,
            ExtID__c = zpz2_oppty_4.Id + '_ZPZ2'
        );
        opptyActList.add(zpz2_opptyAct_4);

        zpz3_opptyAct_1 = new Opportunity_Activity__c(
            Status__c = 'Completed', 
            TransactionName__c= 'ZPZ3',
            WhatId__c = zpz3_oppty_1.Id,
            ExtID__c = zpz3_oppty_1.Id + '_ZPZ3'
        );
        opptyActList.add(zpz3_opptyAct_1);

        zpg1_opptyAct_1 = new Opportunity_Activity__c(
            Status__c = 'Completed', 
            TransactionName__c= 'ZPG1',
            WhatId__c = zpg1_oppty_1.Id,
            ExtID__c = zpg1_oppty_1.Id + '_ZPG1'
        );
        opptyActList.add(zpg1_opptyAct_1);
        
        insert opptyActList;
        // [E] Opportunity Activity

        // [S] Project
        project = new Project__c(
            Name = 'Test Project', 
            Opportunity__c = zp82_oppty_1.Id, 
            ProjectCode__c = 'SIC-21007741-A0', 
            DeletionFlag__c = false            
        );
        insert project;
        // [E] Project


        bizReview_cost_y = new Biz_Review__c(
            Opportunity__c = zp62_oppty_1.Id,
            Costplanningreadiness__c = 'Yes', 
            OriginalPriceVersion__c = 'F001', 
            Version__c = 1, 
            Decision__c = 'Participation'
        );
        insert bizReview_cost_y;

        bizReview_cost_n = new Biz_Review__c(
            Opportunity__c = zp62_oppty_1.Id,
            Costplanningreadiness__c = 'No',             
            Version__c = 2, 
            Decision__c = 'Participation'
        );
        insert bizReview_cost_n;

        bizReview_cost_a = new Biz_Review__c(
            Opportunity__c = zp62_oppty_1.Id,
            //Costplanningreadiness__c = 'Yes', 
            OriginalPriceVersion__c = 'F001', 
            Version__c = 1, 
            Decision__c = 'Participation'
        );
        insert bizReview_cost_a;

        bizReview_cost_b = new Biz_Review__c(
            Opportunity__c = zp62_oppty_1.Id,
            Costplanningreadiness__c = 'Yes', 
            OriginalPriceVersion__c = '0000', 
            Version__c = 1
            //Decision__c = 'Participation'
        );
        insert bizReview_cost_b;
        
        bizReview_cost_c = new Biz_Review__c(
            Opportunity__c = zp62_oppty_0.Id,
            Costplanningreadiness__c = 'Yes', 
            OriginalPriceVersion__c = '0000', 
            Version__c = 1
            //Decision__c = 'Participation'
        );
        insert bizReview_cost_c;
    }

    @isTest static void test_method1(){
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());

        // Activity status == 'In Progress'
        KnoxApprovalValidation.validationCheck(zp32_opptyAct_1.Id, null);

        // Activity status != 'In Progress'
        // IF-056 - EV_CONTAPRO_OK == 'S'
        KnoxApprovalValidation.validationCheck(zp32_opptyAct_2.Id, null);

        // Activity status != 'In Progress'
        // IF-056 - EV_CONTAPRO_OK == 'S'
        KnoxApprovalValidation.validationCheck(zp32_opptyAct_3.Id, null);

        // Activity status != 'In Progress'
        // IF-056 - EV_CONTAPRO_OK == 'S'
        KnoxApprovalValidation.validationCheck(zp32_opptyAct_4.Id, null);

        // Activity status == 'In Progress'
        KnoxApprovalValidation.validationCheck(zp62_opptyAct_1.Id, bizReview_cost_y.Id);

        // Activity status != 'In Progress'
        // IF-056 - EV_CONTAPRO_OK == 'S'
        KnoxApprovalValidation.validationCheck(zp62_opptyAct_1.Id, bizReview_cost_n.Id);

        KnoxApprovalValidation.validationCheck(zp62_opptyAct_3.Id, null);

        

        Test.setMock(HttpCalloutMock.class, new IF_Callout_SampleMock());

        KnoxApprovalValidation.validationCheck(zp32_opptyAct_1.Id, null);

        KnoxApprovalValidation.validationCheck(zp82_opptyAct_1.Id, null);

		Test.stopTest();
    }

    @isTest static void test_method3(){
		Test.startTest();
                
        status = 200;
        EV_EXIST = 'Z';
        Test.setMock(HttpCalloutMock.class, new GenericMock());
        KnoxApprovalValidation.validationCheck(zp82_opptyAct_1.Id, null);
        
        EV_EXIST = 'Y';
        Test.setMock(HttpCalloutMock.class, new GenericMock());
        KnoxApprovalValidation.validationCheck(zp82_opptyAct_1.Id, null);
        EV_EXIST = 'X';
        Test.setMock(HttpCalloutMock.class, new GenericMock());
        KnoxApprovalValidation.validationCheck(zp82_opptyAct_5.Id, null);
        KnoxApprovalValidation.validationCheck(zp82_opptyAct_6.Id, null);
        
        status = 400;
        EV_EXIST = 'Y';
        Test.setMock(HttpCalloutMock.class, new GenericMock());
        KnoxApprovalValidation.validationCheck(zp82_opptyAct_1.Id, null);
        EV_EXIST = 'X';
        Test.setMock(HttpCalloutMock.class, new GenericMock());
        KnoxApprovalValidation.validationCheck(zp82_opptyAct_5.Id, null);
        KnoxApprovalValidation.validationCheck(zp82_opptyAct_6.Id, null);
        

        
		Test.stopTest();
    }

    @isTest static void test_method2(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        // Activity status != 'In Progress'
        // IF-056 - EV_CONTAPRO_OK == 'S'
        KnoxApprovalValidation.validationCheck(zp62_opptyAct_1.Id, bizReview_cost_a.Id);

        // Activity status != 'In Progress'
        // IF-056 - EV_CONTAPRO_OK == 'S'
        KnoxApprovalValidation.validationCheck(zp62_opptyAct_1.Id, bizReview_cost_b.Id);
        

        // Activity status == 'In Progress'
        KnoxApprovalValidation.validationCheck(zp82_opptyAct_1.Id, null);

        // Activity status != 'In Progress'
        // IF-056 - EV_CONTAPRO_OK == 'S'
        KnoxApprovalValidation.validationCheck(zp82_opptyAct_2.Id, null);

        // Activity status != 'In Progress'
        // IF-056 - EV_CONTAPRO_OK == 'S'
        KnoxApprovalValidation.validationCheck(zp82_opptyAct_3.Id, null);

        // Activity status != 'In Progress'
        // IF-056 - EV_CONTAPRO_OK == 'S'
        KnoxApprovalValidation.validationCheck(zp82_opptyAct_4.Id, null);
        
        // Opportunity LostReasonLogistics__c 입력
        KnoxApprovalValidation.validationCheck(zpz1_opptyAct_1.Id, null);

        // Opportunity LostReasonLogistics__c 미입력
        KnoxApprovalValidation.validationCheck(zpz1_opptyAct_2.Id, null);

        // Opportunity Business == 'TI'
        KnoxApprovalValidation.validationCheck(zpz2_opptyAct_1.Id, null);

        // Opportunity Business == 'TD'
        KnoxApprovalValidation.validationCheck(zpz2_opptyAct_2.Id, null);

        // Opportunity Business == 'TS'
        KnoxApprovalValidation.validationCheck(zpz2_opptyAct_3.Id, null);

        // Opportunity Business == ''
        KnoxApprovalValidation.validationCheck(zpz2_opptyAct_4.Id, null);

        // IF-055 - EV_STATUS != 1
        KnoxApprovalValidation.validationCheck(zpz3_opptyAct_1.Id, null);

        KnoxApprovalValidation.validationCheck(zpg1_opptyAct_1.Id, null);

		Test.stopTest();
    }
    public class GenericMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            String jsonData = '';
            if(EV_EXIST.equals('Z')){
                if(req.getEndpoint().indexOf('/if056/') > -1){
                    jsonData =  '{ ' +
                    '    "T_RTN": [ ' +
                    '        { ' +
                    '           "TYPE": "W", ' +
                    '           "ID": 0, ' +
                    '           "NUMBER": 398, ' +
                    '           "MESSAGE": "string", ' +
                    '           "LOG_NO": "string", ' +
                    '           "LOG_MSG_NO": 0, ' +
                    '           "MESSAGE_V1": "Entertainment Expense exceeded the limit.", ' +
                    '           "MESSAGE_V2": "string", ' +
                    '           "MESSAGE_V3": "SIC16320291A000", ' +
                    '           "MESSAGE_V4": "S002", ' +
                    '           "PARAMETER": "string", ' +
                    '           "ROW": 0, ' +
                    '           "FIELD": "string", ' +
                    '           "SYSTEM": "string" ' +
                    '        } ' +
                    '    ], ' +
                    '    "EV_VERSION": "S002", ' +
                    '    "EV_VNCRE": 0, ' +
                    '    "EV_RTNST": "S", ' +
                    '    "EV_HURDLERATE_OK": "X", ' +
                    '    "EV_CONTAPRO_OK": "S", ' +
                    '    "EV_EXTERN_ACT_ID": "string", ' +
                    '    "EV_PRESALE_LIMIT": "string", ' +
                    '    "EV_OUTCOME_YN": "string", ' +
                    '    "EV_OUTCOST_YN": "string", ' +
                    '    "EV_EXCEPT": "string", ' +
                    '    "EV_PRESALES_YN": "Y", ' +
                    '    "EV_OPERATING_INCOME": "string" ' +
                    '} ' ;
                } else if(req.getEndpoint().indexOf('/if102/') > -1){
                    jsonData =  '{ ' +
                                '   "EV_EXIST": " ", ' +
                                '   "EV_BO_CHECK": "X", ' +
                                '   "EV_PJT_CHECK": "  " ' +
                                '}'; 
                }
            }
            if(EV_EXIST.equals('X')){
                if(req.getEndpoint().indexOf('/if056/') > -1){
                    jsonData =  '{ ' +
                    '    "T_RTN": [ ' +
                    '        { ' +
                    '           "TYPE": "W", ' +
                    '           "ID": 0, ' +
                    '           "NUMBER": 398, ' +
                    '           "MESSAGE": "string", ' +
                    '           "LOG_NO": "string", ' +
                    '           "LOG_MSG_NO": 0, ' +
                    '           "MESSAGE_V1": "Entertainment Expense exceeded the limit.", ' +
                    '           "MESSAGE_V2": "string", ' +
                    '           "MESSAGE_V3": "SIC16320291A000", ' +
                    '           "MESSAGE_V4": "S002", ' +
                    '           "PARAMETER": "string", ' +
                    '           "ROW": 0, ' +
                    '           "FIELD": "string", ' +
                    '           "SYSTEM": "string" ' +
                    '        } ' +
                    '    ], ' +
                    '    "EV_VERSION": "S002", ' +
                    '    "EV_VNCRE": 0, ' +
                    '    "EV_RTNST": "S", ' +
                    '    "EV_HURDLERATE_OK": "X", ' +
                    '    "EV_CONTAPRO_OK": "S", ' +
                    '    "EV_EXTERN_ACT_ID": "string", ' +
                    '    "EV_PRESALE_LIMIT": "string", ' +
                    '    "EV_OUTCOME_YN": "string", ' +
                    '    "EV_OUTCOST_YN": "string", ' +
                    '    "EV_EXCEPT": "string", ' +
                    '    "EV_PRESALES_YN": "Y", ' +
                    '    "EV_OPERATING_INCOME": "string" ' +
                    '} ' ;
                } else if(req.getEndpoint().indexOf('/if102/') > -1){
                    jsonData =  '{ ' +
                                '   "EV_EXIST": " ", ' +
                                '   "EV_BO_CHECK": "X", ' +
                                '   "EV_PJT_CHECK": "X" ' +
                                '}'; 
                }
            }
            if(EV_EXIST.equals('Y')){
                if(req.getEndpoint().indexOf('/if056/') > -1){
                    jsonData =  '{ ' +
                    '    "T_RTN": [ ' +
                    '        { ' +
                    '           "TYPE": "W", ' +
                    '           "ID": 0, ' +
                    '           "NUMBER": 398, ' +
                    '           "MESSAGE": "string", ' +
                    '           "LOG_NO": "string", ' +
                    '           "LOG_MSG_NO": 0, ' +
                    '           "MESSAGE_V1": "Entertainment Expense exceeded the limit.", ' +
                    '           "MESSAGE_V2": "string", ' +
                    '           "MESSAGE_V3": "SIC16320291A000", ' +
                    '           "MESSAGE_V4": "S002", ' +
                    '           "PARAMETER": "string", ' +
                    '           "ROW": 0, ' +
                    '           "FIELD": "string", ' +
                    '           "SYSTEM": "string" ' +
                    '        } ' +
                    '    ], ' +
                    '    "EV_VERSION": "S002", ' +
                    '    "EV_VNCRE": 0, ' +
                    '    "EV_RTNST": "S", ' +
                    '    "EV_HURDLERATE_OK": "X", ' +
                    '    "EV_CONTAPRO_OK": "S", ' +
                    '    "EV_EXTERN_ACT_ID": "string", ' +
                    '    "EV_PRESALE_LIMIT": "string", ' +
                    '    "EV_OUTCOME_YN": "string", ' +
                    '    "EV_OUTCOST_YN": "string", ' +
                    '    "EV_EXCEPT": "string", ' +
                    '    "EV_PRESALES_YN": "Y", ' +
                    '    "EV_OPERATING_INCOME": "string" ' +
                    '} ' ;
                } else if(req.getEndpoint().indexOf('/if102/') > -1){
                    jsonData =  '{ ' +
                                '   "EV_EXIST": " ", ' +
                                '   "EV_BO_CHECK": " ", ' +
                                '   "EV_PJT_CHECK": " " ' +
                                '}'; 
                }
            }
            
            res.setHeader('Content-Type', 'application/json');
            res.setBody(jsonData);
            res.setStatus('OK');
            
            if(status == 200){
            	res.setStatusCode(200);
            } else if (status == 400){
            	res.setStatusCode(400);                
            }
	
            return res;
        }
    }
    /*
    @isTest static void test_method_ZP32_1() {
        Test.startTest();
        System.debug('test_method_ZP32_1');
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());

        // Activity status == 'In Progress'
        KnoxApprovalValidation.validationCheck(zp32_opptyAct_1.Id, null);

		Test.stopTest();
    }

    @isTest static void test_method_ZP32_2() {
        Test.startTest();
        System.debug('test_method_ZP32_2');
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        
        // Activity status != 'In Progress'
        // IF-056 - EV_CONTAPRO_OK == 'S'
        KnoxApprovalValidation.validationCheck(zp32_opptyAct_2.Id, null);

		Test.stopTest();
    }

    @isTest static void test_method_ZP32_3() {
        Test.startTest();
        System.debug('test_method_ZP32_3');
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        
        // Activity status != 'In Progress'
        // IF-056 - EV_CONTAPRO_OK == 'S'
        KnoxApprovalValidation.validationCheck(zp32_opptyAct_3.Id, null);

		Test.stopTest();
    }

    @isTest static void test_method_ZP32_4() {
        Test.startTest();
        System.debug('test_method_ZP32_4');
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        
        // Activity status != 'In Progress'
        // IF-056 - EV_CONTAPRO_OK == 'S'
        KnoxApprovalValidation.validationCheck(zp32_opptyAct_4.Id, null);

		Test.stopTest();
    }

    
    @isTest static void test_method_ZP62_1() {
        Test.startTest();
        System.debug('test_method_ZP62_1');
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());

        // biz_review.Costplanningreadiness__c = 'Yes'
        KnoxApprovalValidation.validationCheck(zp62_opptyAct_1.Id, bizReview_cost_y.Id);

		Test.stopTest();
    }

    @isTest static void test_method_ZP62_1_2() {
        Test.startTest();
        System.debug('test_method_ZP62_1_2');
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        
        // biz_review.Costplanningreadiness__c = 'No'
        KnoxApprovalValidation.validationCheck(zp62_opptyAct_1.Id, bizReview_cost_n.Id);

		Test.stopTest();
    }
    
    @isTest static void test_method_ZP62_1_3() {
        Test.startTest();
        System.debug('test_method_ZP62_1_3');
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());

        // biz_review.Costplanningreadiness__c = 'Yes'
        KnoxApprovalValidation.validationCheck(zp62_opptyAct_1.Id, bizReview_cost_a.Id);

		Test.stopTest();
    }

    @isTest static void test_method_ZP62_1_4() {
        Test.startTest();
        System.debug('test_method_ZP62_1_4');
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());

        // biz_review.Costplanningreadiness__c = 'Yes'
        KnoxApprovalValidation.validationCheck(zp62_opptyAct_1.Id, bizReview_cost_b.Id);

		Test.stopTest();
    }

    @isTest static void test_method_ZP62_3_1() {
        Test.startTest();
        System.debug('test_method_ZP62_3_1');
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        KnoxApprovalValidation.validationCheck(zp62_opptyAct_3.Id, null);

		Test.stopTest();
    }

    @isTest static void test_method_ZP82_1() {
        Test.startTest();
        System.debug('test_method_ZP82_1');

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        
        // Opportunity Deal Break == 'X'
        KnoxApprovalValidation.validationCheck(zp82_opptyAct_1.Id, null);

		Test.stopTest();
    }

    @isTest static void test_method_ZP82_2() {
        Test.startTest();
        System.debug('test_method_ZP82_2');

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        
        // Opportunity Deal Break != 'X'
        KnoxApprovalValidation.validationCheck(zp82_opptyAct_2.Id, null);

            // IF-067 - EV_RETURN == 'Y'

            // IF-067 - EV_RETURN != 'Y'

            // IF-056 - EV_CONTAPRO_OK == 'S'

            // IF-056 - EV_CONTAPRO_OK != 'S'
                // IF-102 - EV_BO_CHECK != 'X'
                // IF-102 - EV_BO_CHECK == 'X' AND EV_PJT_CHECK != 'X'

		Test.stopTest();
    }

    @isTest static void test_method_ZP82_3() {
        Test.startTest();
        System.debug('test_method_ZP82_3');

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        
        // Opportunity Deal Break == 'X'
        KnoxApprovalValidation.validationCheck(zp82_opptyAct_3.Id, null);

		Test.stopTest();
    }

    @isTest static void test_method_ZP82_4() {
        Test.startTest();
        System.debug('test_method_ZP82_4');

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        try{
            // Opportunity Deal Break == 'X'
            KnoxApprovalValidation.validationCheck(zp82_opptyAct_4.Id, null);
        } catch(Exception e){}
        

		Test.stopTest();
    }
    
    @isTest static void test_method_ZPZ1() {
        Test.startTest();
        System.debug('test_method_ZPZ1');

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        try{
            
            // Opportunity LostReasonLogistics__c 입력
            KnoxApprovalValidation.validationCheck(zpz1_opptyAct_1.Id, null);
    
            // Opportunity LostReasonLogistics__c 미입력
            KnoxApprovalValidation.validationCheck(zpz1_opptyAct_2.Id, null);
        } catch(Exception e){}

		Test.stopTest();
    }
    
    @isTest static void test_method_ZPZ2() {
        Test.startTest();
        System.debug('test_method_ZPZ2');

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        try{
            
            // Opportunity Business == 'TI'
            KnoxApprovalValidation.validationCheck(zpz2_opptyAct_1.Id, null);
    
            // Opportunity Business == 'TD'
            KnoxApprovalValidation.validationCheck(zpz2_opptyAct_2.Id, null);
    
            // Opportunity Business == 'TS'
            KnoxApprovalValidation.validationCheck(zpz2_opptyAct_3.Id, null);
    
            // Opportunity Business == ''
            KnoxApprovalValidation.validationCheck(zpz2_opptyAct_4.Id, null);
        } catch(Exception e){}


		Test.stopTest();
    }
    
    @isTest static void test_method_ZPZ3() {
        Test.startTest();
        System.debug('test_method_ZPZ3');

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());

        try{
            // IF-055 - EV_STATUS != 1
            KnoxApprovalValidation.validationCheck(zpz3_opptyAct_1.Id, null);
    
            // IF-055 - EV_STATUS == 1
        } catch(Exception e){}

		Test.stopTest();
    }
    
    @isTest static void test_method_ZPG1() {
        Test.startTest();
        System.debug('test_method_ZPG1');

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        try{
        	KnoxApprovalValidation.validationCheck(zpg1_opptyAct_1.Id, null);
        } catch(Exception e){}

		Test.stopTest();
	}
*/

}