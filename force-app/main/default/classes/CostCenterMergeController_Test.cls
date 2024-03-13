/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-07-29
 * @last modified by  : younghoon.kim@dkbmc.com
**/
@isTest
public class CostCenterMergeController_Test {
    @TestSetup
    static void setup(){
        // [S] Custom Setting
        TriggerSwitch__c ts = new TriggerSwitch__c(
            All__c                              = true,
            Event__c                            = true,
            Migration__c                        = true,
            Opportunity__c                      = true,
            OpportunityActivity__c              = true,
            OpportunityBizLvSetting__c          = true,
            OpportunityCodeSetting__c           = true,
            OpportunityDeleteSetting__c         = false,
            OpportunityLogisticsValidation__c   = false,
            OpportunitySendToSAP__c             = false,
            RevenueScheduleOpportunity__c       = false,
            WeeklyReportSend__c                 = false
        );
        insert ts;
        // [E] Custom Setting

        // [S] User Insert
        List<User> userList = new List<User>();
        
        Profile profile_Admin = [SELECT id FROM Profile WHERE name = 'System Administrator' OR name = '시스템 관리자'];
        User user_Admin = new User(
            Alias                   = 'Admin', 
            Email                   = 'admin@samsung.com', 
            EmailEncodingKey        = 'UTF-8', 
            LastName                = 'Admin', 
            LanguageLocaleKey       = 'en_US', 
            LocaleSidKey            = 'ko_KR', 
            ProfileId               = profile_Admin.Id, 
            TimeZoneSidKey          = 'Asia/Seoul', 
            UserName                = 'admin@samsung.com.test', 
            EmployeeNumber          = '111111', 
            FederationIdentifier    = 'admin111111'
        );
        userList.add(user_Admin);

        Profile profile_SalesRep = [SELECT Id FROM Profile WHERE Name = 'Sales Rep.(HQ)'];
        User user_salesRep1 = new User(
            Alias                   = 'sr1', 
            Email                   = 'sr1@samsung.com', 
            EmailEncodingKey        = 'UTF-8', 
            LastName                = 'sr1', 
            LanguageLocaleKey       = 'en_US', 
            LocaleSidKey            = 'ko_KR', 
            ProfileId               = profile_SalesRep.Id, 
            TimeZoneSidKey          = 'Asia/Seoul', 
            UserName                = 'sr1@samsung.com.test', 
            EmployeeNumber          = '222222', 
            FederationIdentifier    = 'sales222222'
        );
        userList.add(user_salesRep1);

        User user_salesRep2 = new User(
            Alias                   = 'sr2', 
            Email                   = 'sr2@samsung.com', 
            EmailEncodingKey        = 'UTF-8', 
            LastName                = 'sr2', 
            LanguageLocaleKey       = 'en_US', 
            LocaleSidKey            = 'ko_KR', 
            ProfileId               = profile_SalesRep.Id, 
            TimeZoneSidKey          = 'Asia/Seoul', 
            UserName                = 'sr2@samsung.com.test', 
            EmployeeNumber          = '222222', 
            FederationIdentifier    = 'sales222222'
        );
        userList.add(user_salesRep2);

        insert userList;
        // [E] User Insert

        // [S] Employee Insert
        Employee__c emp_Admin = new Employee__c(
            Name            = 'Admin',
            EvMailAddr__c   = 'admin@samsung.com',
            EvUniqID__c     = 'admin111111',            
            EvEmpNO__c      = '111111'
        );
        insert emp_Admin;
        // [E] Employee Insert

        // [S] Company Insert
        List<Company__c> compList = new List<Company__c>();

        Company__c comp_asis1 = new Company__c (
            Name              = 'SDSLA', 
            CompanyCode__c    = 'T801', 
            EPCompanyCode__c  = 'C6L', 
            Country__c        = 'BR'
        );
        compList.add(comp_asis1);

        Company__c comp_tobe1 = new Company__c (
            Name              = 'SDSLA_SL', 
            CompanyCode__c    = 'T815', 
            EPCompanyCode__c  = 'C6L', 
            Country__c        = 'BR'
        );
        compList.add(comp_tobe1);

        insert compList;
        // [E] Company Insert

        // [S] Cost Center Insert
        List<CostCenter__c> ccList = new List<CostCenter__c>();

        CostCenter__c costCenter_asis1 = new CostCenter__c(
            Name            = '[CLSD]Solution Deli', 
            CostCenter__c   = 'T801-10070',
            Company__c      =  comp_asis1.Id,
            CompanyCode__c  = 'T801'
        );
        ccList.add(costCenter_asis1);

        CostCenter__c costCenter_tobe1 = new CostCenter__c(
            Name            = 'Pricing Group',
            CostCenter__c   = 'T815-10040',
            Company__c      =  comp_tobe1.Id,
            CompanyCode__c  = 'T815'
        );
        ccList.add(costCenter_tobe1);

        CostCenter__c costCenter_tobe2 = new CostCenter__c(
            Name            = 'Support Team', 
            CostCenter__c   = 'T815-10041',
            Company__c      =  comp_tobe1.Id,
            CompanyCode__c  = 'T815'
        );
        ccList.add(costCenter_tobe2);

        insert ccList;
        // [E] Cost Center Insert
            
        // [S] Account Insert
        Account account = new Account(
            Name            = 'Test Account',
            AccountNumber   = '123123',
            MDGCheck__c     = true
        );
        insert account;
        // [E] Account Insert

        // [S] Opportunity Insert
        Date today = System.today();
        Date revenueStartDate = today.addDays(1);
        Date revenueEndDate = today.addDays(10);
        Opportunity oppty = new Opportunity(
            Name                        = 'Test Oppty',
            CloseDate                   = System.today(),
            StageName                   = 'Z01',
            SalesDepartment__c          = costCenter_asis1.Id,
            cPrimarySalesDepartment__c  = costCenter_asis1.Id,
            OpportunityCode__c          = 'SDS-20000010',
            cOriginAcc__c               = account.Id,
            ProposalPM__c               = emp_Admin.Id,
            BusinessLevel__c            = 'C',
            cRevenueStartDate__c        = revenueStartDate,
            cRevenueEndDate__c          = revenueEndDate,
            BiddingMethod__c            = 'BID001',
            Amount                      = 11000
        );
        insert oppty;
        // [E] Opportunity Insert

        // [S] Opportunity Team Member Insert
        List<OpportunityTeamMember> otmList = new List<OpportunityTeamMember>();

        OpportunityTeamMember opptyTeamMember1 = new OpportunityTeamMember(
            OpportunityId   = oppty.Id,
            UserId          = user_salesRep1.Id
        );
        otmList.add(opptyTeamMember1);

        OpportunityTeamMember opptyTeamMember2 = new OpportunityTeamMember(
            OpportunityId   = oppty.Id,
            UserId          = user_salesRep2.Id
        );
        otmList.add(opptyTeamMember2);

        insert otmList;
        // [E] Opportunity Team Member Insert

        // [S] Opportunity Activity Insert
        List<Opportunity_Activity__c> opptyActList = new List<Opportunity_Activity__c>();

        Opportunity_Activity__c opptyAct1 = new Opportunity_Activity__c(
            WhatId__c           = oppty.Id,
            TransactionName__c  = 'XP11',
            ExtID__c            = oppty.Id + '_XP11',
            MigData__c          = true,
            Status__c           = 'Completed',
            StartDate__c        = Date.today(),
            EndDate__c          = Date.today()
        );
        opptyActList.add(opptyAct1);

        Opportunity_Activity__c opptyAct2 = new Opportunity_Activity__c(
            WhatId__c           = oppty.Id,
            TransactionName__c  = 'ZP21',
            ExtID__c            = oppty.Id + '_ZP21',
            MigData__c          = true,
            Status__c           = 'Completed',
            StartDate__c        = Date.today(),
            EndDate__c          = Date.today()
        );
        opptyActList.add(opptyAct2);

        Opportunity_Activity__c opptyAct3 = new Opportunity_Activity__c(
            WhatId__c           = oppty.Id,
            TransactionName__c  = 'ZPG1',
            ExtID__c            = oppty.Id + '_ZPG1',
            MigData__c          = true,
            Status__c           = 'Completed',
            StartDate__c        = Date.today(),
            EndDate__c          = Date.today()
        );
        opptyActList.add(opptyAct3);

        insert opptyActList;
        // [E] Opportunity Activity Insert

        // [S] Knox Approval Insert
        List<KnoxApproval__c> knoxList = new List<KnoxApproval__c>();

        KnoxApproval__c knox1 = new KnoxApproval__c(
            Opportunity__c          = oppty.Id,
            OpportunityActivity__c  = opptyAct3.Id,
            BoCode__c               = 'SDS-20000010',
            CompanyCode__c          = 'T801'
        );
        knoxList.add(knox1);

        insert knoxList;
        // [E] Knox Approval Insert

        // [S] Master Service Insert
        Master_Service__c master_service = new Master_Service__c(
            Name        = 'AI',
            Code__c     = '22000006'
        );
        insert master_service;
        // [E] Master Service Insert

        // [S] Master Solution Insert
        Master_Solution__c master_solution = new Master_Solution__c(
            Name                = 'Test Master Solution',
            Code__c             = '32000069',
            SolutionType__c     = '30'
        );
        insert master_solution;
        // [E] Master Solution Insert

        // [S] Biz Attribute Insert
        BizAttribute__c bizAttr = new BizAttribute__c (
            Name        = 'Technical Support', 
            Active__c   = true, 
            Code__c     = 'S149'
        );
        insert bizAttr;
        // [E] Biz Attribute Insert

        // [S] Service Insert
        Service__c service = new Service__c(
            Opportunity__c          = oppty.Id,
            SalesDepartment__c      = costCenter_asis1.Id,
            sSalesDepartment__c     = costCenter_asis1.Id,
            DeliveryDepartment__c   = costCenter_asis1.Id,
            sDeliveryDepartment__c  = costCenter_asis1.Id,
            WBSCode__c              = 'SCC20000011H001'
        );

        insert service;
        // [E] Service Insert

        // [S] Solution Insert
        Solution__c solution = new Solution__c(
            Opportunity__c          = oppty.Id,
            Service__c              = service.Id,
            Solution__c             = master_solution.Id,
            sSolution__c            = master_solution.Id,
            BizAttribute__c         = bizAttr.Id,
            sBizAttribute__c        = bizAttr.Id,
            WBSCode__c              = 'SMC20000011H00132',
            ProjectCode__c          = 'SMC-20000011-H0'
        );
        insert solution;
        // [S] Solution Insert

        // [S] CostCenterMerge__c Insert
        List<CostCenterMerge__c> ccmList = new List<CostCenterMerge__c>();

        CostCenterMerge__c ccm1 = new CostCenterMerge__c(
            CompanyCode_AsIs__c         = 'T801',
            OpptyCode_AsIs__c           = 'SDS-20000010',
            Oppty_SalesDept_ToBe__c     = 'T815-10040',
            Oppty_DeliveryDept_ToBe__c  = 'T815-10041',
            Project__c                  = 'SMA-20000011-HB',
            ProjectCode__c              = 'SMA20000011HB00',
            ProjectDescription__c       = '# 202104_HQ_TEST - Project Desc',
            WBS__c                      = 'SMA-20000012-HB',
            WBSDescription__c           = '# 202104_HQ_TEST - WBS Desc 6',
            Svc_SalesDept_ToBe__c       = 'T815-10040',
            Svc_DeliveryDept_ToBe__c    = 'T815-10041',
            ItemNumber__c               = '0',
            Service__c                  = '22000006',
            Solution__c                 = '32000069',
            BizAttributeCode__c         = '',
            IsComplete__c               = false,
            Oppty_CodeFormat_ToBe__c    = 'L'
        );
        ccmList.add(ccm1);

        CostCenterMerge__c ccm2 = new CostCenterMerge__c(
            CompanyCode_AsIs__c         = 'T801',
            OpptyCode_AsIs__c           = 'SDS-20000010',
            Oppty_SalesDept_ToBe__c     = 'T815-10040',
            Oppty_DeliveryDept_ToBe__c  = 'T815-10041',
            Project__c                  = 'SMA-20000011-HB',
            ProjectCode__c              = 'SMA20000011HB00',
            ProjectDescription__c       = '# 202104_HQ_TEST - Project Desc',
            WBS__c                      = 'SMA-20000011-HB-01',
            WBSDescription__c           = '# 202104_HQ_TEST - WBS Desc 7',
            Svc_SalesDept_ToBe__c       = 'T815-10040',
            Svc_DeliveryDept_ToBe__c    = 'T815-10041',
            ItemNumber__c               = '10',
            Service__c                  = '22000006',
            Solution__c                 = '',
            BizAttributeCode__c         = 'S149',
            IsComplete__c               = false,
            Oppty_CodeFormat_ToBe__c    = 'L'
        );
        ccmList.add(ccm2);

        CostCenterMerge__c ccm3 = new CostCenterMerge__c(
            CompanyCode_AsIs__c         = 'T801',
            OpptyCode_AsIs__c           = 'SDS-20000010',
            Oppty_SalesDept_ToBe__c     = 'T815-10040',
            Oppty_DeliveryDept_ToBe__c  = 'T815-10041',
            Project__c                  = 'SMA-20000011-HB',
            ProjectCode__c              = 'SMA20000011HB00',
            ProjectDescription__c       = '# 202104_HQ_TEST - Project Desc',
            WBS__c                      = 'SMA-20000011-HB-01-11',
            WBSDescription__c           = '# 202104_HQ_TEST - WBS Desc 8',
            Svc_SalesDept_ToBe__c       = 'T815-10040',
            Svc_DeliveryDept_ToBe__c    = 'T815-10041',
            ItemNumber__c               = '10',
            Service__c                  = '22000006',
            Solution__c                 = '32000069',
            BizAttributeCode__c         = 'S149',
            IsComplete__c               = false,
            Oppty_CodeFormat_ToBe__c    = 'L'
        );
        ccmList.add(ccm3);

        CostCenterMerge__c ccm4 = new CostCenterMerge__c(
            CompanyCode_AsIs__c         = 'T801',
            OpptyCode_AsIs__c           = 'SDS-20000010',
            Oppty_SalesDept_ToBe__c     = 'T815-10040',
            Oppty_DeliveryDept_ToBe__c  = 'T815-10041',
            Project__c                  = 'SMA-20000011-HB',
            ProjectCode__c              = 'SMA20000011HB00',
            ProjectDescription__c       = '# 202104_HQ_TEST - Project Desc',
            WBS__c                      = 'SMA-20000011-HB-01-21',
            WBSDescription__c           = '# 202104_HQ_TEST - WBS Desc 9',
            Svc_SalesDept_ToBe__c       = 'T815-10040',
            Svc_DeliveryDept_ToBe__c    = 'T815-10041',
            ItemNumber__c               = '10',
            Service__c                  = '22000006',
            Solution__c                 = '32000069',
            BizAttributeCode__c         = 'S149',
            IsComplete__c               = false,
            Oppty_CodeFormat_ToBe__c    = 'L'
        );
        ccmList.add(ccm4);

        CostCenterMerge__c ccm5 = new CostCenterMerge__c(
            CompanyCode_AsIs__c         = 'T801',
            OpptyCode_AsIs__c           = 'SDS-20000010',
            Oppty_SalesDept_ToBe__c     = 'T815-10040',
            Oppty_DeliveryDept_ToBe__c  = 'T815-10041',
            Project__c                  = 'SMA-20000011-HB',
            ProjectCode__c              = 'SMA20000011HB00',
            ProjectDescription__c       = '# 202104_HQ_TEST - Project Desc',
            WBS__c                      = 'SMA-20000011-HB-01-31',
            WBSDescription__c           = '# 202104_HQ_TEST - WBS Desc 10',
            Svc_SalesDept_ToBe__c       = 'T815-10040',
            Svc_DeliveryDept_ToBe__c    = 'T815-10041',
            ItemNumber__c               = '10',
            Service__c                  = '22000006',
            Solution__c                 = '32000069',
            BizAttributeCode__c         = 'S149',
            IsComplete__c               = false,
            Oppty_CodeFormat_ToBe__c    = 'L'
        );
        ccmList.add(ccm5);

        CostCenterMerge__c ccm6 = new CostCenterMerge__c(
            CompanyCode_AsIs__c         = 'T801',
            OpptyCode_AsIs__c           = 'SDS-20000010',
            Oppty_SalesDept_ToBe__c     = 'T815-10040',
            Oppty_DeliveryDept_ToBe__c  = 'T815-10041',
            Project__c                  = 'SMC-20000011-HB',
            ProjectCode__c              = 'SMC20000011HB00',
            ProjectDescription__c       = '# 202104_HQ_TEST - Project Desc',
            WBS__c                      = 'SMC-20000011-HB',
            WBSDescription__c           = '# 202104_HQ_TEST - WBS Desc 1',
            Svc_SalesDept_ToBe__c       = 'T815-10040',
            Svc_DeliveryDept_ToBe__c    = 'T815-10041',
            ItemNumber__c               = '0',
            Service__c                  = '22000006',
            Solution__c                 = '32000069',
            BizAttributeCode__c         = 'S149',
            IsComplete__c               = false,
            Oppty_CodeFormat_ToBe__c    = 'L'
        );
        ccmList.add(ccm6);

        CostCenterMerge__c ccm7 = new CostCenterMerge__c(
            CompanyCode_AsIs__c         = 'T801',
            OpptyCode_AsIs__c           = 'SDS-20000010',
            Oppty_SalesDept_ToBe__c     = 'T815-10040',
            Oppty_DeliveryDept_ToBe__c  = 'T815-10041',
            Project__c                  = 'SMC-20000011-HB',
            ProjectCode__c              = 'SMC20000011HB00',
            ProjectDescription__c       = '# 202104_HQ_TEST - Project Desc',
            WBS__c                      = 'SMC-20000011-HB-01',
            WBSDescription__c           = '# 202104_HQ_TEST - WBS Desc 2',
            Svc_SalesDept_ToBe__c       = 'T815-10040',
            Svc_DeliveryDept_ToBe__c    = 'T815-10041',
            ItemNumber__c               = '10',
            Service__c                  = '22000006',
            Solution__c                 = '32000069',
            BizAttributeCode__c         = 'S149',
            IsComplete__c               = false,
            Oppty_CodeFormat_ToBe__c    = 'L'
        );
        ccmList.add(ccm7);

        CostCenterMerge__c ccm8 = new CostCenterMerge__c(
            CompanyCode_AsIs__c         = 'T801',
            OpptyCode_AsIs__c           = 'SDS-20000010',
            Oppty_SalesDept_ToBe__c     = 'T815-10040',
            Oppty_DeliveryDept_ToBe__c  = 'T815-10041',
            Project__c                  = 'SMC-20000011-HB',
            ProjectCode__c              = 'SMC20000011HB00',
            ProjectDescription__c       = '# 202104_HQ_TEST - Project Desc',
            WBS__c                      = 'SMC-20000011-HB-01-11',
            WBSDescription__c           = '# 202104_HQ_TEST - WBS Desc 3',
            Svc_SalesDept_ToBe__c       = 'T815-10040',
            Svc_DeliveryDept_ToBe__c    = 'T815-10041',
            ItemNumber__c               = '10',
            Service__c                  = '22000006',
            Solution__c                 = '32000069',
            BizAttributeCode__c         = 'S149',
            IsComplete__c               = false,
            Oppty_CodeFormat_ToBe__c    = 'L'
        );
        ccmList.add(ccm8);

        CostCenterMerge__c ccm9 = new CostCenterMerge__c(
            CompanyCode_AsIs__c         = 'T801',
            OpptyCode_AsIs__c           = 'SDS-20000010',
            Oppty_SalesDept_ToBe__c     = 'T815-10040',
            Oppty_DeliveryDept_ToBe__c  = 'T815-10041',
            Project__c                  = 'SMC-20000011-HB',
            ProjectCode__c              = 'SMC20000011HB00',
            ProjectDescription__c       = '# 202104_HQ_TEST - Project Desc',
            WBS__c                      = 'SMC-20000011-HB-01-21',
            WBSDescription__c           = '# 202104_HQ_TEST - WBS Desc 4',
            Svc_SalesDept_ToBe__c       = 'T815-10040',
            Svc_DeliveryDept_ToBe__c    = 'T815-10041',
            ItemNumber__c               = '10',
            Service__c                  = '22000006',
            Solution__c                 = '32000069',
            BizAttributeCode__c         = 'S149',
            IsComplete__c               = false,
            Oppty_CodeFormat_ToBe__c    = 'L'
        );
        ccmList.add(ccm9);

        CostCenterMerge__c ccm10 = new CostCenterMerge__c(
            CompanyCode_AsIs__c         = 'T801',
            OpptyCode_AsIs__c           = 'SDS-20000010',
            Oppty_SalesDept_ToBe__c     = 'T815-10040',
            Oppty_DeliveryDept_ToBe__c  = 'T815-10041',
            Project__c                  = 'SMC-20000011-HB',
            ProjectCode__c              = 'SMC20000011HB00',
            ProjectDescription__c       = '# 202104_HQ_TEST - Project Desc',
            WBS__c                      = 'SMC-20000011-HB-01-31',
            WBSDescription__c           = '# 202104_HQ_TEST - WBS Desc 5',
            Svc_SalesDept_ToBe__c       = 'T815-10040',
            Svc_DeliveryDept_ToBe__c    = 'T815-10041',
            ItemNumber__c               = '10',
            Service__c                  = '22000006',
            Solution__c                 = '32000069',
            BizAttributeCode__c         = 'S149',
            IsComplete__c               = false,
            Oppty_CodeFormat_ToBe__c    = 'L'
        );
        ccmList.add(ccm10);
        
        insert ccmList;
        // [E] CostCenterMerge__c Insert
    }

    @isTest
    static void testBatch() {
        Test.startTest();
        CostCenterMergeController.defaultCheck();
        CostCenterMergeController.batchStart();
        Test.stopTest();
    }
}