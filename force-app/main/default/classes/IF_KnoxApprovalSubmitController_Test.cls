/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-05-21
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   01-07-2021   soohong0.kim@partner.samsung.com   Initial Version
**/
@isTest
public class IF_KnoxApprovalSubmitController_Test {

    private static testMethod void IF_KnoxApprovalSubmitControllerTest() {

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

        IF_KnoxApprovalSubmitController.InputClass input = new IF_KnoxApprovalSubmitController.InputClass();

        input.contents      = 'test';
        input.contentsType  = 'test';
        input.docSecuType   = 'test';
        input.notifyOption  = 'test';
        input.urgYn         = 'Y';
        input.sbmDt         = 'test';
        input.timeZone      = 'test';
        input.docMngSaveCode= 'test';
        input.subject       = 'test';
        input.sbmLang       = 'test';
        input.importantYn   = 'Y';
        input.apInfId       = approval.MISID__c;
        
        List<IF_KnoxApprovalSubmitController.Aplns> aplnsList = new List<IF_KnoxApprovalSubmitController.Aplns>();
        aplnsList.add(new IF_KnoxApprovalSubmitController.Aplns('test','test','test','test','test','test','test','test','test','test'));
        input.aplns = aplnsList;

        List<IF_KnoxApprovalSubmitController.Attachments> attachList = new List<IF_KnoxApprovalSubmitController.Attachments>();
        attachList.add(new IF_KnoxApprovalSubmitController.Attachments('test','test','test'));
        input.attachments = attachList;
      
        Test.stopTest();


        Map<String, Object> returnMap = IF_KnoxApprovalSubmitController.approvalSubmit(input);
        Integer statusCode   = Util_String.nvlInt( returnMap.get( 'StatusCode'));
        System.assertEquals( statusCode, 200);        
    }
}