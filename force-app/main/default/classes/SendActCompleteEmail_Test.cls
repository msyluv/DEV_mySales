/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2022-02-17
 * @last modified by  : seonju.jin@dkbmc.com
**/
@isTest
public class SendActCompleteEmail_Test {
    @TestSetup
    static void setData(){

        Opportunity oppty = new Opportunity(
			Name = 'Test Opportunity', 
            StageName = 'Z01',
            Type = 'New Business',
            LeadSource = 'Other',
			CloseDate = System.today()
		);
        insert oppty;

        // *******************************************
        // OppoActivity 
        // **************************************************************

        // Request Resource
        Opportunity_Activity__c opptyAct_requestResource = new Opportunity_Activity__c(
            Status__c = 'Not Started',
            WhatId__c = oppty.id,
            TransactionName__c = OpportunityActivityHelper.ACT_CODE_REQUEST_RESOURCES
        );
        insert opptyAct_requestResource;


        Project__c project = new Project__c(
            Opportunity__c =  oppty.Id,
            Name = 'Test2',
            Description__c = 'Test2',
            ProjectCode__c = 'testProject002'
        );
        insert project;

        KnoxApproval__c approval = new KnoxApproval__c();
        approval.Status__c = '1';
        approval.MISID__c = 'SDSSFDC2020121710344116081688819';
        approval.syncFlag__c = 'N';
        approval.Opportunity__c = oppty.Id;
        approval.OpportunityActivity__c = opptyAct_requestResource.Id;
        insert approval;
        
        /**
         * Knox Approver
         */
        Employee__c emp1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'EPID1');
        KnoxApprover__c knoxApprover1 = new KnoxApprover__c(
            KnoxApproval__c = approval.Id,
            Index__c = 0,
            Name = 'test1',
            ApproverType__c = '0',
            EvSdeptNM__c = '개발',
            EvMailAddr__c = emp1.EvMailAddr__c,
            Employee__c = emp1.Id,
            EvUniqID__c = emp1.EvUniqID__c,
            IsChangeLine__c = true,
            IsEditText__c = true,
            IsArbitraryDecision__c = true
        );
        insert knoxApprover1;
        
        
        KnoxApproval__c approval2 = new KnoxApproval__c(
            Name = 'approval2',
        	Status__c = '1',
        	MISID__c = 'SDSSFDC2020121710344116081688820',
        	syncFlag__c = 'Y',
        	Opportunity__c = oppty.Id,
        	OpportunityActivity__c = opptyAct_requestResource.Id
        );
        insert approval2;

        KnoxApproval__c approval_copy = approval.clone(false, true, false);
        approval_copy.id = null;
        approval_copy.OriginKnoxApproval__c = approval.Id;
        insert approval_copy;

        KnoxApproval__c approval_copy2 = approval2.clone(false, true, false);
        approval_copy2.id = null;
        approval_copy2.syncFlag__c = 'Y';
        approval_copy2.OriginKnoxApproval__c = approval2.Id;
        insert approval_copy2;

        KnoxApproval__c approval3 = new KnoxApproval__c(
            Name = 'approval3',
        	Status__c = '1',
        	MISID__c = 'SDSSFDC2020121710344116081688821',
        	syncFlag__c = 'Y',
        	Opportunity__c = oppty.Id,
        	OpportunityActivity__c = opptyAct_requestResource.Id
        );
        insert approval3;
    }
    
    @IsTest
    static void testmethod_01(){
        Test.startTest();
        List<KnoxApproval__c> objList = [SELECT Id FROM KnoxApproval__c];
        Set<Id> knoxApprovalIdSet = new Set<Id>();
        for(KnoxApproval__c obj : objList){
            KnoxApprovalIdSet.add(obj.Id);
        }
        SendActCompleteEmail.sendKnoxMail(KnoxApprovalIdSet);
        Test.stopTest();
        
    }
}