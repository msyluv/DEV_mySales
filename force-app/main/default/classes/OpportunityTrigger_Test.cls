/**
 * @description       : 
 * @author            : wonjune.oh@partner.samsung.com
 * @group             : 
 * @last modified on  : 2024-02-26
 * @last modified by  : sarthak.j1@samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-16   wonjune.oh@partner.samsung.com   Initial Version
 * 1.1   2022-05-30   akash.g@samsung.com              Change functionality for Contract/Origin Account change.
 * 1.2   2023-01-17   anish.jain@partner.samsung.com   Coverage for Manual Sharing part.
 * 1.3	 2023-08-17   aditya.r2@samsung.com			   Coverage for Sales Region
 * 1.4   2023-09-15   divyam.gupta@samsung.com         mySales-293 Warning if Close Date is later than Contract Start Date
 * 1.5   2023-09-20   atul.k1@samsung.com                 Task - (Logistics) Create Alert Message
 * 1.6   2024-01-18   sarthak.j1@samsung.com           Fixing REQUIRED_FIELD_MISSING error
 * 1.7   2024-02-26   sarthak.j1@samsung.com           For increasing code coverage.
 * 1.8   2024-03-19   atul.k1@samsung.com              For increasing code coverage.
**/
@isTest
public with sharing class OpportunityTrigger_Test {
    static TriggerSwitch__c trSwitch_default;
    static Account acc;
    static CostCenter__c costCenterHQ;
    static Company__c company,company2;
    static Opportunity opptyHQ;
    static Opportunity opptyHQ_WON;
    static Opportunity opptyHQ_WON_S4;//Akash
    //Start - Anish v-1.2
    static Opportunity opptyHQ1; 
    static Opportunity opptyHQ2; 
    static Opportunity opptyHQ3; 
    static Opportunity opptyHQ4; 
    static Opportunity opptyHQ5; 
    static Opportunity opptyHQ_WON_1; 
    static Opportunity opptyHQ_WON_NEW; 
    static Opportunity opptyHQ_WON1;
    static Opportunity opptyHQ_WON2;
    static Opportunity opptyHQ_WON_12;
    static Opportunity opptyHQ_WON44; 
    static OpportunityShare optyshare;
    static CostCenter__c cCenter; 
    static CostCenter__c cCenter1;   
    static CostCenter__c cCenter_S4; //Akash
    //End - Anish v-1.2
    static Opportunity opptyLogi;
    static Opportunity opptyLogi2;
    static Opportunity opptyLogi3;
    static Opportunity opptyLogi4;
    static Organization__c org, org1;	// Added by Aditya - v 1.3

    
    static Lead lead;
    static Sales_Lead__c saleslead;

    static Opportunity_Activity__c opptyAct;

    static KnoxApproval__c knoxApproval;
    
    static User salesUser1;
    static User migUser;
    static Employee__c emp1;
    static Employee__c emp2; //Anish v-1.2
    static Employee__c migEmp;

    static RecordType RT_OPPTY_HQ = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
    static RecordType RT_OPPTY_LOGISTICS = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Logistics' Limit 1];

    final static String STAGE_IDENTIFIED = 'Z01';
    final static String STAGE_VALIDATED  = 'Z02';
    final static String STAGE_QUALFIED   = 'Z03';
    final static String STAGE_SOLUTIONED = 'Z04';

    // Opportunity Activity Transaction Name : Picklist
    final static String ACTNAME_Credit_Assessment = '2.2.1.'; // 신용 평가
    final static String ACTNAME_Tariff_Verification = '2.2.3.'; // 전자사업 손익점검
    final static String ACTNAME_Bidding_LBS  = '2.3.2.';
    final static String ACTNAME_Final_LBS = '2.4.5.';
     
    // Opportunity Activity Status : Picklist
    final static String ACTSTATUS_In_Progress = 'In Progress';
    final static String ACTSTATUS_Completed = 'Completed';

    static {
        // Default Org Switch Setup (checkbox default true)
        trSwitch_default = new TriggerSwitch__c();        
        insert trSwitch_default;

        // Mig User Setting
        migEmp  = Utils_TestDataFactory.createEmployee('migEmp', 'migEmp');
        migUser = Utils_TestDataFactory.createUserFull(Utils_TestDataFactory.getProfile('System Administrator')
                                                        , migEmp.EvMailAddr__c
                                                        , migEmp.EvUniqID__c);
        
        // Mig User Switch insert (SetupOwnerId 에 특정 프로필 또는 User 셋팅하여 Test 제어)
        TriggerSwitch__c trSwitch_migUser = new TriggerSwitch__c(
            Migration__c = true,
            SetupOwnerId = migUser.Id
        );        
        insert trSwitch_migUser;
        
        List<Account> accList = new List<Account>();
        Account acc = new Account( 
            Name = 'Test Account',
            MDGCheck__c = true
        );
        accList.add(acc);

        Account accMDG = new Account( 
            Name = 'Test Account',
            MDGCheck__c = true
        );
        accList.add(accMDG);

        insert accList;
        
        List<Company__c> cmpList = new List<Company__c>();
        company = new Company__c(
            Name = '멀티캠퍼스',
            CompanyCode__c = 'T100',
            EPCompanyCode__c = 'PE1',
            CurrencyIsoCode = 'KRW'
        );
        cmpList.add(company);
        company2 = new Company__c(
            Name = '멀티캠퍼스',
            CompanyCode__c = 'T100',
            EPCompanyCode__c = 'PE1',
            CurrencyIsoCode = 'USD'
        );
        cmpList.add(company2);
        insert cmpList;
        
        // Added by Aditya - v 1.3
        List<Organization__c> orgList = new List<Organization__c>();
        org = new Organization__c(
            Name = 'test',
            Region__c = 'M',
            Code__c = 'T714',
            Company__c = company.Id
        );
        orgList.add(org);
        
        org1 = new Organization__c(
            Name = 'test1',
            Region__c = 'A',
            Code__c = 'T802',
            Company__c = company.Id
        );
        orgList.add(org1);
        
        insert orgList;

        costCenterHQ = new CostCenter__c(
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
        );
        insert costCenterHQ;
        
         opptyHQ = new Opportunity(
            Name = 'Test Opportunity',
            RecordTypeId = RT_OPPTY_HQ.Id,
            ProposalPM_User__c = migUser.Id, //Anish v-1.2
            MigData__c = True,  //Anish v-1.2
            StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today(),
            AccountId = acc.Id,
            CurrencyIsoCode = 'USD', // Atul MySales-296 V 1.5
            Amount = 5000000,
            cLeadID__c = NULL
        );
        
        //Start-Anish v-1.2
        opptyHQ1 = new Opportunity(
            Name = 'Test Opportunity',
            RecordTypeId = RT_OPPTY_HQ.Id,
            CspMspType__c = 'CSP', 
            OtherCSP__c = 'CSP1',
            MSP_Amount__c = 200,
            StageName = 'Z01',
            cPrimarySalesDepartment__c = null,
            CloseDate = Date.today(),
            AccountId = acc.Id,
            cLeadID__c = NULL
        );
               
        opptyHQ2 = new Opportunity(
            Name = 'Test Opportunity',
            RecordTypeId = RT_OPPTY_HQ.Id,
            CspMspType__c = 'MSP', 
            SCPScale__c = 5000,
            ConversionType__c = 'Re-host',
            CMBizType__c= 'MSP_Integration',
            MSP_Amount__c = 2000,
            StageName = 'Z01',
            cPrimarySalesDepartment__c = null,
            CloseDate = Date.today(),
            AccountId = acc.Id,
            cLeadID__c = NULL
        ); 

        opptyHQ3 = new Opportunity(
            Name = 'Test Opportunity',
            RecordTypeId = RT_OPPTY_HQ.Id,
            CspMspType__c = 'Saas', 
            OtherCSP__c = 'CSP1',
            SCPScale__c = 8000,
            StageName = 'Z01',
            cPrimarySalesDepartment__c = null,
            CloseDate = Date.today(),
            AccountId = acc.Id,
            cLeadID__c = NULL
        );
        
        cCenter = new CostCenter__c(
        Name = 'Digital Group',
        Node2__c = 'T100S3'
        );
        insert cCenter;
        
        
        
        cCenter1 = new CostCenter__c(
        Name = 'Digital Grouping',
        Node2__c = 'T514S4',
        BA__c = 'ET36'   //V 1.8
            
        );
        insert cCenter1;
        //End-Anish v-1.2
        //Akash Start
        cCenter_S4 = new CostCenter__c(
        Name = 'Digital Groups',
        Node2__c = 'T100S4',
        ZZCheck__c= true,
        BA__c = 'ET36'   // V 1.8
        );
        insert cCenter_S4;
        
         opptyHQ_WON_S4  = new Opportunity(
            Name = 'Test Opportunity WON_S4',
            RecordTypeId = RT_OPPTY_HQ.Id,
            cPrimarySalesDepartment__c = cCenter_S4.Id, //Anish v-1.2
            StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today(),
            AccountId = accMDG.Id
        );
        
        
        //Akash end
        opptyHQ_WON  = new Opportunity(
            Name = 'Test Opportunity WON',
            RecordTypeId = RT_OPPTY_HQ.Id,
            cPrimarySalesDepartment__c = cCenter.Id, //Anish v-1.2
            StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today(),
            AccountId = accMDG.Id
        );
        
        //Start-Anish v-1.2
        opptyHQ_WON_1  = new Opportunity(
            Name = 'Test Opportunity WON',
            RecordTypeId = RT_OPPTY_HQ.Id,
            CspMspType__c = 'CSP',
            StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today(),
            AccountId = accMDG.Id
        );
        
          opptyHQ_WON_12  = new Opportunity(
            Name = 'Test Opportunity WON',
            RecordTypeId = RT_OPPTY_HQ.Id,
            CspMspType__c = 'MSP',
            Amount = 500,
            StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today(),
            AccountId = accMDG.Id
        );
        
        opptyHQ_WON_NEW  = new Opportunity(
            Name = 'Test Opportunity WON',
            RecordTypeId = RT_OPPTY_HQ.Id,
            cPrimarySalesDepartment__c = cCenter1.Id,
            StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today(),
            AccountId = accMDG.Id
        );
        
          emp2 = Utils_TestDataFactory.createEmployee('TestEmp2', 'EPID2');
        salesUser1 = Utils_TestDataFactory.createUserFull(
            Utils_TestDataFactory.getProfile('Sales Rep.(Logi)')
            , emp2.EvMailAddr__c
            , emp2.EvUniqID__c);

        opptyHQ_WON44  = new Opportunity(
            Name = 'Test Opportunity WON',
            RecordTypeId = RT_OPPTY_HQ.Id,
            ProposalPM__c = emp2.Id,
            StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today(),
            AccountId = accMDG.Id
        );

         opptyHQ_WON1  = new Opportunity(
            Name = 'Test Opportunity WON',
            RecordTypeId = RT_OPPTY_HQ.Id,
            StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today(),
            Amount =  1000000000,
            CurrencyIsoCode = 'INR',
            AccountId = accMDG.Id
        );
        
         opptyHQ_WON2  = new Opportunity(
            Name = 'Test Opportunity WON',
            RecordTypeId = RT_OPPTY_HQ.Id,
            StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today(),
            Amount =  2000000000,
            CurrencyIsoCode = 'KRW',
            AccountId = accMDG.Id
        );
        //End-Anish v-1.2
        
        opptyLogi = new Opportunity(
            Name = 'Test Logi Opportunity 1',
            RecordTypeId = RT_OPPTY_LOGISTICS.Id,
            LBSExceptionType__c = '05', //Anish v-1.2
            type = '01', //Anish v-1.2
            LogisticsBizDevelopmentType__c = '10', //Anish v-1.2
            StageName = 'Z01',
            CloseDate = Date.today(),
            AccountId = acc.Id,
            SalesOrganization__c = org.Id,	// Added by Aditya - v 1.3
            DeliveryOrganization__c = org.Id	// Added by Aditya - v 1.3
        );

        opptyLogi2 = new Opportunity(
            Name = 'Test Logi Opportunity 2',
            RecordTypeId = RT_OPPTY_LOGISTICS.Id,
            LBSExceptionType__c = '01', //Anish v-1.2
            StageName = 'Z01',
            CloseDate = Date.today(),
            AccountId = accMDG.Id
        );

        opptyLogi3 = new Opportunity(
            Name = 'Test Logi Opportunity 3',
            RecordTypeId = RT_OPPTY_LOGISTICS.Id,
            LBSExceptionType__c = '07', //Anish v-1.2
            StageName = 'Z01',
            CloseDate = Date.today(),
            AccountId = accMDG.Id
        );

        opptyLogi4 = new Opportunity(
            Name = 'Test Logi Opportunity 4',
            RecordTypeId = RT_OPPTY_LOGISTICS.Id,
            StageName = 'Z01',
            CloseDate = Date.today()
        );
        
        lead = new Lead(LastName = 'TestLead', 
                     PersonalInfoAgreementExpireDate__c = Date.today(), 
                     PersonalInfoAgreement__c = true, 
                     Company='TestCompany');
            
        saleslead = new Sales_Lead__c(
            Name = 'TestSalesLead', 
            LeadStage__c = 'Hot',
            Lead__c = lead.Id, 
            Amount__c = 5000, 
            AccountId__c = acc.Id,
            CloseDate__c = Date.today().addDays(1),  
            RevenueEndDate__c = Date.today().addDays(3), 
            RevenueStartDate__c = Date.today().addDays(2),
            Budget__c = true,
            Authority__c = true,
            //Start v-1.6
            SalesDepartment__c = [SELECT Id FROM CostCenter__c LIMIT 1].Id
            //End v-1.6
        );
		

        emp1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'EPID1');
        salesUser1 = Utils_TestDataFactory.createUserFull(
            Utils_TestDataFactory.getProfile('Sales Rep.(Logi)')
            , emp1.EvMailAddr__c
            , emp1.EvUniqID__c);

    }
   

    @isTest static void test_migUser() {
        Test.startTest();
        System.runAs(migUser) {
            insert lead;
        	insert saleslead;
            insert opptyHQ;
            opptyHQ.StageName = 'Z01';
            opptyHQ.ProposalPM__c = emp1.Id;
            opptyHQ.cLeadID__c = saleslead.Id;
            update opptyHQ;

            delete opptyHQ;
        }
        Test.stopTest();
    }

    @isTest static void test_changeStage() {
        Test.startTest();
        insert opptyHQ_WON;
        opptyHQ_WON.StageName = 'Z05';
        opptyHQ_WON.LBSExceptionType__c = '05';
        update opptyHQ_WON;
        Test.stopTest();
    }
    
    
    //Start-Anish v-1.2
     @isTest static void test_changeStage_new_1() {
        Test.startTest();
        insert opptyHQ_WON_1;
        opptyHQ_WON_1.StageName = 'Z05';
        opptyHQ_WON_1.LBSExceptionType__c = '05';
        opptyHQ_WON_1.CspMspType__c = 'CSP';
        update opptyHQ_WON_1;
        Test.stopTest();
    }
    
         @isTest static void test_changeStage_new_12() {
        Test.startTest();
        insert opptyHQ_WON_12;
        opptyHQ_WON_12.Amount = 5000;
        opptyHQ_WON_12.CspMspType__c = 'MSP';
        update opptyHQ_WON_12;
        Test.stopTest();
    }

     @isTest static void test_changeStage_new() {
        Test.startTest();
        insert opptyHQ_WON_NEW;
        opptyHQ_WON.CurrencyIsoCode = 'INR';
        opptyHQ_WON.StageName = 'Z01';
        opptyHQ_WON.LBSExceptionType__c = '05';
        update opptyHQ_WON_NEW;
        Test.stopTest();
    }
    //End-Anish v-1.2
   

    @isTest static void test_changeStage2() {
        Test.startTest();
        insert opptyHQ_WON;
         
        opptyHQ_WON.StageName = 'Z06';
        update opptyHQ_WON;
        Test.stopTest();
    }
    //Start-Anish v-1.2
     @isTest static void test_changeStage22() {
        Test.startTest();
        insert opptyHQ_WON1;

        opptyHQ_WON.StageName = 'Z06';
        update opptyHQ_WON1;
        Test.stopTest();
    }
    
     @isTest static void test_changeStage222() {
        Test.startTest();
        insert opptyHQ_WON2;

        opptyHQ_WON.StageName = 'Z06';
        update opptyHQ_WON2;
        Test.stopTest();
    }
    
        @isTest static void test_changeStage44() {
        Test.startTest();
        emp2.EvSapBukrs__c = 'T100';
        emp2.EvUniqID__c = 'ABCD3425';
        update emp2;
        insert opptyHQ_WON44;

        opptyHQ_WON.StageName = 'Z08';
        update opptyHQ_WON44;
        Test.stopTest();
    }
    //End-Anish v-1.2
    
    @isTest static void test_changeStage3() {
        Test.startTest();
        insert opptyHQ_WON;
        
        opptyHQ_WON.StageName = 'Z07';
        update opptyHQ_WON;
        Test.stopTest();
    }
    @isTest static void test_changeStage4() {
        Test.startTest();
        insert opptyHQ_WON;

        opptyHQ_WON.StageName = 'Z08';
        update opptyHQ_WON;
        Test.stopTest();
    }

    @isTest static void test_setValueFilterPicklist() {
        Test.startTest();
        insert opptyHQ;

        opptyHQ_WON.StageName = OpportunityActivityHelper.OPP_STAGE_WON;
        opptyHQ.cOriginAcc__c = null;
        
        update opptyHQ;
        Test.stopTest();
    }
	    
   //V1.1 -> Change functionality for Contract/Origin Account change.
     @isTest static void test_method_changeAccount_01() {
        Test.startTest();
        insert opptyHQ1; //Anish v-1.2
 		Account accMDG1 = new Account( 
            Name = 'Test Account 1',
            MDGCheck__c = true
        );
        insert accMDG1;

        Test.stopTest();
    }
    //V1.1 -> Change functionality for Contract/Origin Account change.
    @isTest static void test_method_changeAccount_02() {
        Test.startTest();
        insert opptyHQ;
 		Account accMDG1 = new Account( 
            Name = 'Test Account 1',
            MDGCheck__c = true
        );
        insert accMDG1;

        Test.stopTest();
    }
	//V1.1 -> Change functionality for Contract/Origin Account change.
	@isTest static void test_method_changeAccount_03() {
        Test.startTest();
        insert opptyHQ;
 		Account accMDG1 = new Account( 
            Name = 'Test Account 1',
            MDGCheck__c = true
        );
        insert accMDG1;
        Test.stopTest();
    }
    
       //Start- Anish
     @isTest static void test_method_changeAccount_011() {
        Test.startTest();
        insert opptyHQ2; 
 		Account accMDG1 = new Account( 
            Name = 'Test Account 1',
            MDGCheck__c = true
        );
        insert accMDG1;

        Test.stopTest();
    }
    
    /* @isTest static void test_method_changeAccount_0111() {
        Test.startTest();
        insert opptyHQ3; 
 		Account accMDG1 = new Account( 
            Name = 'Test Account 1',
            MDGCheck__c = true
        );
        insert accMDG1;

        Test.stopTest();
    } */
    
     @isTest static void test_method_changeAccount_01111() {
        Test.startTest();
        insert opptyLogi; 
 		Account accMDG1 = new Account( 
            Name = 'Test Account 1',
            MDGCheck__c = true
        );
        insert accMDG1;
        opptyLogi.SalesOrganization__c = org1.Id;	// Added by Aditya - v 1.3
        opptyLogi.DeliveryOrganization__c = org1.Id;	// Added by Aditya - v 1.3
        update opptyLogi;	// Added by Aditya - v 1.3

        Test.stopTest();
    }
    
     @isTest static void test_method_changeAccount_011112() {
        Test.startTest();
        insert opptyLogi3; 
 		Account accMDG1 = new Account( 
            Name = 'Test Account 1',
            MDGCheck__c = true
        );
        insert accMDG1;

        Test.stopTest();
    }
    
     @isTest static void test_method_changeAccount_011111() {
        Test.startTest();
        insert opptyLogi2; 
 		Account accMDG1 = new Account( 
            Name = 'Test Account 1',
            MDGCheck__c = true
        );
        insert accMDG1;

        Test.stopTest();
    }
  //End-Anish v-1.2  
  
 //Akash Start
      @isTest static void test_changeStage_S4() {
        Test.startTest();
        
        opptyHQ_WON.StageName = 'Z05';
        opptyHQ_WON.cPrimarySalesDepartment__c = cCenter_S4.Id;
        opptyHQ_WON.LBSExceptionType__c = '05';
        insert opptyHQ_WON_S4;
        update opptyHQ_WON_S4;
        Test.stopTest();
    }
    // START V 1.4
    @isTest static void test_checkcloseDate() {
        Test.startTest();
         opptyHQ.Check_Close_Date__c = false;
         opptyHQ.cRevenueStartDate__c	= Date.today()-4;
        insert opptyHQ;

         opptyHQ.cRevenueStartDate__c	= Date.today()-3;
        
        update opptyHQ;
        Test.stopTest();
    }
        // END V 1.4
    //Start v-1.7
    @isTest
    static void test_oppDelete(){
        Test.startTest();
        opptyHQ3.CspMspType__c = 'CSP';
        insert opptyHQ3;
        delete opptyHQ3;
        Test.stopTest();
    }
    //End v-1.7
    //Start v-1.8
    @isTest
    static void test_BussinessAreaChange(){
        Test.startTest();
        Account accMDG = new Account( 
            Name = 'Test Account',
            MDGCheck__c = true
        );
       
        
        opptyHQ5  = new Opportunity(
            Name = 'Test Opportunity HQ5',
            RecordTypeId = RT_OPPTY_HQ.Id,
            cPrimarySalesDepartment__c = cCenter_S4.Id, //Anish v-1.2
            StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today(),
            AccountId = accMDG.Id
        );
        insert opptyHQ5;
        Project__c prj = new Project__c();
        prj.Opportunity__c = opptyHQ5.id;
        prj.DeletionFlag__c = false;
        insert prj;
        opptyHQ5.cPrimarySalesDepartment__c= cCenter1.id;
        Update opptyHQ5;
        Test.stopTest();
    }
    //End v-1.8 
    

}