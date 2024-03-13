/**
 * @description       : 
 * @author            : wonjune.oh@partner.samsung.com
 * @group             : 
 * @last modified on  : 2022-05-30
 * @last modified by  : akash.g@samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-16   wonjune.oh@partner.samsung.com   Initial Version
 * 1.1   2022-05-30   akash.g@samsung.com              Change functionality for Contract/Origin Account change.
**/
@isTest
public class OpportunityValidateHelper_Test {
     static TriggerSwitch__c trSwitch_default;
    static Account acc;
    static CostCenter__c costCenterHQ;
    static Company__c company,company2;
    static Opportunity opptyHQ;
    static Opportunity opptyHQ_WON;
    static Opportunity opptyLogi;
    static Opportunity opptyLogi2;
    static Opportunity opptyLogi3;
    static Opportunity opptyLogi4;
    static Opportunity opptyLogi5; // added by kajal
    
    static Lead lead;
    static Sales_Lead__c saleslead;

    static Opportunity_Activity__c opptyAct;

    static KnoxApproval__c knoxApproval;
    
    static User salesUser1;
    static User migUser;
    static Employee__c emp1;
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
            StageName = 'Z02',
            CloseDate = Date.today(),
            AccountId = acc.Id,
            cLeadID__c = NULL
        );

        opptyHQ_WON  = new Opportunity(
            Name = 'Test Opportunity WON',
            RecordTypeId = RT_OPPTY_HQ.Id,
            StageName = OpportunityActivityHelper.OPP_STAGE_WON,
            CloseDate = Date.today(),
            AccountId = accMDG.Id
        );

        opptyLogi = new Opportunity(
            Name = 'Test Logi Opportunity 1',
            RecordTypeId = RT_OPPTY_LOGISTICS.Id,
            StageName = 'Z01',
            CloseDate = Date.today(),
            AccountId = acc.Id
        );

        opptyLogi2 = new Opportunity(
            Name = 'Test Logi Opportunity 2',
            RecordTypeId = RT_OPPTY_LOGISTICS.Id,
            StageName = 'Z01',
            CloseDate = Date.today(),
            AccountId = accMDG.Id
        );

        opptyLogi3 = new Opportunity(
            Name = 'Test Logi Opportunity 3',
            RecordTypeId = RT_OPPTY_LOGISTICS.Id,
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
            Authority__c = true
        );
		

        emp1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'EPID1');
        salesUser1 = Utils_TestDataFactory.createUserFull(
            Utils_TestDataFactory.getProfile('Sales Rep.(Logi)')
            , emp1.EvMailAddr__c
            , emp1.EvUniqID__c);

    }
/*
    @isTest static void test_method_1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        insert opptyHQ;

        opptyHQ.StageName = 'Z01';
        // opptyHQ.ProposalPM_User__c = salesUser1.Id;
        opptyHQ.ProposalPM__c = emp1.Id;
        update opptyHQ;

        delete opptyHQ;
		Test.stopTest();
    }
*/    


    /**
     * RecordType logistics Validate1
     */
     @isTest static void test_validateLogistics_external() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        system.runAs(salesUser1) {
            insert opptyLogi;

            // [C1~C6. Customer Type (External)]  
            // TEST : I → V : 신용평가 '진행 이후' 변경 가능
            // 🔴 negative case
            opptyLogi.LogisticsCustomerType__c = OpportunityActivityHelper.OPP_CUSTOMER_TYPE_EXTERNAL;
            opptyLogi.Type                     = OpportunityActivityHelper.OPP_TYPE_NEW_OPPORTUNITY;
            opptyLogi.LBSExceptionType__c      = OpportunityActivityHelper.OPP_LBS_TYPE_NA;
            opptyLogi.StageName = STAGE_VALIDATED;
            try { 
                update opptyLogi;
                System.assert(false);
            } catch (Exception e) {
                System.assert(e.getMessage().indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') > -1, '🔴 Validation Error : '  + e.getMessage() );
            }

       
        }
    } 
    
    
     @isTest static void test_validateLogistics_external1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        system.runAs(salesUser1) {
            insert opptyLogi;

            // [C1~C6. Customer Type (External)]  
            // TEST : I → V : 신용평가 '진행 이후' 변경 가능
            // 🔴 negative case
            opptyLogi.LogisticsCustomerType__c = OpportunityActivityHelper.OPP_CUSTOMER_TYPE_EXTERNAL;
            opptyLogi.Type                     = OpportunityActivityHelper.OPP_TYPE_NEW_OPPORTUNITY;
            opptyLogi.LBSExceptionType__c      = OpportunityActivityHelper.OPP_LBS_TYPE_SQUARE_PRODUCT;
            opptyLogi.StageName = OpportunityActivityHelper.OPP_STAGE_QUALIFIED;
            try { 
                update opptyLogi;
                //System.assert(false);
            } catch (Exception e) {
                //System.assert(e.getMessage().indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') > -1, '🔴 Validation Error : '  + e.getMessage() );
            }

       
        }
    } 
    
    

    /*
    @isTest static void test_validateLogistics_external2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        system.runAs(salesUser1) {
            // [C3. Customer Type (External) + Opportunity Type (New Opportunity) + LBS Exception Type (N/A)]
            // ? → Q : Bidding LBS '완료' 이후
            // ? → S : Final LBS '완료' 이후
            // 🔴 negative case
            opptyLogi2.LogisticsCustomerType__c = OpportunityActivityHelper.OPP_CUSTOMER_TYPE_EXTERNAL;
            opptyLogi2.Type                     = OpportunityActivityHelper.OPP_TYPE_NEW_OPPORTUNITY;
            opptyLogi2.LBSExceptionType__c      = OpportunityActivityHelper.OPP_LBS_TYPE_NA;
            insert opptyLogi2;

            opptyLogi2.StageName = STAGE_QUALFIED;
            try {
                update opptyLogi2;
                System.assert(false);
            } catch (Exception e) {
                System.assert(e.getMessage().indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') > -1, '🔴 Validation Error : '  + e.getMessage() );
            }

            // 💚 positive case
            opptyAct = new Opportunity_Activity__c(
                WhatId__c = opptyLogi2.Id
                , TransactionName__c = ACTNAME_Bidding_LBS
                , Status__c = 'Completed'
            );
            insert opptyAct;

            try {
                opptyLogi2.StageName = STAGE_QUALFIED;
                update opptyLogi2;
            } catch (Exception e) {
                System.assert(false, 'Test Error, Must be Success!');
            }

            opptyAct = new Opportunity_Activity__c(
                WhatId__c = opptyLogi2.Id
                , TransactionName__c = ACTNAME_Final_LBS
                , Status__c = 'Completed'
            );
            insert opptyAct;

            try {
                opptyLogi2.StageName = STAGE_SOLUTIONED;
                update opptyLogi2;
            } catch (Exception e) {
                System.assert(false, 'Test Error, Must be Success!');
            }
        }

        Test.stopTest();
    }
	*/

    /* @isTest static void test_validateLogistics_secSet() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        system.runAs(salesUser1) {
           // [C7~C12. Customer Type (SEC-SET)]
           // I → V : Tariff Verification '완료' 이후
           
            //insert opptyLogi;
            List<Opportunity> insertList = new List<Opportunity>();
            insertList.add(opptyLogi);
            insertList.add(opptyLogi2);

            insert insertList;
            
            opptyLogi.LogisticsCustomerType__c = OpportunityActivityHelper.OPP_CUSTOMER_TYPE_SEC_SET;
            opptyLogi.Type                     = OpportunityActivityHelper.OPP_TYPE_NEW_OPPORTUNITY;
            opptyLogi.LBSExceptionType__c      = OpportunityActivityHelper.OPP_LBS_TYPE_NA;
            opptyLogi.StageName = STAGE_VALIDATED;

            // [C9. Customer Type (SEC-SET) + Opportunity Type (New Opportunity) + LBS Exception Type (N/A)]
            // ? → S : Final LBS '완료' 이후
            opptyLogi2.LogisticsCustomerType__c = OpportunityActivityHelper.OPP_CUSTOMER_TYPE_SEC_SET;
            opptyLogi2.Type                     = OpportunityActivityHelper.OPP_TYPE_NEW_OPPORTUNITY;
            opptyLogi2.LBSExceptionType__c      = OpportunityActivityHelper.OPP_LBS_TYPE_NA;
            opptyLogi2.StageName = STAGE_SOLUTIONED;

            List<Opportunity> updateList = new List<Opportunity>();

            // 🔴 negative case
            try {
                updateList.add(opptyLogi);
                updateList.add(opptyLogi2);
                update updateList;
                System.assert(false);
            } catch (Exception e) {
                System.assert(e.getMessage().indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') > -1, '🔴 Validation Error : '  + e.getMessage() );
            }

            List<Opportunity_Activity__c> insertActList = new List<Opportunity_Activity__c>();

            // 💚 positive case
            // I → V : Tariff Verification '완료' 이후
            opptyAct = new Opportunity_Activity__c(
                WhatId__c = opptyLogi.Id
                , TransactionName__c = ACTNAME_Tariff_Verification
                , Status__c = 'Completed'
            );
            insertActList.add(opptyAct);

            // ? → S : Final LBS '완료' 이후
            Opportunity_Activity__c opptyAct2 = new Opportunity_Activity__c(
                WhatId__c = opptyLogi2.Id
                , TransactionName__c = ACTNAME_Final_LBS
                , Status__c = 'Completed'
            );
            insertActList.add(opptyAct2);

            insert insertActList;
            try {
                update updateList;
            } catch (Exception e) {
                System.assert(false, 'Test Error, Must be Success!');
            }
        }
    } */


    /* @isTest static void test_collaboration() {
        Test.startTest();
        
        List<Employee__c> empList = new List<Employee__c>();
        Employee__c empHQ = Utils_TestDataFactory.createEmployee('TestEmp1123123', 'EPID11');
        empHQ.EvKostl__c = 'T100-11331';
        empList.add(empHQ);

        User salesUser1 = Utils_TestDataFactory.createUserFull(
            Utils_TestDataFactory.getProfile('Sales Rep.(HQ)')
            , empHQ.EvMailAddr__c
            , empHQ.EvUniqID__c);

        Employee__c emp = Utils_TestDataFactory.createEmployee('TestEmp23232323', 'EPID222');
        emp.EvKostl__c = 'T320-11331';
        empList.add(emp);

        update empList;

        User salesUser2 = Utils_TestDataFactory.createUserFull(
            Utils_TestDataFactory.getProfile('Sales Rep.(HQ)')
            , emp.EvMailAddr__c
            , emp.EvUniqID__c);
        
        system.runAs(salesUser1) {
            Opportunity originOppty = new Opportunity(
                Name = 'Test Opportunity',
                RecordTypeId = RT_OPPTY_HQ.Id,
                StageName = 'Z02',
                CloseDate = Date.today(),
                OwnerId = salesUser1.Id
            );

            insert originOppty;

            Opportunity collaboOppty = new Opportunity(
                Name = 'Test Opportunity',
                RecordTypeId = RT_OPPTY_HQ.Id,
                StageName = 'Z02',
                CloseDate = Date.today(),
                IsOriginal__c = false,
                CollaborationBOId__c = originOppty.Id,
                OwnerId = salesUser2.Id
            );

            insert collaboOppty;
        }
        
        Test.stopTest();
    } */

    /*
    @isTest static void test_chkAmtValid(){
        Test.startTest();
        opptyHQ.CompanyCode__c = 'T100';
        insert opptyHQ;
        Test.stopTest();
    }*/
    
 
    /*
     * 
     * @isTest static void test_saveSalesLead(){
        Test.startTest();
        insert lead;
        insert saleslead;
        insert opptyHQ;
        opptyHQ.cLeadID__c = saleslead.Id;
        update opptyHQ;
        delete opptyHQ;
        Test.stopTest();
        
    }
	
*/

}