/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2023-12-12 
 * @last modified by  : vikrant.ks@samsung.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2021-07-20   seonju.jin@dkbmc.com   Initial Version
 * 1.1   2023-12-12   vikrant.ks@samsung.com Increase code coverage
**/
@isTest
public class WBSHelper_Test {
    static Master_Service__c master_service;
    static Master_Solution__c master_solution;
    static BizAttribute__c master_attribute;
    static CostCenter__c costCenter;
    static SvcSolBizAttr__c svcSolBizAttr;

    static Company__c compnay;
    static Account account;
    static User user;
    static Employee__c emp;

    static Opportunity oppty;

    static Service__c service;
    static Solution__c solution;
    static Project__c project;
    static WBS__c wbs;

    static{
    costCenter = new CostCenter__c(
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
        SvcSolBizAttr__c svcSolBizAttr =  new SvcSolBizAttr__c(
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
    public static void testMethod01(){
        Test.startTest();
        
        List<Opportunity> opptyList = [SELECT Id, Name, CompanyCode__c FROM Opportunity WHERE Id =:oppty.Id];
        List<Solution__c> solList = [SELECT Id, Name, sWBSClass__c, sBusinessType__c, BusinessType__c, sBizAttribute__r.Code__c,  Service__r.sService__r.Code__c
        , sSolution__r.Code__c, sSolutionType__c, ItemNumber__c , PSType__c , sPSType__c, SendSAP__c FROM Solution__c WHERE Opportunity__c = :oppty.Id];
        WBSHelper helper = WBSHelper.getInstance(opptyList.get(0).Id, opptyList.get(0).CompanyCode__c);

        for(Solution__c sol : solList){
            helper.getServicCode(sol);
            helper.checkDuplicateWBS(sol, sol.ItemNumber__c.intValue());
        }

        // helper.getGubun('30');

        Test.stopTest();
    }
    
    @isTest //V1.1 Start
    Public static void testMethod02(){
        List<String> stype= new List<String>{'10','20','30','40','50','60'};
        List<String> companyCode= new List<String>{'T100','T170','T631','T711','T140'};
        for(String a:stype){
            for(String b:companyCode){
                String s= WBSHelper.getGubun(a,b);
                System.debug(a+' '+b+' '+s);
            }
		}

    }
    //V1.1 End
}