/**
* @description       : 
* @author            : seonju.jin@dkbmc.com
* @group             : 
* @last modified on  : 2023-05-25
* @last modified by  : seonju.jin@dkbmc.com
* Modifications Log 
* Ver   Date         Author                            Modification
* 1.0   2021-02-08   seonju.jin@dkbmc.com              Initial Version
* 1.1   2023-05-25   saurav.k@partner.samsung.com      Code Enhancement regarding 24th/May Developer Script Exception(MySales - 211)
**/
@isTest
public class OpportunityBOReviewMailHelper_Test {
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
    static Opportunity oppty2;
    static Opportunity_Activity__c opptyAct;
    static Service__c service,service2;
    static Solution__c solution,solution2;
    
    static{
        
        Profile p = [SELECT id FROM Profile WHERE name = 'System Administrator' OR name = '시스템 관리자'];
        user = new User(
            Alias = 'standt1', Email='user0001@ss-sds.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='ko_KR', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
            UserName='user0001@ss-sds.com', Division = 'TW',
            EmployeeNumber = '123455', FederationIdentifier = '123123123'
        );
        insert user;
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
        
        emp = new Employee__c(
            Name = 'Test Emp',
            EvMailAddr__c = 'logiUser' + '@samsung.com',
            EvEmpNO__c = '123454',
            EvUniqID__c = user.FederationIdentifier
        );
        insert emp;
        
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
            Amount = 123123123
        );
        insert oppty;
        
        oppty2 = new Opportunity(
            Name = 'Test Oppty',
            CloseDate = System.today(),
            StageName = 'Z01'
        );
        insert oppty2;
        
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
        
        master_solution = new Master_Solution__c(
            Name = 'Test Master Solution',
            Code__c = '30000135'
        );
        insert master_solution;
        
        master_attribute = new BizAttribute__c(
            Name = 'Test Master Attribute',
            Code__c = 'TEST_ATTRIBUTE_0001'
        );
        insert master_attribute;
        
        SvcSolBizAttr__c svcSolBizAttr =  new SvcSolBizAttr__c(
            BizAttribute__c = master_attribute.Id,
            BusinessType__c = 'TI',
            Solution__c = master_solution.Id,
            Use__c = true
        );
        insert svcSolBizAttr;
        
        service = new Service__c(
            Opportunity__c = oppty.Id,
            Service__c = master_service.Id,
            DeliveryDepartment__c = costCenter.Id,
            SalesDepartment__c  = costCenter.Id,
            ItemNumber__c = 10
        );
        insert service;
        
        service2 = new Service__c(
            Opportunity__c = oppty.Id,
            Service__c = master_service.Id,
            DeliveryDepartment__c = costCenter.Id,
            SalesDepartment__c  = costCenter.Id,
            ItemNumber__c = 20,
            SendSAP__c = true
        );
        insert service2;
        
        solution = new Solution__c(
            Opportunity__c = oppty.Id,
            Service__c = service.Id,
            BizAttribute__c = master_attribute.Id,
            Solution__c = master_solution.Id
            
        );
        insert solution;
        
        solution2 = new Solution__c(
            Opportunity__c = oppty.Id,
            Service__c = service2.Id,
            BizAttribute__c = master_attribute.Id,
            Solution__c = master_solution.Id,
            SendSAP__c = true
        );
        insert solution2;
        /* Start -V 1.1- (MYSALES: 211)  */  
        IF_Log__c logUserIsNotActive = new IF_Log__c();
        logUserIsNotActive.StatusCode__c = 'F';
        logUserIsNotActive.StartDatetime__c = system.now();
        logUserIsNotActive.EndDatetime__c = system.now();
        logUserIsNotActive.InterfaceId__c = 'UserIsNotActive';
        logUserIsNotActive.LogType__c = 'Queueable';
        logUserIsNotActive.ExceptionType__c = 'Sales_Rep_Status_is_R';                                       
        logUserIsNotActive.ErrorMessage__c = 'Please check subsidiary BOs Opportunity Sales Rep status';
        logUserIsNotActive.ApexName__c = 'OpportunityBOReviewMailHelper';
        logUserIsNotActive.ApexMethod__c = 'sendKnoxEmail';
        insert logUserIsNotActive;
        
       
        
        user u = [Select Id,FederationIdentifier from user limit 1];
        /* Start V 1.1- (MYSALES: 211)*/
        Employee__c emp1 = new Employee__c();
       // emp1.Status__c = '';
        emp1.EvCellTel__c = '0000-0000';
        emp1.EvCompTel__c = '1111-1111';
        emp1.EvUniqID__c = u.FederationIdentifier;
        emp1.CreatedDate = Datetime.now().addDays(-30);
        emp1.LastModifiedDate = Datetime.now().addDays(-20);
        emp1.EvMailAddr__c = 'test@test.com';
        insert emp1;
        update emp1;
       
         
         KnoxEmail__c knoxEmail = new KnoxEmail__c(
                                            RecordId__c = oppty.Id
                                            , Sender__c = emp1.Id
                                            , ToAddress__c = 'testing213244@gmail.com'
                                            , CcAddress__c = 'example@gmail.com'
                                            , BccAddress__c = 'tes444@gmail.com'
                                            , Name = 'subject'
                                            , HtmlBody__c = 'description'
                                            , MailId__c = 'test566777@gmail.com'
                                            , Status__c = 'Send'
                                        );
        insert knoxEmail;
        /* End -V 1.1- (MYSALES: 211)  */
        
        
    }
    
    @isTest public static void test_method_01(){
       
        KnoxEmail__c knoxEmailData = [SELECT Id,RecordId__c,Sender__c,ToAddress__c,CcAddress__c,BccAddress__c,Name,HtmlBody__c,MailId__c,Status__c from KnoxEmail__c limit 1];
        List<String> toList = new list<String>();
        toList.add(knoxEmailData.ToAddress__c);
        List<String> ccList = new list<String>();
        ccList.add(knoxEmailData.CcAddress__c);
        List<String> bccList = new list<String>();
        bccList.add(knoxEmailData.BccAddress__c);
        //Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());
      Employee__c em = [SELECT Id, Name, EvEName__c, EvSdeptNM__c, EvSdeptENM__c, EvUniqID__c, EvMailAddr__c, EvSapBukrs__c, EvEmpNO__c, EvSapEmpNO__c 
                                              FROM Employee__c 
                                             WHERE Status__c = null
                                               AND EvUniqID__c =: user.FederationIdentifier
                                             LIMIT 1];//V 1.1- (MYSALES: 211)
         
        
        Test.startTest();
        List<Service__c> lservice = [SELECT Id, Name, itemNumber__c, DeletionFlag__c, sService__r.Code__c, sService__r.Name, Service__r.Code__c , Service__r.Name, DeliveryDepartment__c, DeliveryDepartment__r.CostCenter__c, DeliveryDepartment__r.CostCenterName__c, sDeliveryDepartment__c             , sDeliveryDepartment__r.CostCenter__c              , sDeliveryDepartment__r.CostCenterName__c              , sSalesDepartment__c, sSalesDepartment__r.CostCenter__c  , sSalesDepartment__r.CostCenterName__c  , SalesDepartment__c , SalesDepartment__r.CostCenter__c   , SalesDepartment__r.CostCenterName__c   , WBSClass__c, SendSAP__c, WBSCode__c, ServiceBackup__c, ServiceNmBackup__c, DeliveryDepartmentBackup__c, SalesDepartmentBackup__c, DeliveryDepartmentNmBackup__c, SalesDepartmentNmBackup__c, sDeletionFlag__c FROM Service__c];
        List<Solution__c> lsolution = [SELECT Id, Name, Service__c, Service__r.ServiceBackup__c, Service__r.Service__r.Name, Service__r.Service__r.Code__c, Service__r.WBSCode__c, Service__r.DeliveryDepartment__r.CostCenter__c , Service__r.DeliveryDepartment__r.CostCenterName__c , Service__r.SalesDepartment__r.CostCenter__c   , Service__r.SalesDepartment__r.CostCenterName__c   , Service__r.Service__c        , Service__r.sService__r.Name, Service__r.sDeliveryDepartment__r.CostCenter__c , Service__r.sDeliveryDepartment__r.CostCenterName__c , Service__r.sSalesDepartment__r.CostCenter__c   , Service__r.sSalesDepartment__r.CostCenterName__c   , Service__r.sService__r.Code__c, Solution__c     , Solution__r.Name, Solution__r.Code__c       , toLabel(Solution__r.SolutionType__c)  , sSolution__c     , sSolution__r.Name, sSolution__r.Code__c       , toLabel(sSolution__r.SolutionType__c)  , BizAttribute__r.Code__c   , BizAttribute__c , BizAttribute__r.Name, sBizAttribute__r.Code__c   , sBizAttribute__c , sBizAttribute__r.Name, SolutionType__c, sSolutionType__c, ItemNumber__c   , BusinessType__c , sBusinessType__c , WBSClass__c     , sWBSClass__c     , WBSCode__c, ProjectCode__c  , SolutionBackup__c, SolutionNmBackup__c, BizAttributeBackup__c, BizAttributeNmBackup__c, Service__r.ServiceNmBackup__c, Service__r.DeliveryDepartmentNmBackup__c, Service__r.SalesDepartmentNmBackup__c, SendSAP__c, sDeletionFlag__c , DeletionFlag__c  , Changed__c, sPSType__c, PSType__c FROM Solution__c ];
        IF_Log__c ifLog =[SELECT Id, StartDatetime__c , EndDatetime__c, InterfaceId__c, LogType__c, ExceptionType__c, ErrorMessage__c, ApexName__c, ApexMethod__c from IF_Log__c];        
        system.runAs(user){
            OpportunityBOReviewMailHelper helper1 = new OpportunityBOReviewMailHelper(oppty,lservice,lsolution, 'CHANGE_APPROVAL');
            helper1.sendMailInfo();
            OpportunityBOReviewMailHelper helper2 = new OpportunityBOReviewMailHelper(oppty,lservice,lsolution, 'REVIEW_COMPLETED');
            helper2.sendMailInfo();            
            OpportunityBOReviewMailHelper.createInterfaceLog(ifLog);//V 1.1- (MYSALES: 211)
           	OpportunityBOReviewMailHelper.convertDateFormat(Date.newInstance(2016, 12, 9));//V 1.1- (MYSALES: 211)
        }
        Test.stopTest();
    }
}