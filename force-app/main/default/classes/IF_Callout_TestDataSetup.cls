/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-04-27
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-12-29   ghkil@partner.samsung.com   Initial Version
**/
public class IF_Callout_TestDataSetup {

    public static void dataSetup() {
        RecordType RT_OPPTY_HQ;
        RecordType RT_OPPTY_LOGISTICS;
    
        RT_OPPTY_HQ        = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
        RT_OPPTY_LOGISTICS = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Logistics' Limit 1];

        // Account accAct = new Account(Name = 'accTest');

        // Insert accAct;
        
        List<Map<String, String>> MasterActTransactionPick = Utils.getPicklistOptionType('MasterActivity__c','TransactionName__c');
        List<Map<String, String>> OpptyActTransactionPick = Utils.getPicklistOptionType('Opportunity_Activity__c','TransactionName__c');

        // ****************************************        
        // MasterActivity__c 입력
        // ****************************************        
        MasterActivity__c mastrtAct = new MasterActivity__c(
            TransactionName__c          = MasterActTransactionPick[0].get('value')
            , Stage__c                  = 'Z01'
            , Order__c                  = 1
            , IsRequiredKnoxApproval__c = false
            , Position__c               = '1'
            , IsImportant__c            = true
            , IsRequired__c             = true
            , ObjectApiName__c          = 'Opportunity'
            , IsActive__c               = true
            , Type__c                   = 'HQ'
        );
        Insert mastrtAct;

        // ****************************************
        // Company__c 입력
        // ****************************************
        Company__c insertCompany = new Company__c (
            Name                = 'T100 - Name'
            , CompanyCode__c    = 'T100'
            , EPCompanyCode__c  = 'EP1'
            , CurrencyIsoCode   = 'KRW'
            , Country__c        = 'Korea, Republic of'
        );
        Insert insertCompany;

        Company__c insertCompany2 = new Company__c (
            Name                = 'T200 - Name'
            , CompanyCode__c    = 'T200'
            , EPCompanyCode__c  = 'EP1'
            , CurrencyIsoCode   = 'USD'
            , Country__c        = 'United States'
        );
        Insert insertCompany2;        

        // ****************************************
        // CostCenter__c 입력
        // ****************************************
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
            , Company__c        = insertCompany.Id
        );
        Insert insertCostCenter;

        CostCenter__c insertCostCenter2 = new CostCenter__c(
            Name                = '기술전략팀2(T100-11332)'
            , CurrencyIsoCode   = 'USD'
            , CompanyCode__c    = 'T200'
            , CostCenterName__c = '기술전략팀2'
            , CostCenter__c     = 'T100-11332'
            , Node1__c          = 'T200'
            , Node2__c          = 'T200SB'
            , Node3__c          = 'T200SB1'
            , Node4__c          = 'T200SB13'
            , Node5__c          = 'T200SB131'
            , Company__c        = insertCompany2.Id
        );
        Insert insertCostCenter2;

        // ****************************************
        // Organization__c 입력
        // ****************************************
        Organization__c insertOrganization1 = new Organization__c(
            Name = 'Logical Organization'
            , Region__c = 'H'
            , Company__c = insertCompany.Id
        );
        Insert insertOrganization1;

        // ****************************************
        // Master_Service__c 입력
        // ****************************************        
        Master_Service__c insertMasterService1 = new Master_Service__c(
            Name = 'Consulting'
            // , Business__c = ''
            , ServiceDepartmentCode__c  = 'T100-11331'
            , ServiceDepartment__c      = '기술전략팀'
            , ValidityStartDate__c      = system.today()
            , ValidityEndDate__c        = system.today()
            , Code__c                   = '20000026'
            , Use__c                    = true
        );
        Insert insertMasterService1;

        // ****************************************
        // Master_Solution__c 입력
        // ****************************************        
        Master_Solution__c insertMasterSolution1 = new Master_Solution__c(
            Name                = 'Telephony Traffic Wholesale'
            , Code__c           = '30000090'
            , Service__c        = insertMasterService1.Id
            // , SolutionManageName__c = false
            , SolutionType__c   = '30'
            , Use__c            = true
        );
        Insert insertMasterSolution1;

        Master_Solution__c insertMasterSolution2 = new Master_Solution__c(
            Name                = 'Telephony Traffic Wholesale2'
            , Code__c           = '30000092'
            , Service__c        = insertMasterService1.Id
            // , SolutionManageName__c = false
            , SolutionType__c   = '40'
            , Use__c            = true
        );
        Insert insertMasterSolution2;

        // ****************************************
        // Department__c 입력
        // ****************************************        
        Department__c insertDepartment = new Department__c(
            Name                = '기술기획팀'
            , CurrencyIsoCode   = 'KRW'
            , Abtel__c          = 'C60AI562'
            , Bkzer__c          = 'X'
            , Bukrs__c          = 'T100'
            , Datab__c          = System.today()
            , DatabI__c         = Date.valueOf('4000-12-31')
            , EKText__c         = '기술기획팀'
            , Kostl__c          = 'T100-11331'
        );
        Insert insertDepartment;

        // ****************************************
        // User 입력
        // ****************************************        
        user admin = [Select Id from User Where ( Profile.Name = 'System Administrator' OR Profile.Name = '시스템 관리자') AND isActive = true Limit 1];
		system.runAs (admin) {
			Profile adminP = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];

            Profile readP = [SELECT Id FROM Profile WHERE Name = 'Read Only' OR Name = '읽기 전용'];

            User insertUser = new User(
                Alias               = 'standt1'
                , Email             = 'hong99991@samsung.com'
                , EmailEncodingKey  = 'UTF-8'
                , LanguageLocaleKey = 'en_US'
                , LocaleSidKey      = 'en_US'
                , TimeZoneSidKey    = 'Asia/Seoul'
                , UserName          = 'hong99991@samsung.com'
                , LastName          = '홍'
                , FirstName         = '길동'
                , EmployeeNumber    = '16421'
                , ProfileId         = adminP.Id
            );
            Insert insertUser;

            User insertUser2 = new User(
                Alias               = 'standt2'
                , Email             = 'hong99992@samsung.com'
                , EmailEncodingKey  = 'UTF-8'
                , LanguageLocaleKey = 'en_US'
                , LocaleSidKey      = 'en_US'
                , TimeZoneSidKey    = 'Asia/Seoul'
                , UserName          = 'hong99992@samsung.com'
                , LastName          = '홍'
                , FirstName         = '길동99'
                , EmployeeNumber    = '16499'
                , ProfileId         = readP.Id
            );
            Insert insertUser2;            
        }

        // ****************************************
        // Opportunity 입력
        // ****************************************
        Opportunity hqOppty = new Opportunity(
            Name                    = 'testOpp1'
            , RecordTypeId          = RT_OPPTY_HQ.Id
            , CloseDate             = System.today()
            , StageName             = 'Z01'
            , SalesDepartment__c    = insertCostCenter.Id
            , Amount                = 1000000
            , CurrencyIsoCode       = 'KRW'
            , OpportunityCode__c    = 'SDS-20000200'
            , cRevenueStartDate__c  = System.today()
            , cRevenueEndDate__c    = System.today().addDays(90)
        );
        Insert hqOppty;

        Opportunity hqOppty2 = new Opportunity(
            Name                    = 'testOpp2'
            , RecordTypeId          = RT_OPPTY_HQ.Id
            , CloseDate             = System.today()
            , StageName             = 'Z01'
            , SalesDepartment__c    = insertCostCenter2.Id
            , Amount                = 1000000
            , CurrencyIsoCode       = 'KRW'
            , OpportunityCode__c    = 'SDS-20000201'
            , cRevenueStartDate__c  = System.today()
            , cRevenueEndDate__c    = System.today().addDays(90)
        );
        Insert hqOppty2;

        Opportunity operOne = new Opportunity(
            Name                    = 'testOpp3'
            , RecordTypeId          = RT_OPPTY_HQ.Id
            , CloseDate             = System.today()
            , StageName             = 'Z01'
            , SalesDepartment__c    = insertCostCenter.Id
            , Amount                = 10000
            , CurrencyIsoCode       = 'USD'
            , cRevenueStartDate__c  = System.today()
            , cRevenueEndDate__c    = System.today().addDays(90)            
        );
        Insert operOne;

        Opportunity insertLogisticsOpportunity1 = new Opportunity(
            Name                    = 'logisticsTestOpp1'
            , RecordTypeId          = RT_OPPTY_LOGISTICS.Id
            , CloseDate             = System.today()
            , StageName             = 'Z01'
            , SalesDepartment__c    = insertCostCenter.Id
            , SalesOrganization__c  = insertOrganization1.Id
            , Amount                = 1000000
            , CurrencyIsoCode       = 'KRW'
            , cRevenueStartDate__c  = System.today()
            , cRevenueEndDate__c    = System.today().addDays(90)            
        );
        Insert insertLogisticsOpportunity1;

        Opportunity insertLogisticsOpportunity2 = new Opportunity(
            Name                    = 'logisticsTestOpp2'
            , RecordTypeId          = RT_OPPTY_LOGISTICS.Id
            , CloseDate             = System.today()
            , StageName             = 'Z01'
            , SalesDepartment__c    = insertCostCenter.Id
            , SalesOrganization__c  = insertOrganization1.Id
            , Amount                = 10000
            , CurrencyIsoCode       = 'USD'          
            , cRevenueStartDate__c  = System.today()
            , cRevenueEndDate__c    = System.today().addDays(90)  
        );
        Insert insertLogisticsOpportunity2;

        // ****************************************
        // Opportunity_Activity__c 입력
        // ****************************************
        Opportunity_Activity__c operAct = new Opportunity_Activity__c( 
            Status__c               = 'Not Started'
            , DueDate__c            = System.today()
            , TransactionName__c    = OpptyActTransactionPick[0].get('value')
            , WhatId__c             = hqOppty.Id
            , ExtID__c              = hqOppty.Id + '_' + OpptyActTransactionPick[0].get('value')
        );
        Insert operAct;

        Opportunity_Activity__c operAct2 = new Opportunity_Activity__c( 
            Status__c               = 'Not Started'
            , DueDate__c            = System.today()
            , TransactionName__c    = OpptyActTransactionPick[0].get('value')
            , WhatId__c             = hqOppty2.Id
            , ExtID__c              = hqOppty2.Id + '_' + OpptyActTransactionPick[0].get('value')
        );
        Insert operAct2;

        // ****************************************
        // Service__c 입력
        // ****************************************
        Service__c insertService = new Service__c(
            Opportunity__c          = hqOppty.Id
            // , Name                  = 'testService1'
            , ItemNumber__c         = 1
            , Service__c            = insertMasterService1.Id
            //, Solution__c           = insertMasterSolution1.Id
            , SalesDepartment__c    = insertCostCenter.Id
            , DeliveryDepartment__c = insertCostCenter.Id
            , DeletionFlag__c       = false
            , SendSAP__c            = true            
        );
        Insert insertService;

        Service__c insertService2 = new Service__c(
            Opportunity__c          = hqOppty.Id
            // , Name                  = 'testService2'
            , ItemNumber__c         = 1
            , Service__c            = insertMasterService1.Id
            //, Solution__c           = insertMasterSolution2.Id
            , SalesDepartment__c    = insertCostCenter.Id
            , DeliveryDepartment__c = insertCostCenter.Id
            , DeletionFlag__c       = false
            , SendSAP__c            = true                        
        );
        Insert insertService2;

        Service__c insertService3 = new Service__c(
            Opportunity__c          = hqOppty2.Id
            // , Name                  = 'testService2'
            , ItemNumber__c         = 1
            , Service__c            = insertMasterService1.Id
           // , Solution__c           = insertMasterSolution2.Id
            , SalesDepartment__c    = insertCostCenter.Id
            , DeliveryDepartment__c = insertCostCenter.Id
            , DeletionFlag__c       = false
            , SendSAP__c            = true            
        );
        Insert insertService3;

        Service__c insertService4 = new Service__c(
            Opportunity__c          = insertLogisticsOpportunity1.Id
            // , Name                  = 'testService2'
            , ItemNumber__c         = 1
            , Service__c            = insertMasterService1.Id
           // , Solution__c           = insertMasterSolution2.Id
            , SalesDepartment__c    = insertCostCenter.Id
            , DeliveryDepartment__c = insertCostCenter.Id
            , DeletionFlag__c       = false
            , SendSAP__c            = true            
        );
        Insert insertService4;

        Service__c insertService5 = new Service__c(
            Opportunity__c          = insertLogisticsOpportunity2.Id
            // , Name                  = 'testService2'
            , ItemNumber__c         = 1
            , Service__c            = insertMasterService1.Id
           // , Solution__c           = insertMasterSolution2.Id
            , SalesDepartment__c    = insertCostCenter.Id
            , DeliveryDepartment__c = insertCostCenter.Id
            , DeletionFlag__c       = false
            , SendSAP__c            = true            
        );
        Insert insertService5;        

        // ****************************************
        // Solution__c 입력
        // ****************************************        
        Solution__c insertSolution1 = new Solution__c(
            // Name                    = 'testSolution1'
            Service__c              = insertService.Id
            , CurrencyIsoCode       = 'KRW'
            , Amount__c             = null
            , Solution__c           = insertMasterSolution1.Id
            // , Opportunity__c        = hqOppty.Id
            , ProjectCode__c        = 'SMA-20201121-A0'
            , DeletionFlag__c       = false
            , SendSAP__c            = true            
        );
        Insert insertSolution1;

        Solution__c insertSolution2 = new Solution__c(
            // Name                    = 'testSolution2'
            Service__c              = insertService2.Id
            , CurrencyIsoCode       = 'KRW'
            , Amount__c             = null
            , Solution__c           = insertMasterSolution2.Id
            // , Opportunity__c        = hqOppty.Id
            , DeletionFlag__c       = false
            , SendSAP__c            = true            
        );
        Insert insertSolution2;

        Solution__c insertSolution3 = new Solution__c(
            // Name                    = 'testSolution2'
            Service__c              = insertService3.Id
            , CurrencyIsoCode       = 'KRW'
            , Amount__c             = null
            , Solution__c           = insertMasterSolution2.Id
            // , Opportunity__c        = hqOppty.Id
            , DeletionFlag__c       = false
            , SendSAP__c            = true            
        );
        Insert insertSolution3;

        Solution__c insertSolution4 = new Solution__c(
            // Name                    = 'testSolution2'
            Service__c              = insertService4.Id
            , CurrencyIsoCode       = 'KRW'
            , Amount__c             = null
            , Solution__c           = insertMasterSolution2.Id
            // , Opportunity__c        = hqOppty.Id
            , DeletionFlag__c       = false
            , SendSAP__c            = true            
        );
        Insert insertSolution4;

        Solution__c insertSolution5 = new Solution__c(
            // Name                    = 'testSolution2'
            Service__c              = insertService5.Id
            , CurrencyIsoCode       = 'KRW'
            , Amount__c             = null
            , Solution__c           = insertMasterSolution2.Id
            // , Opportunity__c        = hqOppty.Id
            , DeletionFlag__c       = false
            , SendSAP__c            = true            
        );
        Insert insertSolution5;

        // ****************************************
        // WBS__c 입력
        // ****************************************        
        WBS__c insertWbs = new WBS__c(
            Name                = 'testWbs1'
            , CurrencyIsoCode   = 'KRW'
            , OpportunityID__c  = hqOppty.Id
            , ItemNumber__c     = '0000000010'
            , SolutionOwner__c  = 'T100-11331'
        );
        Insert insertWbs;

        // ****************************************
        // Project__c 입력
        // ****************************************        
        Project__c insertProject = new Project__c(
            Name                = 'testProejct1'
            , Description__c    = 'testProejct1~~~~'
            , Opportunity__c    = hqOppty.Id
            , ProjectCode__c    = 'SMA-20201121-A0'
        );
        Insert insertProject;

        Project__c insertProject2 = new Project__c(
            Name                = 'testProejct2'
            , Description__c    = 'testProejct2~~~~'
            , Opportunity__c    = hqOppty.Id
            , ProjectCode__c    = 'SIA-20905161-A0'
        );
        Insert insertProject2;

        // ****************************************
        // BizAttribute__c 입력
        // ****************************************        
        BizAttribute__c insertBizAttribute = new BizAttribute__c (
            Name    = 'BizAttribute Name'
            , Code__c = 'C999'
            , Description__c = 'BizAttribute Description'
        );
        Insert insertBizAttribute;

        WeeklyReport__c insertWeeklyReport = new WeeklyReport__c(
            Name                    = 'testReporting'       // Reporting Name
            , Opportunity__c        = hqOppty.Id            // Opportunity
            , CheckedforIssue__c    = false                 // Checked for Issue
            , Contents__c           = '주간보고내용~~~~'     // Contents
            , Flag__c               = 'I'                   // Flag
            , IssueDescription__c   = '보고서 추가 설명'     // Issue Description
            , ReportingDate__c      = System.today()        // Reporting Date
            , Critical__c           = true                  // 중요 보고 여부
            // , SalesLead__c          = 
        );
        Insert insertWeeklyReport;

        RevenueScheduleOpportunity__c insertRevenueOpportunity1 = new RevenueScheduleOpportunity__c(
            Parent__c = insertLogisticsOpportunity1.Id
            , Revenue__c = 500000000
            , ScheduleDate__c = Date.today()
            , CurrencyIsoCode = 'KRW'
        );
        Insert insertRevenueOpportunity1;

        // system.debug('mastrtAct : ' + mastrtAct);
        // system.debug('insertCompany : ' + insertCompany);
        // system.debug('insertCostCenter : ' + insertCostCenter);
        // system.debug('insertOrganization1 : ' + insertOrganization1);
        // system.debug('insertMasterService1 : ' + insertMasterService1);
        // system.debug('insertMasterSolution1 : ' + insertMasterSolution1);
        // system.debug('insertMasterSolution2 : ' + insertMasterSolution2);
        // system.debug('insertDepartment : ' + insertDepartment);
        // system.debug('hqOppty : ' + hqOppty);
        // system.debug('operAct : ' + operAct);
        // system.debug('operOne : ' + operOne);
        // system.debug('insertLogisticsOpportunity1 : ' + insertLogisticsOpportunity1);
        // system.debug('insertService : ' + insertService);
        // system.debug('insertService2 : ' + insertService2);
        // system.debug('insertSolution1 : ' + insertSolution1);
        // system.debug('insertSolution2 : ' + insertSolution2);
        // system.debug('insertWbs : ' + insertWbs);
        // system.debug('insertProject : ' + insertProject);
        // system.debug('insertBizAttribute : ' + insertBizAttribute);
        // system.debug('insertWeeklyReport : ' + insertWeeklyReport);
        // system.debug('insertRevenueOpportunity1 : ' + insertRevenueOpportunity1);
    }


    // Batch_MdgBusinessController (IF-109) 테스트를 위해 MDGBusinessMaster__c에 데이터 입력
    public static void mdgBusinessMasterInsert (Integer insertCount) {
        List<MDGBusinessMaster__c> businessList = new List<MDGBusinessMaster__c>();

        for (Integer i = 1; i <= insertCount; i++) {
            // Business 입력
            MDGBusinessMaster__c business = new MDGBusinessMaster__c();
            
            business.CLASS__c = 'BusinessCode' + String.valueOf(i);
            business.HCLAS__c = '';
            business.KLAGR__c = 'KL';
            business.VONDT__c = '20201201';
            business.BISDT__c = '99991231';
            business.USEYN__c = 'Y';
            business.Name = 'BusinessCode' + String.valueOf(i);
            business.IFType__c = 'Business';
            business.IFFlag__c = 'I';
            business.ExternalId__c = 'Business' + '|' + 'BusinessCode' + String.valueOf(i) + '|' + ''; // ExternalId (데이터 타입 + CLASS + HCLAS)    
            
            businessList.add(business);
            
            // Business ClassDesc 입력
            MDGBusinessMaster__c businessDesc = new MDGBusinessMaster__c();
            
            businessDesc.CLASS__c = 'BusinessCode' + String.valueOf(i);
            if (math.mod(i, 2) == 0) {
                businessDesc.SPRAS__c = 'K';
                businessDesc.KSCHL__c = 'BusinessCode' + String.valueOf(i) + ' 한글이름';
            } else {
                businessDesc.SPRAS__c = 'E';
                businessDesc.KSCHL__c = 'BusinessCode' + String.valueOf(i) + ' EnglishName';
            }
            businessDesc.KLAGR__c = 'KL';
            businessDesc.NORMB__c = 'N';
            businessDesc.Name = 'BusinessCode' + String.valueOf(i);
            businessDesc.IFType__c = 'ClassDesc';
            businessDesc.IFFlag__c = 'I';
            businessDesc.ExternalId__c = 'ClassDesc' + '|' + 'BusinessCode' + String.valueOf(i) + '|' + ''; // ExternalId (데이터 타입 + CLASS + HCLAS)
            
            businessList.add(businessDesc);
            
            // Service 입력
            MDGBusinessMaster__c service = new MDGBusinessMaster__c();
            
            service.CLASS__c = 'ServiceCode' + String.valueOf(i);
            service.HCLAS__c = 'BusinessCode' + String.valueOf(i);
            service.KLAGR__c = 'KL';
            service.VONDT__c = '20201201';
            service.BISDT__c = '99991231';
            service.USEYN__c = 'Y';
            service.SRVBNC__c = 'srvbnc';
            service.SRVBNT__c = 'srvdpc';
            service.SRVDPC__c = 'srvdpc';
            service.SRVDPT__c = 'srvdpt';     
            service.Name = 'ServiceCode' + String.valueOf(i);
            service.IFType__c = 'Service';
            service.IFFlag__c = 'I';
            service.ExternalId__c = 'Service' + '|' + 'ServiceCode' + String.valueOf(i) + '|' + 'BusinessCode' + String.valueOf(i); // ExternalId (데이터 타입 + CLASS + HCLAS)
            
            businessList.add(service);
            
            // Service ClassDesc 입력
            MDGBusinessMaster__c serviceDesc = new MDGBusinessMaster__c();
            
            serviceDesc.CLASS__c = 'ServiceCode' + String.valueOf(i);
            if (math.mod(i, 2) == 0) {
                serviceDesc.SPRAS__c = 'K';
                serviceDesc.KSCHL__c = 'ServiceCode' + String.valueOf(i) + ' 한글이름';
            } else {
                serviceDesc.SPRAS__c = 'E';
                serviceDesc.KSCHL__c = 'ServiceCode' + String.valueOf(i) + ' EnglishName';
            }
            serviceDesc.KLAGR__c = 'KL';
            serviceDesc.NORMB__c = 'N';
            serviceDesc.Name = 'ServiceCode' + String.valueOf(i);
            serviceDesc.IFType__c = 'ClassDesc';
            serviceDesc.IFFlag__c = 'I';
            serviceDesc.ExternalId__c = 'ClassDesc' + '|' + 'ServiceCode' + String.valueOf(i) + '|' + ''; // ExternalId (데이터 타입 + CLASS + HCLAS)
            
            businessList.add(serviceDesc);
            
            // Solution 입력
            MDGBusinessMaster__c solution = new MDGBusinessMaster__c();
            
            solution.CLASS__c = 'SolutionCode' + String.valueOf(i);
            solution.HCLAS__c = 'ServiceCode' + String.valueOf(i);
            solution.KLAGR__c = 'KL';
            solution.VONDT__c = '20201201';
            solution.BISDT__c = '99991231';
            solution.USEYN__c = 'Y';
            solution.SOLTY__c = '10';
            solution.PRDYN__c = 'Y';
            solution.SOLMNC__c = 'SOLMNC';
            solution.SOLMNT__c = 'SOLMNT';
            solution.SOLDPC__c = 'SOLDPC';
            solution.SOLDPT__c = 'SOLDPT';
            solution.BRAND__c = 'B';
            solution.COMPC__c = 'COMPC';
            solution.PLLEV__c = 'P';
            solution.PLCST__c = 'P';
            solution.LODAT__c = 'LODAT';
            solution.EOPDT__c = 'EOPDT';
            solution.EOSDT__c = 'EOSDT';
            solution.Name = 'SolutionCode' + String.valueOf(i);
            solution.IFType__c = 'Solution';
            solution.IFFlag__c = 'I';
            solution.ExternalId__c = 'Solution' + '|' + 'SolutionCode' + String.valueOf(i) + '|' + 'ServiceCode' + String.valueOf(i); // ExternalId (데이터 타입 + CLASS + HCLAS)
            
            businessList.add(solution);    
            
            // Solution ClassDesc 입력
            MDGBusinessMaster__c solutionDesc = new MDGBusinessMaster__c();
            
            solutionDesc.CLASS__c = 'SolutionCode' + String.valueOf(i);
            if (math.mod(i, 2) == 0) {
                solutionDesc.SPRAS__c = 'K';
                solutionDesc.KSCHL__c = 'SolutionCode' + String.valueOf(i) + ' 한글이름';
            } else {
                solutionDesc.SPRAS__c = 'E';
                solutionDesc.KSCHL__c = 'SolutionCode' + String.valueOf(i) + ' EnglishName';
            }
            solutionDesc.KLAGR__c = 'KL';
            solutionDesc.NORMB__c = 'N';
            solutionDesc.Name = 'SolutionCode' + String.valueOf(i);
            solutionDesc.IFType__c = 'ClassDesc';
            solutionDesc.IFFlag__c = 'I';
            solutionDesc.ExternalId__c = 'ClassDesc' + '|' + 'SolutionCode' + String.valueOf(i) + '|' + ''; // ExternalId (데이터 타입 + CLASS + HCLAS)
            
            businessList.add(solutionDesc);
        }
        
        system.debug('businessList : ' + businessList.size());
        upsert businessList ExternalId__c;        
    }

    public static void deleteMdgBusinessMaster() {

        // Master_Solution__c 삭제
        List<Master_Solution__c> deleteMasterSol = [Select Id from Master_Solution__c where systemModStamp >= LAST_N_DAYS:1 And Code__c Like 'SolutionCode%' ];

        system.debug('전deleteMasterSol : ' + deleteMasterSol.size());
        delete deleteMasterSol;         
        system.debug('후deleteMasterSol : ' + deleteMasterSol.size());
            
        // Master_Service__c 삭제
        List<Master_Service__c> deleteMasterSvc = [Select Id from Master_Service__c where systemModStamp >= LAST_N_DAYS:1 And Code__c Like 'ServiceCode%'];
        
        system.debug('전deleteMasterSvc : ' + deleteMasterSvc.size());
        delete deleteMasterSvc;
        system.debug('후deleteMasterSvc : ' + deleteMasterSvc.size());

        // Business__c 삭제
        List<Business__c> deleteBiz = [Select Id from Business__c where systemModStamp >= LAST_N_DAYS:1 And Code__c Like 'BusinessCode%'];
        
        system.debug('전deleteBiz : ' + deleteBiz.size());
        delete deleteBiz;
        system.debug('후deleteBiz : ' + deleteBiz.size());

        // MDGBusinessMaster__c 삭제 
        List<MDGBusinessMaster__c> deleteMdg = [Select Id from MDGBusinessMaster__c where systemModStamp >= LAST_N_DAYS:1  And (CLASS__c Like 'BusinessCode%' or CLASS__c Like 'ServiceCode%' or CLASS__c Like 'SolutionCode%') ];
        
        system.debug('전deleteMdg : ' + deleteMdg.size());
        delete deleteMdg;
        system.debug('후deleteMdg : ' + deleteMdg.size());
    }
}

/*

// Log 확인
Select 	Id,Name,LogType__c,InterfaceId__c,ApexName__c,ApexMethod__c,StatusCode__c,RequestMessage__c,ExceptionType__c,
		ErrorMessage__c,StackTrace__c,SuccessCount__c,FailCount__c,TotalCount__c,InterfaceGuid__c,StartDatetime__c,EndDatetime__c,
		LogText__c,CpuTime__c,ResponseMessage__c 
from 	IF_Log__c 
where interfaceId__c = 'IF-109' 
and    systemModStamp >= LAST_N_DAYS:1
order by createddate desc 
limit 10

Select IFFlag__c, count(Id) 
from MDGBusinessMaster__c where systemModStamp >= LAST_N_DAYS:1
group by IFFlag__c

// MDGBusinessMaster__c 확인
Select Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, BISDT__c, BRAND__c, CLASS__c, COMPC__c, EOPDT__c, EOSDT__c, HCLAS__c, KLAGR__c, KSCHL__c, LODAT__c, NORMB__c, PLCST__c, PLLEV__c, PRDYN__c, SOLDPC__c, SOLDPT__c, SOLMNC__c, SOLMNT__c, SOLTY__c, SPRAS__c, SRVBNC__c, SRVBNT__c, SRVDPC__c, SRVDPT__c, IFType__c, USEYN__c, VONDT__c, ExternalId__c, IFFlag__c, Type_del__c from MDGBusinessMaster__c where systemModStamp >= LAST_N_DAYS:1

// Business__c 확인
Select Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, Code__c, Description__c, Use__c, ValidityEndDate__c, ValidityStartDate__c from Business__c where systemModStamp >= LAST_N_DAYS:1

// Master_Service__c 확인
Select Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,LastActivityDate,LastViewedDate,LastReferencedDate,Business__c,Code__c,Description__c,ServiceBizUnitCode__c,ServiceBizUnit__c,ServiceDepartmentCode__c,ServiceDepartment__c,Use__c,ValidityEndDate__c,ValidityStartDate__c from Master_Service__c where systemModStamp >= LAST_N_DAYS:1

// Master_Solution__c 확인
Select Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,LastActivityDate,LastViewedDate,LastReferencedDate,Code__c,CompanyCode__c,Description__c,EOPDate__c,EOSDate__c,LODDate__c,PLCStatus__c,PLManagementLevel__c,Product__c,Service__c,SolutionDepartmentCode__c,SolutionDepartment__c,SolutionManageName__c,SolutionManagerNo__c,SolutionType__c,Use__c,ValidityEndDate__c,ValidityStartDate__c from Master_Solution__c where systemModStamp >= LAST_N_DAYS:1




// MDGBusinessMaster__c 입력 실행
IF_Callout_TestDataSetup.mdgBusinessMasterInsert(1);

// Batch_MdgBusinessController 실행
Id batchJobId = Database.executeBatch(new Batch_MdgBusinessController(), 2000);

// 테스트 데이터 삭제 실행
IF_Callout_TestDataSetup.deleteMdgBusinessMaster();

*/