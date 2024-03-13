@isTest
public class Batch_MigrationForTA_Test {
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

        // [S] Master Service Insert
        Master_Service__c master_service = new Master_Service__c(
            Name        = 'AI',
            Code__c     = '22000003'
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
            Service__c = master_service.Id,
            SendSAP__c = True
        );

        insert service;
        // [E] Service Insert

        // [S] Solution Insert
        Solution__c solution = new Solution__c(
            Opportunity__c          = oppty.Id,
            Service__c              = service.Id,
            Solution__c             = master_solution.Id,
            sSolution__c            = master_solution.Id
        );
        insert solution;
        // [E] Solution Insert
        
        // [S] WBS Insert
        WBS__c wbs = new WBS__c(
            OpportunityID__c = oppty.Id,
            Solution__c = solution.Id,
            Name = '12345678912345678',
            ItemNumber__c = '10',
            ServiceCode__c = '22000003'
        );
        insert wbs;
        // [E] WBS Insert
    }
    
    @isTest
    static void testBatch() {
        Test.startTest();
        Database.executeBatch(new Batch_MigrationForTA(), 100);
        Test.stopTest();
    }
}