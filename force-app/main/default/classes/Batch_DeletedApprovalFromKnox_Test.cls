@isTest
public class Batch_DeletedApprovalFromKnox_Test {
    
    static Profile pf = [SELECT Id FROM Profile WHERE Name Like '%System Admin%' or Name Like '시스템 관리자' limit 1];

    @TestSetup
    static void setData(){

        User user1 = new User(
            Alias = 'testUser',
            Email='SysAdminTestuser@dkbmc.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            EmployeeNumber='AC100000',
            TimeZoneSidKey='Asia/Seoul',
            UserName='SysAdminTestuser@samsung.com',
            ProfileId = pf.Id,
            FederationIdentifier = 'k123456789'
        );
        insert user1;

        Employee__c emp1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'EPID1');

        // [Account]
        Account acc = Utils_TestDataFactory.createAccount('TestAccount');
        acc.MDGCheck__c = true;
        update acc;

        // [Opportunity]
		Opportunity opp = Utils_TestDataFactory.createOpportunity('TestOpportunity', acc.Id);
        opp.ownerId = user1.id;

        Opportunity opp_collabo = Utils_TestDataFactory.createOpportunity('TestOpportunity Collabo', acc.Id);
        opp.CollaborationBOId__c = opp_collabo.Id;
        opp.CollaborationInOut__c = 'Out';
        update opp;

        Opportunity_Activity__c opptyAct = new Opportunity_Activity__c( 
            Status__c            = OpportunityActivityNewController.OPPTYACT_STATUS_COMPLETED
            , DueDate__c         = System.today()
            , TransactionName__c = OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL
            , WhatId__c          = opp.Id 
        );
        opptyAct.ExtId__c = OpportunityActivityHelper.generateOpportunityActivityExtKey(opptyAct);
        insert  opptyAct;

        KnoxApproval__c approval = new KnoxApproval__c();
        approval.Status__c = '1';
        approval.MISID__c = 'SDSSFDC2020111617314416055155045';
        approval.syncFlag__c = 'Y';
        approval.Opportunity__c = opp.Id;
        approval.OpportunityActivity__c = opptyAct.Id;
        approval.CreatedDate = Date.today().addDays(-40);
        insert approval;
        
        KnoxApprover__c approver = new KnoxApprover__c();
        approver.KnoxApproval__c = approval.id;
        insert approver;
        
    }
    private static testMethod void test01() {
        Test.startTest();

        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());
        Database.executeBatch(new Batch_DeletedApprovalFromKnoxController(), 20);        
        Test.stopTest();
    }

}