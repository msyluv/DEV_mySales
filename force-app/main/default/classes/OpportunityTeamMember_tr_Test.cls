@isTest
public with sharing class OpportunityTeamMember_tr_Test {
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

    static Opportunity_Activity__c opptyAct;

    static KnoxApproval__c knoxApproval;
    
    static User salesUser1;
    static User migUser;
    static Employee__c emp1;
    static Employee__c migEmp;

    static RecordType RT_OPPTY_HQ = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
    static RecordType RT_OPPTY_LOGISTICS = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Logistics' Limit 1];

    static {
        // Default Org Switch Setup (checkbox default true)
        trSwitch_default = new TriggerSwitch__c();        
        insert trSwitch_default;

        System.debug('################### ■ OpportunityTeamMember_tr_Test, Start ###################');
        System.debug('<=== ■ [' + Trigger.operationType + '] OpportunityTeamMember_tr_Test ===>');
        
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
            AccountId = acc.Id
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


        emp1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'EPID1');
        salesUser1 = Utils_TestDataFactory.createUserFull(
            Utils_TestDataFactory.getProfile('Sales Rep.(Logi)')
            , emp1.EvMailAddr__c
            , emp1.EvUniqID__c);

        System.debug('<=== ■ ###################### OpportunityTeamMember_tr_Test ===>');
    }
    
    @isTest static void test_method_1() {
        System.debug('<=== ■ test_method_1, startTest ===>');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        insert opptyHQ;

        opptyHQ.StageName = 'Z01';
        // opptyHQ.ProposalPM_User__c = salesUser1.Id;
        opptyHQ.ProposalPM__c = emp1.Id;
        update opptyHQ;

        delete opptyHQ;
		Test.stopTest();
        System.debug('<=== ■ test_method_1, stopTest ===>');
    }
    
}