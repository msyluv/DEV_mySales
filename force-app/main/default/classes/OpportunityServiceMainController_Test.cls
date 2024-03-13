/**
* @author            : younghoon.kim@dkbmc.com
* @group             : 
* @description       : 
* @last modified on  : 2023-05-23
* @last modified by  : gitesh.s@samsung.com
* Modifications Log 
* Ver   Date         Author                           Modification
* 1.0   2020-11-26   younghoon.kim@dkbmc.com          Initial Version
* 1.1   2022-11-15   anish.jain@partner.samsung.com   Coverage for IF -171 'Save' button modification
* 1.2   2022-11-29   divyam.gupta@samsung.com         Coverage for IF -040 & IF-050 added condition for check project name length.
* 1.3   2023-05-23   gitesh.s@samsung.com             Coverage for Department Validity Check (MYSALES-196)
**/
@isTest
public class OpportunityServiceMainController_Test {
    static Master_Service__c master_service,master_service2;
    static Master_Solution__c master_solution;
    static BizAttribute__c master_attribute;
    static CostCenter__c costCenter;
    // v1.3 - Gitesh Saini
    static CostCenter__c invalidCC;
    static User salesRep;
    // v1.3
    static SvcSolBizAttr__c svcSolBizAttr;
    
    static Company__c compnay;
    static Account account;
    static User user;
    static Employee__c emp;
    
    static Opportunity oppty;
    static Opportunity oppty1;
    static Opportunity_Activity__c opptyAct;
    static Service__c service, service_del,service2;
    static Solution__c solution, solution_del,solution2;
    
    static{
        
        MasterActivity__c mastrtAct1_HQ = new MasterActivity__c(
            TransactionName__c=Utils.getPicklistOptionType('MasterActivity__c','TransactionName__c')[0].get('value')
            , Stage__c='Z01',Order__c=1
            , IsRequiredKnoxApproval__c=false
            , Position__c='1',IsImportant__c=true,IsRequired__c=true
            , ObjectApiName__c='Opportunity',IsActive__c=true,Type__c='HQ'
        );
        insert mastrtAct1_HQ;
        
        
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

        // v1.3 - Gitesh Saini
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Sales Rep.(HQ)'];
        salesRep = new User(
            Alias = 'SalesRep', Email='salesrep@sds.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='ko_KR', ProfileId = profile.Id, TimeZoneSidKey='Asia/Seoul', 
            UserName='salesrep@sds.com', Division = 'TW',
            EmployeeNumber = '987654'
        );
        insert salesRep;

        invalidCC = new CostCenter__c(
            Name = 'Test Cost Center', CurrencyIsoCode = 'KRW', CompanyCode__c = 'T100', 
            CostCenterName__c = 'Test Cost Center', CostCenter__c = 'T100-11332', Node1__c = 'T100', 
            Node2__c = 'T100SB', Node3__c = 'T100SB1', Node4__c = 'T100SB13', Node5__c = 'T100SB131', 
            ClosingDate__c = System.today().addDays(2), ZZCheck__c = false, OwnerId = salesRep.Id
        );
        insert invalidCC;
        // v1.3
        
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
            BusinessType__c = 'TI',
            Amount = 11000
        );
        insert oppty;
        
        //START V 1.3 Added by Divyam Gupta
        oppty1 = new Opportunity(
            Name = 'testopp STE_Solution Maintenance extension for DSTA secured phone project DSTA site',
            CloseDate = System.today(),
            StageName = 'Z01',
            SalesDepartment__c = costCenter.Id,
            cPrimarySalesDepartment__c = costCenter.Id,
            OpportunityCode__c = 'SDS-20191511',
            cOriginAcc__c = account.Id,
            ProposalPM__c = emp.Id,
            BusinessLevel__c = 'C',
            cRevenueStartDate__c = revenueStartDate,
            cRevenueEndDate__c = revenueEndDate,
            BiddingMethod__c = 'BID001',
            BusinessType__c = 'TI',
            Amount = 11000
        );
        
        insert oppty1;
        //END V 1.3
        Date firstDayOfMonth = System.today().toStartOfMonth();
        Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
        opptyAct = new Opportunity_Activity__c(
            ExtID__c = oppty.Id + '_ZP21',
            WhatId__c = oppty.Id,
            StartDate__c = firstDayOfMonth,
            EndDate__c = lastDayOfMonth
        );
        insert opptyAct;
        
        master_service = new Master_Service__c(
            Name = 'Test Master Service',
            Code__c = '20000026'
        );
        insert master_service;
        
        master_service2 = new Master_Service__c(
            Name = 'Test Master Service',
            Code__c = '20000024'
        );
        insert master_service2;
        
        master_solution = new Master_Solution__c(
            Name = 'Test Master Solution',
            Code__c = '30000135'
        );
        insert master_solution;
        
        master_attribute = new BizAttribute__c(
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
        
        service_del = new Service__c(
            Opportunity__c = oppty.Id,
            sService__c = master_service.Id,
            Service__c = master_service.Id,
            sDeliveryDepartment__c = costCenter.Id,
            sSalesDepartment__c  = costCenter.Id,
            DeliveryDepartment__c = costCenter.Id,
            SalesDepartment__c  = costCenter.Id,
            ItemNumber__c = 20,
            Changed__c = true,
            SendSAP__c = true,
            sDeletionFlag__c = true
        );
        insert service_del;
        
        service2 = new Service__c(
            Opportunity__c = oppty.Id,
            sService__c = master_service.Id,
            Service__c = master_service.Id,
            sDeliveryDepartment__c = costCenter.Id,
            sSalesDepartment__c  = costCenter.Id,
            DeliveryDepartment__c = costCenter.Id,
            SalesDepartment__c  = costCenter.Id,
            ItemNumber__c = 20,
            Changed__c = true,
            SendSAP__c = true,
            sDeletionFlag__c = false,
            DeletionFlag__c = false
        );
        insert service2;
        
        solution = new Solution__c(
            Opportunity__c = oppty.Id,
            Service__c = service.Id,
            sBizAttribute__c = master_attribute.Id,
            sSolution__c = master_solution.Id,
            sPSType__c = svcSolBizAttr.PsType__c,
            sWBSClass__c = svcSolBizAttr.WBSClass__c,
            sBusinessType__c = svcSolBizAttr.BusinessType__c,
            Changed__c = true,
            sDeletionFlag__c = false
        );
        insert solution;
        
        solution_del = new Solution__c(
            Opportunity__c = oppty.Id,
            Service__c = service_del.Id,
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
            WBSCode__c = 'SCC20201892A00111',
            sDeletionFlag__c = true,
            DeletionFlag__c = false,
            SendSAP__c = true
        );
        insert solution_del;
        
        solution2 = new Solution__c(
            Opportunity__c = oppty.Id,
            Service__c = service2.Id,
            sBizAttribute__c = master_attribute.Id,
            sSolution__c = master_solution.Id,
            sPSType__c = 'SC2',
            sWBSClass__c = 'SC',
            sBusinessType__c = svcSolBizAttr.BusinessType__c,
            BizAttribute__c = master_attribute.Id,
            Solution__c = master_solution.Id,
            PSType__c = svcSolBizAttr.PsType__c,
            WBSClass__c = 'SC',
            BusinessType__c = svcSolBizAttr.BusinessType__c,
            Changed__c = true,
            WBSCode__c = 'SCC20201892A00211',
            sDeletionFlag__c = false,
            DeletionFlag__c = false
        );
        insert solution2;
        
        Opportunity_Activity__c opptyAct = new Opportunity_Activity__c( 
            Status__c= 'In Progress'
            , DueDate__c=System.today()
            , TransactionName__c=OpportunityActivityHelper.ACT_CODE_REVIEW_BO
            , WhatId__c=oppty.Id);
        
        insert opptyAct;
    }
    
    @isTest
    public static void test_method_01(){
        Test.startTest();
        
        OpportunityServiceSolutionMainController.getOpptyInfo(oppty.Id, opptyAct.Id);
        
        //exception
        // OpportunityServiceSolutionMainController.getOpptyInfo(service2.Id, '');
        
        OpportunityServiceSolutionMainController.selectSvcSol(oppty.Id);
        
        
        Boolean isNew = false;
        Boolean isDelete = false;
        
        //신규
        isNew = true; isDelete = false;
        String jsonStr= makeServiceList(20, isNew, isDelete);
        OpportunityServiceSolutionMainController.saveServiceList(oppty.Id, jsonStr, false); 
        
        //수정
        isNew = false; isDelete = false;
        jsonStr= makeServiceList(10, isNew, isDelete);
        OpportunityServiceSolutionMainController.saveServiceList(oppty.Id, jsonStr, false);
        
        //삭제
        isNew = false; isDelete = true;
        jsonStr= makeServiceList(30, isNew, isDelete);
        OpportunityServiceSolutionMainController.saveServiceList(oppty.Id, jsonStr, false);
        
        //Oppty valudation check
        Opportunity oppty_test = new Opportunity(
            Name = 'Test Oppty',
            CloseDate = System.today(),
            StageName = 'Z01'
        );
        insert oppty_test;
        
        OpportunityServiceSolutionMainController.checkRequiredVal(oppty_test);

        // v1.3 - Gitesh Saini
        oppty_test.SalesDepartment__c = invalidCC.Id;
        oppty_test.cPrimarySalesDepartment__c = invalidCC.Id;
        oppty_test.OwnerId = salesRep.Id;
        update oppty_test;

        System.runAs(salesRep) {
            OpportunityServiceSolutionMainController.checkRequiredVal(oppty_test);
        }
        // v1.3
        
        Test.stopTest();
    }
    
    @isTest
    public static void test_method_02(){
        Test.startTest();
        
        IF_Callout_TestMock testmock = new IF_Callout_TestMock();
        Test.setMock(HttpCalloutMock.class, testmock);
        
        //IF-040 프로젝트 생성
        OpportunityServiceSolutionMainController.onConfirmToSAP(oppty.Id);
        
        //IF-050 프로젝스 수정
        Project__c pjt = new Project__c(
            DeletionFlag__c = false,
            Description__c = 'BO Description',
            Opportunity__c = oppty.Id,
            ProjectCode__c = 'SMC-20201761-A0',
            Name = oppty.Name	
        );
        
        insert pjt;
        
        OpportunityServiceSolutionMainController.onConfirmToSAP(oppty.Id); 
        Test.stopTest();
    }
    
    @isTest
    public static void test_method_03(){
        Test.startTest();
        
        //set return json IF-040
        Map<String,Object>  pjtCreateResult = new Map<String,Object>();
        String resData = '';
        resData +='{';
        resData +='    "ET_MESSAGE": [';
        resData +='      {';
        resData +='        "TYPE": "S",';
        resData +='        "ID": null,';
        resData +='        "NUMBER": "000",';
        resData +='        "MESSAGE": "Pjt. Code is created successfully. (SMC20201761A000)",';
        resData +='        "LOG_NO": null,';
        resData +='        "LOG_MSG_NO": "000000",';
        resData +='        "MESSAGE_V1": null,';
        resData +='        "MESSAGE_V2": null,';
        resData +='        "MESSAGE_V3": null,';
        resData +='        "MESSAGE_V4": null,';
        resData +='        "PARAMETER": null,';
        resData +='        "ROW": "0",';
        resData +='        "FIELD": null,';
        resData +='        "SYSTEM": null';
        resData +='      }],';
        resData +='    "ET_WBS_INFO": [';
        resData +='      {';
        resData +='        "PSPID": "SMA20201761A000",';
        resData +='        "PSPID_OUTPUT": "SMA-20201761-A0",';
        resData +='        "POSID": "SMA20201761A001",';
        resData +='        "ZZSOLUTION": null,';
        resData +='        "SERVICE": "20000026",';
        resData +='        "NUMBER_INT":"0000000000",';
        resData +='        "LOEVM": null,';
        resData +='        "SOLUTION_OWNER": "T100-95003",';
        resData +='        "ZZORDER_TYPE_S": "S109"';
        resData +='      },';
        resData +='      {';
        resData +='        "PSPID": "SMA20201761A000",';
        resData +='        "PSPID_OUTPUT": "SMA-20201761-A0",';
        resData +='        "POSID": "SMA20201761A00111",';
        resData +='        "ZZSOLUTION": "30000135",';
        resData +='        "SERVICE": "20000026",';
        resData +='        "NUMBER_INT":"0000000010",';
        resData +='        "LOEVM": null,';
        resData +='        "SOLUTION_OWNER": "T100-12034",';
        resData +='        "ZZORDER_TYPE_S": "S109"';
        resData +='      },';
        resData +='      {';
        resData +='        "PSPID": "SMA20201761A000",';
        resData +='        "PSPID_OUTPUT": "SMA-20201761-A0",';
        resData +='        "POSID": "SMA20201761A00121",';
        resData +='        "ZZSOLUTION": "30000135",';
        resData +='        "SERVICE": "20000026",';
        resData +='        "NUMBER_INT":"0000000010",';
        resData +='        "LOEVM": null,';
        resData +='        "SOLUTION_OWNER": "T100-12034",';
        resData +='        "ZZORDER_TYPE_S": "S109"';
        resData +='      }';
        resData +='    ],';
        resData +='    "ET_PJT_CODE_A": [';
        resData +='      "SMA-20201761-A0"';
        resData +='    ],';
        resData +='    "ET_PJT_CODE_C": [';
        resData +='      "SMC-20201761-A0"';
        resData +='    ]';
        resData +='  }';
        
        List<Service__c> lservice = selectService();
        List<Solution__c> lsolution = selectSolution();
        
        pjtCreateResult = (Map<String,Object>)JSON.deserializeUntyped(resData);
        OpportunityServiceSolutionMainController.saveProject(oppty,lservice,lsolution,pjtCreateResult, 'IF-040');
        //V 1.3 Added by Divyam Gupta
        OpportunityServiceSolutionMainController.saveProject(oppty1,lservice,lsolution,pjtCreateResult, 'IF-040');
        
        Test.stopTest();
    }
    
    @isTest
    public static void test_method_04(){
        Test.startTest();
        Map<String,Object>  pjtChangeResult = new Map<String,Object>();
        
        //set return json IF-050
        String resData = '';
        resData += '{';
        resData +='            "ET_MESSAGE": [';
        resData +='              {';
        resData +='                "TYPE": "S",';
        resData +='                "ID": null,';
        resData +='                "NUMBER": "000",';
        resData +='                "MESSAGE": "",';
        resData +='                "LOG_NO": null,';
        resData +='                "LOG_MSG_NO": "000000",';
        resData +='                "MESSAGE_V1": null,';
        resData +='                "MESSAGE_V2": null,';
        resData +='                "MESSAGE_V3": null,';
        resData +='                "MESSAGE_V4": null,';
        resData +='                "PARAMETER": null,';
        resData +='                "ROW": "0",';
        resData +='                "FIELD": null,';
        resData +='                "SYSTEM": null';
        resData +='              }';
        resData +='            ],';
        resData +='            "ET_WBS_INFO": [';
        resData +='              {';
        resData +='                "PSPID": "SCC20201113A000",';
        resData +='                "PSPID_OUTPUT": "SCC-20201113-A0",';
        resData +='                "POSID": "SCC20201113A000",';
        resData +='                "ZZSOLUTION": "30000135",';
        resData +='                "SERVICE": "20000026",';
        resData +='                "NUMBER_INT":"0000000010",';
        resData +='                "LOEVM": null,';
        resData +='                "SOLUTION_OWNER": "T100-10575",';
        resData +='                "ZZORDER_TYPE_S": "S109"';
        resData +='              },';
        resData +='              {';
        resData +='                "PSPID": "SCC20201113A000",';
        resData +='                "PSPID_OUTPUT": "SCC-20201113-A0",';
        resData +='                "POSID": "SCC20201113A000",';
        resData +='                "ZZSOLUTION": "30000135",';
        resData +='                "SERVICE": "20000026",';
        resData +='                "NUMBER_INT":"0000000010",';
        resData +='                "LOEVM": null,';
        resData +='                "SOLUTION_OWNER": "T100-10575",';
        resData +='                "ZZORDER_TYPE_S": "S109"';
        resData +='              },';
        resData +='              {';
        resData +='                "PSPID": "SCC20201892A000",';
        resData +='                "PSPID_OUTPUT": "SCC-20201892-A0",';
        resData +='                "POSID": "SCC20201892A00111",';
        resData +='                "ZZSOLUTION": "30000135",';
        resData +='                "SERVICE": "20000026",';
        resData +='                "NUMBER_INT":"0000000020",';
        resData +='                "LOEVM": "X",';
        resData +='                "SOLUTION_OWNER": "T100-10575",';
        resData +='                "ZZORDER_TYPE_S": "S109"';
        resData +='              },';
        resData +='              {';
        resData +='                "PSPID": "SCC20201892A000",';
        resData +='                "PSPID_OUTPUT": "SCC-20201892-A0",';
        resData +='                "POSID": "SCC20201892A001",';
        resData +='                "ZZSOLUTION": "",';
        resData +='                "SERVICE": "20000026",';
        resData +='                "NUMBER_INT":"0000000020",';
        resData +='                "LOEVM": "X",';
        resData +='                "SOLUTION_OWNER": "T100-10575",';
        resData +='                "ZZORDER_TYPE_S": "S109"';
        resData +='              },';
        resData +='              {';
        resData +='                "PSPID": "SCC20201113A000",';
        resData +='                "PSPID_OUTPUT": "SCC-20201113-A0",';
        resData +='                "POSID": "SCC20201113A001",';
        resData +='                "ZZSOLUTION": null,';
        resData +='                "SERVICE": "20000026",';
        resData +='                "NUMBER_INT":"0000000010",';
        resData +='                "LOEVM": null,';
        resData +='                "SOLUTION_OWNER": "T100-11313",';
        resData +='                 "ZZORDER_TYPE_S": "S109"';
        resData +='              }]}';
        
        List<Service__c> lservice = selectService();
        List<Solution__c> lsolution = selectSolution();
        
        pjtChangeResult = (Map<String,Object>)JSON.deserializeUntyped(resData);
        OpportunityServiceSolutionMainController.saveProject(oppty,lservice,lsolution,pjtChangeResult, 'IF-050');
        //V 1.3 Added by Divyam Gupta
        OpportunityServiceSolutionMainController.saveProject(oppty1,lservice,lsolution,pjtChangeResult, 'IF-050');
        Test.stopTest();
    }
    
    @isTest
    public static void test_method_05(){
        List<Service__c> lservice = selectService();
        List<Solution__c> lsolution = selectSolution();
        
        OpportunityServiceSolutionMainController.render_IF_050(oppty, lservice, lsolution);
        OpportunityServiceSolutionMainController.render_IF_058(oppty, lservice, lsolution);
    }
    
    @isTest
    public static void test_method_06(){
        Test.startTest();
        String resData = '';
        resData +='{';
        resData +='    "ET_MESSAGE": [';
        resData +='      {';
        resData +='        "TYPE": "S",';
        resData +='        "ID": null,';
        resData +='        "NUMBER": "000",';
        resData +='        "MESSAGE": "SCC-20201892-A0-01-11Erasable WBS.",';
        resData +='        "LOG_NO": null,';
        resData +='        "LOG_MSG_NO": "000000",';
        resData +='        "MESSAGE_V1": null,';
        resData +='        "MESSAGE_V2": null,';
        resData +='        "MESSAGE_V3": null,';
        resData +='        "MESSAGE_V4": null,';
        resData +='        "PARAMETER": null,';
        resData +='        "ROW": "0",';
        resData +='        "FIELD": null,';
        resData +='        "SYSTEM": null';
        resData +='      },';
        resData +='      {';
        resData +='        "TYPE": "S",';
        resData +='        "ID": null,';
        resData +='        "NUMBER": "000",';
        resData +='        "MESSAGE": "SCC-20201892-A0-01-21Erasable WBS.",';
        resData +='        "LOG_NO": null,';
        resData +='        "LOG_MSG_NO": "000000",';
        resData +='        "MESSAGE_V1": null,';
        resData +='        "MESSAGE_V2": null,';
        resData +='        "MESSAGE_V3": null,';
        resData +='        "MESSAGE_V4": null,';
        resData +='        "PARAMETER": null,';
        resData +='        "ROW": "0",';
        resData +='        "FIELD": null,';
        resData +='        "SYSTEM": null';
        resData +='      },';
        resData +='      {';
        resData +='        "TYPE": "S",';
        resData +='        "ID": null,';
        resData +='        "NUMBER": "000",';
        resData +='        "MESSAGE": "SCC-20201892-A0-01-31Erasable WBS.",';
        resData +='        "LOG_NO": null,';
        resData +='        "LOG_MSG_NO": "000000",';
        resData +='        "MESSAGE_V1": null,';
        resData +='        "MESSAGE_V2": null,';
        resData +='        "MESSAGE_V3": null,';
        resData +='        "MESSAGE_V4": null,';
        resData +='        "PARAMETER": null,';
        resData +='        "ROW": "0",';
        resData +='        "FIELD": null,';
        resData +='        "SYSTEM": null';
        resData +='      }';
        resData +='    ]';
        resData +='  }';
        
        Map<String,Object> pjtDeleteResult = (Map<String,Object>)JSON.deserializeUntyped(resData);
        OpportunityServiceSolutionMainController.beforDelete_IF058((List<Object>)pjtDeleteResult.get('ET_MESSAGE'));
        
        List<Service__c> lservice = selectService();
        List<Solution__c> lsolution = selectSolution();
        
        //OpportunityServiceSolutionMainController.rollbackDeleteSvcSol(lservice,lsolution);
        Test.stopTest();
    }
    
    @isTest
    public static void test_method_07(){
        Test.startTest();
        OpportunityServiceSolutionMainController.upsertOpportunityActivity(oppty.Id, 'T100' ,'Completed'); 
        Test.stopTest();
    }
    
    @isTest
    public static void test_method_08(){
        Test.startTest();
        System.enqueueJob(new OpportunityServiceSolutionMainController.Callout_IF093(oppty));
        Test.stopTest();
    }
    
    public static List<Service__c> selectService(){
        return [SELECT Id,Name,itemNumber__c,DeletionFlag__c,sService__r.Code__c,sService__r.Name,Service__r.Code__c ,Service__r.Name ,DeliveryDepartment__c  ,DeliveryDepartment__r.CostCenter__c,DeliveryDepartment__r.CostCenterName__c,sDeliveryDepartment__c,sDeliveryDepartment__r.CostCenter__c,sDeliveryDepartment__r.CostCenterName__c, sSalesDepartment__c,sSalesDepartment__r.CostCenter__c, sSalesDepartment__r.CostCenterName__c, SalesDepartment__c ,SalesDepartment__r.CostCenter__c,SalesDepartment__r.CostCenterName__c,WBSClass__c,SendSAP__c,WBSCode__c,ServiceBackup__c,ServiceNmBackup__c,DeliveryDepartmentBackup__c,SalesDepartmentBackup__c,DeliveryDepartmentNmBackup__c,SalesDepartmentNmBackup__c,sDeletionFlag__c, TechAttribute__c
                FROM Service__c  WHERE Opportunity__c =:oppty.Id];
    }
    
    public static List<Solution__c> selectSolution(){
        return [SELECT Id, Name,Service__c,Service__r.ServiceBackup__c,Service__r.SendSAP__c, Service__r.sDeletionFlag__c , Service__r.DeletionFlag__c, SvcWBSCode__c,Service__r.Service__r.Name,Service__r.Service__r.Code__c,Service__r.WBSCode__c, Service__r.DeliveryDepartment__r.CostCenter__c ,Service__r.DeliveryDepartment__r.CostCenterName__c ,Service__r.SalesDepartment__r.CostCenter__c,Service__r.SalesDepartment__r.CostCenterName__c,Service__r.Service__c,Service__r.sService__r.Name,Service__r.sDeliveryDepartment__r.CostCenter__c ,Service__r.sDeliveryDepartment__r.CostCenterName__c ,Service__r.sSalesDepartment__r.CostCenter__c , Service__r.sSalesDepartment__r.CostCenterName__c , Service__r.sService__r.Code__c,Solution__c, Solution__r.Name, Solution__r.Code__c ,toLabel(Solution__r.SolutionType__c),sSolution__c,sSolution__r.Name  ,sSolution__r.Code__c       ,toLabel(sSolution__r.SolutionType__c)  ,BizAttribute__r.Code__c   ,BizAttribute__c   ,BizAttribute__r.Name,sBizAttribute__r.Code__c   ,sBizAttribute__c   ,sBizAttribute__r.Name,SolutionType__c,sSolutionType__c,ItemNumber__c     ,BusinessType__c   ,sBusinessType__c   ,WBSClass__c       ,sWBSClass__c       ,WBSCode__c,ProjectCode__c    ,SolutionBackup__c,SolutionNmBackup__c,BizAttributeBackup__c,BizAttributeNmBackup__c,Service__r.ServiceNmBackup__c,Service__r.DeliveryDepartmentNmBackup__c, Service__r.SalesDepartmentNmBackup__c, SendSAP__c,sDeletionFlag__c, DeletionFlag__c, Changed__c,sPSType__c, PSType__c, Service__r.TechAttribute__c
                FROM Solution__c WHERE Opportunity__c = :oppty.Id];
    }
    
    public static String makeServiceList(Integer itemNumber, Boolean isNew, Boolean deletion){
        
        List<OpportunityServiceSolutionMainController.SolutionObj> solutionList = new List<OpportunityServiceSolutionMainController.SolutionObj>();
        OpportunityServiceSolutionMainController.Service obj = new OpportunityServiceSolutionMainController.Service();
        List<OpportunityServiceSolutionMainController.ServiceSolution> lservice = new List<OpportunityServiceSolutionMainController.ServiceSolution>();
        OpportunityServiceSolutionMainController.ServiceSolution serviceSolution = new OpportunityServiceSolutionMainController.ServiceSolution();
        OpportunityServiceSolutionMainController.SelectRecord salesRecord = new OpportunityServiceSolutionMainController.SelectRecord();
        OpportunityServiceSolutionMainController.SelectRecord deptRecord = new OpportunityServiceSolutionMainController.SelectRecord();
        OpportunityServiceSolutionMainController.SolutionObj solObj = new OpportunityServiceSolutionMainController.SolutionObj();
        OpportunityServiceSolutionMainController.Solution sol = new OpportunityServiceSolutionMainController.Solution();
        
        salesRecord.Id = costCenter.Id; 
        salesRecord.Name= costCenter.Name;
        
        deptRecord.Id = costCenter.Id;
        deptRecord.Name = costCenter.Name;
        
        obj.recordId= (isNew) ? null : service.Id;
        obj.itemNumber= itemNumber;
        obj.serviceId = master_service.Id;
        obj.salesRecord= salesRecord;
        obj.deptRecord = deptRecord;
        obj.checked = true;
        obj.isChanged = true;
        obj.isDeleted = deletion;
        obj.techyn = false;
        
        sol.recordId= (isNew) ? null : solution.Id;
        sol.serviceRecordId = service.Id;
        sol.serviceId = master_service.Id;
        sol.serviceIdx = 0;
        sol.solutionId = master_solution.Id;
        sol.solutionNm = master_solution.Name;
        sol.attributeId = master_attribute.Id;
        sol.attributeNm = master_attribute.Name;
        sol.isChanged = true;
        sol.isDeleted = deletion;
        sol.itemNumber= itemNumber;
        solObj.solution = sol;
        
        solutionList.add(solObj);
        
        serviceSolution.service = obj;
        serviceSolution.solutionList = solutionList;
        lservice.add(serviceSolution);
        
        String jsonStr= JSON.serialize(lservice);
        return jsonStr;
    }
    
    //@IsTest
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        String responseBody = '';
        
        public MockHttpResponseGenerator(String responseBody){
            this.responseBody = responseBody;
        }
        
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            system.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(responseBody);
            res.setStatusCode(200);
            return res;
        }
    }
    
}