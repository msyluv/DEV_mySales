/**
 * @description       : 
 * @author            : hyunhak.roh@dkbmc.com
 * @group             : 
 * @last modified on  : 2023-14-12
 * @last modified by  : atul.k1@samsung.com 
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2022-05-12   hyunhak.roh@dkbmc.com   Initial Version
 * 1.1   2023-14-12   atul.k1@samsung.com     IF-038 Modification related to billing authority(MYSALES-368)
**/
@isTest
public class OpportunityTeamMember_Test {
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

    //static KnoxApproval__c knoxApproval;
    static OpportunityTeamMember opptyTeamMember;
    
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
            StageName = 'Z01',//OpportunityActivityHelper.OPP_STAGE_WON, // V.1.1
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


        emp1 = Utils_TestDataFactory.createEmployee('TestEmp22', 'EPID1');
        salesUser1 = Utils_TestDataFactory.createUserFull(
            Utils_TestDataFactory.getProfile('Sales Rep.(Logi)')
            , emp1.EvMailAddr__c
            , emp1.EvUniqID__c);
        emp1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'EPID2');
        salesUser1 = Utils_TestDataFactory.createUserFull(
            Utils_TestDataFactory.getProfile('Sales Rep.(Logi)')
            , emp1.EvMailAddr__c
            , emp1.EvUniqID__c);

    }
    
     @isTest static void test_teamMember() {
        Test.startTest();
        insert opptyHQ_WON;

        opptyHQ_WON.StageName = 'Z05';
        opptyHQ_WON.LBSExceptionType__c = '05';
        update opptyHQ_WON;
         
     	//
     	opptyTeamMember = new OpportunityTeamMember(
            OpportunityId = opptyHQ_WON.Id,
            UserId = salesUser1.Id,
            //Name = 'TestEmp1',
            TeamMemberRole = 'Proposal PM'
        );
		
        insert opptyTeamMember;
        
		opptyTeamMember = new OpportunityTeamMember(
            Id = opptyTeamMember.Id,
            OpportunityId = opptyHQ_WON.Id,
            UserId = salesUser1.Id,
            TeamMemberRole = 'Sales Rep'
        ); 
        update opptyTeamMember;
            
        Test.stopTest();
    }
    //V 1.1 Start
     @isTest static void test_teamMember1() {
         Test.startTest();

        User adminUser2 = Utils_TestDataFactory.createUserFull(
                Utils_TestDataFactory.getProfile('Sales Support(HQ)')
                , 'admin222@admin.com'
                , 'admin222_epid1');
        adminUser2.EmployeeNumber = '6754034';
        adminUser2.CompanyCode__c = 'T100';
        update adminUser2;
         Id HQRecId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HQ').getRecordTypeId(); //Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('HQ').getRecordTypeId();
        
        Account acc = new Account( 
            Name = 'Test Account',
            MDGCheck__c = true,
            mDomesticForeign__c = '20'
        );
        insert acc;
        //wrapper insert
        
        //      Id HQRecId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HQ').getRecordTypeId(); //Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('HQ').getRecordTypeId();
        DateTime dt = DateTime.now().addDays(-7);
        
        Organization__c org = new Organization__c(name='SDSAE');
        insert org;
        Opportunity opptyHQ1 = new Opportunity(
            Name = 'Test Opportunity',
            //        RecordTypeId = HQRecId,
            SalesOrganization__c = org.id,
            amount=1356,
            //ProposalPM_User__c = migUser.Id, //Anish v-1.2
            MigData__c = True,  //Anish v-1.2
            //StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today(),
            AccountId = acc.Id,
            cLeadID__c = NULL,
            ownerid = adminUser2.id,
            BO1stRegistrationDate__c = dt,
            StageName = 'Z01'
        );
      //  system.runAs(ulist[0]){
            Company__c cmp = new Company__c(
                Name = 'comp',
                CompanyCode__c = 'T100'
            );
            insert cmp;
            Employee__c emp = new Employee__c(
                Name = 'testUser',
                EvMailAddr__c = 'SysAdminTestuser@samsung.com',
                EvUniqID__c = 'k123456789',
                Knox_Id__c = 'knoxId5',
                EvKostl__c = 'T604-11331'
            );
            insert emp;
            
            CostCenter__c costCenter1 = new CostCenter__c(
                Name                = '기술전략팀(T604-11331)'
                , DeptManager__c    = emp.Id
                , CurrencyIsoCode   = 'KRW'
                , CompanyCode__c    = 'T100'
                , CostCenterName__c = '기술전략팀'
                , Company__c = cmp.Id
                , CostCenter__c     = 'T604-11331'
                , Node1__c          = 'T604'
                , Node2__c          = 'T604SB'
                , Node3__c          = 'T604SB1'
                , Node4__c          = 'T604SB13'
                , Node5__c          = 'T604SB131'
                , ZZCheck__c = true
            );
            insert costCenter1; 
            opptyHQ1.RecordTypeId = HQRecId;
            opptyHQ1.SalesOrganization__c = org.id;
            opptyHQ1.amount=1356;
            opptyHQ1.SalesDepartment__c = costCenter1.Id;
            //opptyHQ1.StageName   ='Identified';
            insert opptyHQ1;
      OpportunityTeamMember  opptyTeamMember = new OpportunityTeamMember(
            OpportunityId = opptyHQ1.Id,
            UserId = adminUser2.Id,
            //Name = 'TestEmp1',
            TeamMemberRole = 'Billing Manager'
        );
		
        insert opptyTeamMember;
         
         Test.stopTest();
     }
    //V 1.1 End
     
}