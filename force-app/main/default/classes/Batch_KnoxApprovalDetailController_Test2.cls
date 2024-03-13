/**
 * @description       : 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-04-05
 * @last modified by  : hj.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2021-01-20   hj.lee@dkbmc.com   Initial Version
**/
@isTest
public class Batch_KnoxApprovalDetailController_Test2 {
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
        approval.MISID__c = 'SDSSFDC2020111617314416055155045';
        approval.syncFlag__c = 'Y';
        approval.Opportunity__c = oppty.Id;
        approval.OpportunityActivity__c = opptyAct_requestResource.Id;
        insert approval;
        
        KnoxApprover__c approver = new KnoxApprover__c();
        approver.KnoxApproval__c = approval.id;
        insert approver;

        KnoxApproval__c approval_copy = new KnoxApproval__c();
        approval_copy.Status__c = '2';
        approval_copy.MISID__c = 'SDSSFDC2020121710344116081688819';
        approval_copy.syncFlag__c = 'N';
        approval_copy.Opportunity__c = oppty.Id;
        approval_copy.OpportunityActivity__c = opptyAct_requestResource.Id;
        approval_copy.OriginKnoxApproval__c = approval.id;
        insert approval_copy;


        KnoxApproval__c approval2 = new KnoxApproval__c();
        approval2.Status__c = '2';
        approval2.MISID__c = 'SDSSFDC2020121710344116081688111';
        approval2.syncFlag__c = 'Y';
        approval2.Opportunity__c = oppty.Id;
        approval2.OpportunityActivity__c = opptyAct_requestResource.Id;
        insert approval2;
        
        KnoxApprover__c approver2 = new KnoxApprover__c();
        approver2.KnoxApproval__c = approval2.id;
        insert approver2;


        KnoxApproval__c approval2_copy = new KnoxApproval__c();
        approval2_copy.Status__c = '2';
        approval2_copy.MISID__c = 'SDSSFDC2020121710344116081688111';
        approval2_copy.syncFlag__c = 'Y';
        approval2_copy.Opportunity__c = oppty.Id;
        approval2_copy.OpportunityActivity__c = opptyAct_requestResource.Id;
        approval2_copy.OriginKnoxApproval__c = approval2.id;
        insert approval2_copy;
    }
    
    //
    private static testMethod void test01() {
        Test.startTest();

        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());
        Database.executeBatch(new Batch_KnoxApprovalDetailController());
        Test.stopTest();
    }
    
    //
    private static testMethod void test02() {
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new KnoxApprovalDetailControllerMock());
        
        Database.executeBatch(new Batch_KnoxApprovalDetailController());
    
        Test.stopTest();
    }
	
    public class KnoxApprovalDetailControllerMock implements HttpCalloutMock{
        public KnoxApprovalDetailControllerMock() { }
    
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
			/*
            {
            result: "fail",
            errorDetail: {
            url: "/approval/api/v2.0/approvals/SDSSFDC2022053023111116539198714/detail",
            errorCode: "APE020",
            errorMessage: "[apInfId] that request process does not exist in mySingle.",
            detailMessages: null
            }
            }
			*/
            
            //String jsonData = ' {"result": "success","data": {"contentsType": "HTML","sbmDt": 20201217041538,"sbmLang": "ko","apInfId": "SDSSFDC2020121713153516081785350","SystemID": null,"notifyOption": 0,"urgYn": "0","docSecuType": "PERSONAL","status": 2,"timeZone": "GMT","subject": "[Salesforce Approval] OPTY 9","aplns": [{"actPrssDt": 20201217041538,"docOpenDt": null,"docArvDt": 20201217041538,"opinion": null,"companyCode": "C60","companyName": "삼성SDS","subOrgCode": null,"subOrgName": null,"departmentCode": "C60AJ384","departmentName": "데이터분석실행그룹(Delivery혁신2)","epId": "M201014061334C60205","emailAddress": "dong00.kim@stage.partner.samsung.com","name": "김동영","titleCode": null,"titleName": null,"seq": 0,"role": 0,"aplnStatsCode": 0,"prxAprYn": "N","dlgAprEpid": null,"arbPmtYn": "N","arbActYn": "N","aplnMdfyPmtYn": "Y","aplnMdfyActYn": "N","contentsMdfyPmtYn": "N","contenstsMdfyActYn": null},{"actPrssDt": null,"docOpenDt": null,"docArvDt": 20201217041538,"opinion": null,"companyCode": "C60","companyName": "삼성SDS","subOrgCode": null,"subOrgName": null,"departmentCode": "C60AJ384","departmentName": "데이터분석실행그룹(Delivery혁신2)","epId": "M200810085139C603253","emailAddress": "yeoguri.kim@stage.partner.samsung.com","name": "김영훈","titleCode": null,"titleName": null,"seq": 1,"role": 1,"aplnStatsCode": 0,"prxAprYn": "N","dlgAprEpid": null,"arbPmtYn": "N","arbActYn": "N","aplnMdfyPmtYn": "Y","aplnMdfyActYn": "N","contentsMdfyPmtYn": "Y","contenstsMdfyActYn": null}]}} ';
            String jsonData = '{"result": "fail","errorDetail": {"url": "/approval/api/v2.0/approvals/SDSSFDC2020111617314416055155045/detail","errorCode": "APE020","errorMessage": "[apInfId] that request process does not exist in mySingle.","detailMessages": null}}';
            response.setBody(jsonData);
            response.setStatusCode(200);
            return response; 
        }
    }
}