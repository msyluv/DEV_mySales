/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-05-12
 * @last modified by  : hj.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   01-21-2021   soohong0.kim@partner.samsung.com   Initial Version
**/
@isTest
public class KnoxApprovalCancelController_Test {

    @TestSetup
    static void setData(){

        Employee__c emp = Utils_TestDataFactory.createEmployee('TestEmp', 'EPID');
        emp.EvEmpNO__c     = '16241';
        emp.EvSapBukrs__c  = 'T100';
        update emp;
        User user1 = Utils_TestDataFactory.createUserFull(Utils_TestDataFactory.getProfile('System Administrator'), emp.EvMailAddr__c, emp.EvUniqID__c);
        
        Employee__c migEmp = Utils_TestDataFactory.createEmployee('TestMigEmp', 'EPIDMIG');

        List<User> migUsers = [SELECT Id FROM User WHERE UserName = 'mig01@samsung.com'];
        User migUser;
        if(migUsers.size() > 0) {
            migUser = migUsers[0];
        } else {
            migUser = Utils_TestDataFactory.createUserFull(Utils_TestDataFactory.getProfile('System Administrator'), 'mig01@samsung.com', migEmp.EvUniqID__c);
        }

        Opportunity oppty = new Opportunity(
			Name = 'Test Opportunity', 
            StageName = 'Z01',
            Type = 'New Business',
            LeadSource = 'Other',
			CloseDate = System.today()
		);
        insert oppty;

        // **************************************************************
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

        KnoxApproval__c approval4 = new KnoxApproval__c(
            Name = 'approval34',
        	Status__c = '4',
        	MISID__c = 'SDSSFDC2020121710344116081688822',
        	syncFlag__c = 'Y',
        	Opportunity__c = oppty.Id,
        	OpportunityActivity__c = opptyAct_requestResource.Id
        );
        insert approval4;

        KnoxApproval__c migApproval = new KnoxApproval__c(
            Name = 'migApproval',
        	Status__c = '4',
        	MISID__c = 'SDSSFDC2020121710344116081688822',
        	syncFlag__c = 'Y',
        	Opportunity__c = oppty.Id,
        	OpportunityActivity__c = opptyAct_requestResource.Id,
            CreatedById = migUser.Id
        );
        insert migApproval;
    }

    private static testMethod void KnoxApprovalCancel_Test1() {
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());
        KnoxApproval__c obj = [select id from KnoxApproval__c where syncFlag__c = 'N' limit 1];
        KnoxApprovalCancelController.initComponent(obj.id);

        Map<String,Object> paramMap = new Map<String,Object>();
        paramMap.put('KnoxApproval', obj);
        paramMap.put('Comments','test');
       
        Test.stopTest();
    }
    
    private static testMethod void KnoxApprovalCancel_Test2() {
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());
        
        KnoxApproval__c obj = [select id from KnoxApproval__c where syncFlag__c = 'Y' limit 1];
        Map<String,Object> paramMap = new Map<String,Object>();
        paramMap.put('KnoxApproval', obj);
        paramMap.put('Comments','test');
        
        KnoxApprovalCancelController.cancelApproval(JSON.serialize(paramMap));
        
        Test.stopTest();
    }

    private static testMethod void KnoxApprovalCancel_ErrorTest() {
        User ur = [SELECT Id FROM User WHERE UserName Like 'TestEmp@%'];
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());
        
        System.runAs(ur) {
            KnoxApproval__c obj = [SELECT id FROM KnoxApproval__c WHERE Name = 'approval3' limit 1];
            KnoxApprovalCancelController.initComponent(obj.id);

            // 진행중이 아닌 경우 Error 
            KnoxApproval__c notInprogressKnoxApp = [SELECT id FROM KnoxApproval__c WHERE Status__c != '1' limit 1];
            KnoxApprovalCancelController.initComponent(notInprogressKnoxApp.id);

            // MIG 데이터인 경우 Error
            KnoxApproval__c migApproval = [SELECT id FROM KnoxApproval__c WHERE CreatedBy.UserName Like 'mig01@samsung.com' limit 1];
            KnoxApprovalCancelController.initComponent(migApproval.id);
        }
        Test.stopTest();
    }
}