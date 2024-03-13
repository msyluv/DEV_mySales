/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-05-21
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   01-05-2021   soohong0.kim@partner.samsung.com   Initial Version
**/

@isTest
public class IF_KnoxApprovalCancelController_Test {
    private static testMethod void IF_KnoxApprovalCancelControllerTest1() {

        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());

        Employee__c emp = Utils_TestDataFactory.createEmployee('TestEmp', 'EPID');
        emp.EvEmpNO__c     = '16241';
        emp.EvSapBukrs__c  = 'T100';
        emp.Knox_Server_Location__c = 'KR';
        update emp;

        Opportunity oppty = new Opportunity(
			Name = 'Test Opportunity', 
            StageName = 'Z01',
            Type = 'New Business',
            LeadSource = 'Other',
			CloseDate = System.today()
		);
        insert oppty;

        Opportunity_Activity__c opptyAct_requestResource = new Opportunity_Activity__c(
            Status__c = 'Not Started',
            WhatId__c = oppty.id,
            TransactionName__c = OpportunityActivityHelper.ACT_CODE_REQUEST_RESOURCES
        );
        insert opptyAct_requestResource;        

        KnoxApproval__c approval = new KnoxApproval__c();
        approval.Status__c = '2';
        approval.MISID__c = 'SDSSFDC2020121710344116081688819';
        approval.syncFlag__c = 'N';
        approval.Opportunity__c = oppty.Id;
        approval.OpportunityActivity__c = opptyAct_requestResource.Id;
        insert approval;
        
        KnoxApprover__c approver = new KnoxApprover__c();
        approver.KnoxApproval__c = approval.id;
        approver.ApproverType__c = '0';
        approver.Employee__c     = emp.Id;
        insert approver;
                
        IF_KnoxApprovalCancelController.InputClass input = new IF_KnoxApprovalCancelController.InputClass();
        input.apInfId = approval.MISID__c;
        input.opinion = 'test';
  
        Test.stopTest();


        Map<String, Object> returnMap = IF_KnoxApprovalCancelController.approvalCancel(input);
        Integer statusCode   = Util_String.nvlInt( returnMap.get( 'StatusCode'));
        System.assertEquals( statusCode, 200);
    }
}