/**
 * @description       : 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-02-10
 * @last modified by  : hj.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2021-02-10   hj.lee@dkbmc.com   Initial Version
**/
@isTest
public class KnoxApprovalActivityNewController_Test {

        
    static RecordType RT_OPPTY_HQ;
    static RecordType RT_OPPTY_LOGISTICS;
    static User systemAdminUser;
    static User salesRepHqUser1;
    static User salesRepLogiUser1;
    static Employee__c emp0;
    static Employee__c emp1;
    static Employee__c emp2;
    static Opportunity opptyHQ;
    static Opportunity opptyLogi;
    static Biz_Review__c bizReview;

    static {
        // [Trigger Switch Setting ] Default Org Switch Setup
        TriggerSwitch__c trSwitch_default = new TriggerSwitch__c(
            All__c = true,
            Opportunity__c = true,
            OpportunityActivity__c = true
        );
        insert trSwitch_default;
        
        RT_OPPTY_HQ        = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
        RT_OPPTY_LOGISTICS = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Logistics' Limit 1];
        
        // 임직원 및 User Setting
        emp0 = Utils_TestDataFactory.createEmployee('TestEmp0', 'EPID0');
        systemAdminUser = Utils_TestDataFactory.createUserFull(
                Utils_TestDataFactory.getProfile('System Administrator')
                , emp0.EvMailAddr__c
                , emp0.EvUniqID__c);

        // 임직원 및 User Setting
        emp1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'EPID1');
        salesRepHqUser1 = Utils_TestDataFactory.createUserFull(
                Utils_TestDataFactory.getProfile('Sales Rep.(HQ)')
                , emp1.EvMailAddr__c
                , emp1.EvUniqID__c);

        // 임직원 및 User Setting
        emp2 = Utils_TestDataFactory.createEmployee('TestEmp2', 'EPID2');
        salesRepLogiUser1 = Utils_TestDataFactory.createUserFull(
                Utils_TestDataFactory.getProfile('Sales Rep.(Logi)')
                , emp2.EvMailAddr__c
                , emp2.EvUniqID__c);

        
        Account acc = new Account(Name = 'accTest');
        insert acc;

        MasterActivity__c mastrtAct1_ZP62 = new MasterActivity__c(
                                   transactionName__c=OpportunityActivityHelper.ACT_CODE_REQUEST_COMMITTEE_APPROVAL
                                 , Stage__c='Z01',Order__c=1
                                 , IsRequiredKnoxApproval__c=false
                                 , Position__c='1',IsImportant__c=true,IsRequired__c=true
                                 , ObjectApiName__c='Opportunity',IsActive__c=true,Type__c='HQ');

        insert mastrtAct1_ZP62;
        
        opptyHQ = new Opportunity(Name ='Test' , RecordTypeId = RT_OPPTY_HQ.Id ,AccountId = acc.Id, CloseDate =System.today() ,StageName = 'Z01');
        insert opptyHQ;

        bizReview = new Biz_Review__c(Description__c = 'test', Version__c = 1, Opportunity__c = opptyHQ.Id, Status__c = 'Confirm');
        insert bizReview;
    }
    
    @isTest
    private static void test_HQ_oppty() {
        Test.startTest();
        System.runAs(systemAdminUser){
            
            KnoxApprovalActivityNewController.initComponent(opptyHQ.Id, 'ZPG1');
            KnoxApprovalActivityNewController.initComponent(bizReview.Id, 'ZP62');
        }
        Test.stopTest();
    }


}