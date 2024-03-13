/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-08-10
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-12-18   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class Batch_LsDashboardController_Test {

    @TestSetup
    static void makeData(){
        Master_Service__c master_service;
        Master_Solution__c master_solution;
        BizAttribute__c master_attribute;
        SvcSolBizAttr__c svcSolBizAttr;

        Company__c compnay;
        Account account;
        User user;
        Employee__c emp;

        Opportunity oppty;

        Service__c service;
        Solution__c solution;
        Project__c project;
        WBS__c wbs;
        
        CostCenter__c costCenter = new CostCenter__c(
            Name                = '기술전략팀(T100-11331)'
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T100'
            , CostCenterName__c = '기술전략팀'
            , CostCenter__c     = 'T100-44444'
            , Node1__c          = 'T100'
            , Node2__c          = 'T100SB'
            , Node3__c          = 'T100SB1'
            , Node4__c          = 'T100SB13'
            , Node5__c          = 'T100SB131'            
        );
        insert costCenter;

        compnay = new Company__c (
            Name                = 'T100 - Name'
            , CompanyCode__c    = 'T100'
            , EPCompanyCode__c  = 'EP1'
            , CurrencyIsoCode   = 'KRW'
            , Country__c        = 'Korea, Republic of'
        );
        insert compnay;

        account = new Account(
            Name = 'Test Account',
            AccountNumber = '123123',
            MDGCheck__c = true
        );
        insert account;

        Profile p = [SELECT id FROM Profile WHERE name = 'System Administrator' OR name = '시스템 관리자'];
        user = new User(
            Alias = 'standt1', Email='user0001@ss-sds.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='ko_KR', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
            UserName='user0001@ss-sds.com', Division = 'TW',
            EmployeeNumber = '123455'
        );
        insert user;

        emp = new Employee__c(
            Name = 'Test Emp',
            EvMailAddr__c = 'logiUser' + '@samsung.com',
            EvUniqID__c = 'epId2',            
            EvEmpNO__c = '123454'
        );
        insert emp;

        Date today = System.today();
        Date revenueStartDate = today.addDays(1);
        Date revenueEndDate = today.addDays(10);
        oppty = new Opportunity(
            Name = 'Test Oppty',
            CloseDate = System.today(),
            StageName = 'Z01',
            SalesDepartment__c = costCenter.Id,
            cPrimarySalesDepartment__c = costCenter.Id,
            OpportunityCode__c = 'SDS-20191510',
            cOriginAcc__c = account.Id,
            ProposalPM__c = emp.Id,
            BusinessLevel__c = 'C',
            cRevenueStartDate__c = revenueStartDate,
            cRevenueEndDate__c = revenueEndDate,
            BiddingMethod__c = 'BID001',
            Amount = 11000
        );
        insert oppty;

        master_service = new Master_Service__c(
            Name = 'Test Master Service',
            Code__c = '20000026'
        );
        insert master_service;

        List<Master_Solution__c> masterSolList = new List<Master_Solution__c>();
        master_solution = new Master_Solution__c(
            Name = 'Test Master Solution',
            Code__c = '30000135',
            SolutionType__c = '10'
        );
        masterSolList.add(master_solution);

        Master_Solution__c master_solution2 = new Master_Solution__c(
            Name = 'Test Master Solution',
            Code__c = '30000136',
            SolutionType__c = '20'
        );
        masterSolList.add(master_solution2);
        insert masterSolList;

        master_attribute = new BizAttribute__c(
            Name = 'Test Master Attribute',
            Code__c = 'S124'
        );
        insert master_attribute;

        List<SvcSolBizAttr__c> lsvcsolbizList = new List<SvcSolBizAttr__c>();
        svcSolBizAttr =  new SvcSolBizAttr__c(
            BizAttribute__c = master_attribute.Id,
            BusinessType__c = 'TI',
            Solution__c = master_solution.Id,
            WBSClass__c = 'SC',
            PSType__c = 'SC1',
            Use__c = true
        );
        lsvcsolbizList.add(svcSolBizAttr);
        insert lsvcsolbizList;

        project = new Project__c(
            Opportunity__c =  oppty.Id,
            Name = oppty.Name,
            Description__c = '',
            ProjectCode__c = 'SCC21765381D000'
            );
        insert project;
            
        List<WBS__c> wbsList = new List<WBS__c>();
        wbs = new WBS__c(
            Name = 'SCC21765381D001',
            OpportunityID__c = oppty.Id,
            Project__c = project.Id,
        	ServiceCode__c = master_service.Code__c,
        	ProjectCode__c = 'SCC21765381D000',
        	SolutionCode__c = master_solution.Code__c,
            BizAttribCode__c = master_attribute.Code__c,
            DeletionFlag__c = 'N',
            ItemNumber__c = '10'
        );
        // insert wbs;
        wbsList.add(wbs);

        WBS__c wbs2 = new WBS__c(
            Name = 'SCC21765381D00111',
            OpportunityID__c = oppty.Id,
            Project__c = project.Id,
        	ServiceCode__c = master_service.Code__c,
        	ProjectCode__c = 'SCC21765381D000',
        	SolutionCode__c = '',
            BizAttribCode__c = master_attribute.Code__c,
            DeletionFlag__c = 'N',
            ItemNumber__c = '10'
        );
        wbsList.add(wbs2);

        WBS__c wbs3 = new WBS__c(
            Name = 'SCC21765381D00121',
            OpportunityID__c = oppty.Id,
            Project__c = project.Id,
        	ServiceCode__c = master_service.Code__c,
        	ProjectCode__c = 'SCC21765381D000',
        	SolutionCode__c = master_solution.Code__c,
            BizAttribCode__c = master_attribute.Code__c,
            DeletionFlag__c = 'N',
            ItemNumber__c = '10'
        );
        wbsList.add(wbs3);

        WBS__c wbs4 = new WBS__c(
            Name = 'SCC21765381D00131',
            OpportunityID__c = oppty.Id,
            Project__c = project.Id,
        	ServiceCode__c = master_service.Code__c,
        	ProjectCode__c = 'SCC21765381D000',
        	SolutionCode__c = master_solution.Code__c,
            BizAttribCode__c = master_attribute.Code__c,
            DeletionFlag__c = 'N',
            ItemNumber__c = '10'
        );
        wbsList.add(wbs4);

        WBS__c wbs5 = new WBS__c(
            Name = 'SMC21765381D00121',
            OpportunityID__c = oppty.Id,
            Project__c = project.Id,
        	ServiceCode__c = master_service.Code__c,
        	ProjectCode__c = 'SMC21765381D000',
        	SolutionCode__c = master_solution.Code__c,
            BizAttribCode__c = master_attribute.Code__c,
            DeletionFlag__c = 'N',
            ItemNumber__c = '10'
        );
        wbsList.add(wbs5);

        insert wbsList;

        service = new Service__c(
            Opportunity__c = oppty.Id,
            sService__c = master_service.Id,
            sDeliveryDepartment__c = costCenter.Id,
            sSalesDepartment__c  = costCenter.Id,
            ItemNumber__c = 10,
            Changed__c = true,
            sDeletionFlag__c = false
        );
        insert service;

        List<Solution__c> solList = new List<Solution__c>();
        solution = new Solution__c(
            Opportunity__c = oppty.Id,
            Service__c = service.Id,
            sBizAttribute__c = master_attribute.Id,
            sSolution__c = master_solution.Id,
            sPSType__c = svcSolBizAttr.PsType__c,
            sWBSClass__c = svcSolBizAttr.WBSClass__c,
            sBusinessType__c = svcSolBizAttr.BusinessType__c,
            BizAttribute__c = master_attribute.Id,
            Solution__c = master_solution.Id,
            PSType__c = svcSolBizAttr.PsType__c,
            WBSClass__c = svcSolBizAttr.WBSClass__c,
            BusinessType__c = svcSolBizAttr.BusinessType__c,
            Changed__c = true,
            sDeletionFlag__c = false
            );
        solList.add(solution);

        Solution__c solution2 = new Solution__c(
            Opportunity__c = oppty.Id,
            Service__c = service.Id,
            sBizAttribute__c = master_attribute.Id,
            sSolution__c = master_solution2.Id,
            sPSType__c = svcSolBizAttr.PsType__c,
            sWBSClass__c = svcSolBizAttr.WBSClass__c,
            sBusinessType__c = svcSolBizAttr.BusinessType__c,
            BizAttribute__c = master_attribute.Id,
            Solution__c = master_solution2.Id,
            PSType__c = svcSolBizAttr.PsType__c,
            WBSClass__c = svcSolBizAttr.WBSClass__c,
            BusinessType__c = svcSolBizAttr.BusinessType__c,
            Changed__c = true,
            sDeletionFlag__c = false
            );
        solList.add(solution2);
        insert solList;
    }

    @isTest
    static void testBatch1() {
        Test.startTest();
        Opportunity oppty = [SELECT Id, Name FROM Opportunity LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        Id batchJobId = Database.executeBatch(new Batch_LsDashboardController(new Set<Id>{oppty.Id}), 2000);

        Test.stopTest();
    }

    @isTest
    static void testBatch2() {
        Test.startTest();
        Opportunity oppty = [SELECT Id, Name FROM Opportunity LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(202));
        Id batchJobId = Database.executeBatch(new Batch_LsDashboardController(new Set<Id>{oppty.Id}), 2000);

        Test.stopTest();
    }

    @isTest
    static void testBatch3() {
        Test.startTest();
        Opportunity oppty = [SELECT Id, Name FROM Opportunity LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));
        Id batchJobId = Database.executeBatch(new Batch_LsDashboardController(new Set<Id>{oppty.Id}), 2000);

        Test.stopTest();
    }

    @isTest
    static void testSchedule() {
        Test.startTest();
        Opportunity oppty = [SELECT Id, Name FROM Opportunity LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(202));

        String sch = '0 0 23 * * ?';
        String jobId = System.schedule('Batch_LsDashboardController', sch, new Batch_LsDashboardController(new Set<Id>{oppty.Id}));
        List<CronTrigger> cronTrList = [ SELECT Id FROM CronTrigger WHERE Id = :jobId];
        System.assert(cronTrList.size() > 0);

        Test.stopTest();
    }
}