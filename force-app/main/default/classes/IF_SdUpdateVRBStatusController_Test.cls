/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 2022-10-26
 * @last modified by  : Kajal.c@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   07-21-2021   ukhyeon.lee@samsung.com   Initial Version
 * 1.1   2022-10-26   Kajal.c@samsung.com 	    Add IV_VRB_TYPE value to store in 'Opportunity_Review_VRB_Type__c' 
 *                                              opportunity field. 
**/
@isTest
public class IF_SdUpdateVRBStatusController_Test {
    final static String REQUEST_URL = '/services/apexrest/WebService/IF144';
    static Opportunity oppty;
    public static Opportunity hqOpportunity;
    static Opportunity_Activity__c opptyAct = new Opportunity_Activity__c();
    static Account acc;
    @TestSetup
    static void setData(){

        Map<String,String> pickMap = new Map<String,String>();
        acc = Utils_TestDataFactory.createAccount('TestAcc');
        acc.AccountNumber = 'A2222233';
        acc.MDGCheck__c = true;
        update acc;

        hqOpportunity = new Opportunity(
            Name = 'test',
            CurrencyIsoCode='EUR',
            OpportunityCode__c='SDS-123123',
            StageName= 'stage1',
            BusinessType__c='TI',
            CloseDate = System.today(),            
            Opportunity_Review_Checkbox1__c=false,
            Opportunity_Review_Checkbox2__c=false,
            Opportunity_Review_Consortium__c=false,
            Opportunity_Review_Exception__c=false,            
            Opportunity_Review_VRB_Type__c='10'
        );

        insert hqOpportunity;
        
        Company__c hqc = new Company__c();
        hqc.CompanyCode__c = 'T100';
        hqc.Name = 'hq';
        insert hqc;

        Company__c subsc = new Company__c();
        subsc.CompanyCode__c = 'T810';
        subsc.Name = 'subsc';
        insert subsc;

        CostCenter__c hqCenter = new CostCenter__c();
        hqCenter.CostCenter__c = 'test12';
        hqCenter.Company__c = hqc.id;
        insert hqCenter;
        
        CostCenter__c subsCenter = new CostCenter__c();
        subsCenter.CostCenter__c = 'test13';
        subsCenter.Company__c = subsc.id;
        insert subsCenter;

        hqOpportunity.SalesDepartment__c =hqCenter.id;
        update hqOpportunity;


        pickMap = Utils.getPicklistOptionType('Opportunity_Activity__c','TransactionName__c')[0];
        opptyAct.WhatId__c = hqOpportunity.id;
        opptyAct.TransactionName__c = 'XP63';
        opptyAct.ExtId__c = hqOpportunity.id + '_'+pickMap.get('value');
        opptyAct.StartDate__c = Date.today();
        opptyAct.EndDate__c = Date.today();
        opptyAct.DueDate__c = Date.today();
        insert opptyAct;

    }


    @isTest
    static void restServiceTest() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        Opportunity tmpOppty = [SELECT Id, OpportunityCode__c, CompanyCode__c FROM Opportunity ];

       
        IF_SdUpdateVRBStatusController.InputHeader input = new IF_SdUpdateVRBStatusController.InputHeader();        
        input.IV_ZZORDER_ID = tmpOppty.OpportunityCode__c;
        input.IV_BUKRS = tmpOppty.CompanyCode__c;
        input.IV_VERSION = 'XP63';
        input.VRB_APPROVAL_TYPE = '10';
        input.VRB_NEW = '';

        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateVRBStatusController.doPost();

        Test.stopTest();
    }

    @isTest
    static void restServiceTest2() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        Opportunity tmpOppty = [SELECT Id, OpportunityCode__c, CompanyCode__c FROM Opportunity ];

       
        IF_SdUpdateVRBStatusController.InputHeader input = new IF_SdUpdateVRBStatusController.InputHeader();        
        input.IV_ZZORDER_ID = tmpOppty.OpportunityCode__c;
        input.IV_BUKRS = tmpOppty.CompanyCode__c;
        input.IV_VERSION = 'XP63';
        input.VRB_APPROVAL_TYPE = '30';
        input.VRB_NEW = '';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateVRBStatusController.doPost();

        Test.stopTest();
    }

    @isTest
    static void restServiceTest3() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        Opportunity tmpOppty = [SELECT Id, OpportunityCode__c, CompanyCode__c FROM Opportunity ];

       
        IF_SdUpdateVRBStatusController.InputHeader input = new IF_SdUpdateVRBStatusController.InputHeader();        
        input.IV_ZZORDER_ID = tmpOppty.OpportunityCode__c;
        input.IV_BUKRS = tmpOppty.CompanyCode__c;
        input.IV_VERSION = 'XP63';
        input.VRB_APPROVAL_TYPE = '10';
        input.VRB_NEW = 'Y';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateVRBStatusController.doPost();

        Test.stopTest();
    }

    @isTest
    static void restServiceTest4() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        Opportunity tmpOppty = [SELECT Id, OpportunityCode__c, CompanyCode__c FROM Opportunity ];

       
        IF_SdUpdateVRBStatusController.InputHeader input = new IF_SdUpdateVRBStatusController.InputHeader();        
        input.IV_ZZORDER_ID = tmpOppty.OpportunityCode__c;
        input.IV_BUKRS = tmpOppty.CompanyCode__c;
        input.IV_VERSION = 'XP73';
        input.VRB_APPROVAL_TYPE = '10';
        input.VRB_NEW = '';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateVRBStatusController.doPost();

        Test.stopTest();
    }

    @isTest
    static void restServiceTest5() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        Opportunity tmpOppty = [SELECT Id, OpportunityCode__c, CompanyCode__c FROM Opportunity ];

       
        IF_SdUpdateVRBStatusController.InputHeader input = new IF_SdUpdateVRBStatusController.InputHeader();        
        input.IV_ZZORDER_ID = tmpOppty.OpportunityCode__c;
        input.IV_BUKRS = tmpOppty.CompanyCode__c;
        input.IV_VERSION = 'XP73';
        input.VRB_APPROVAL_TYPE = '30';
        input.VRB_NEW = '';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateVRBStatusController.doPost();

        Test.stopTest();
    }

    @isTest
    static void restServiceTest6() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        Opportunity tmpOppty = [SELECT Id, OpportunityCode__c, CompanyCode__c FROM Opportunity ];

       
        IF_SdUpdateVRBStatusController.InputHeader input = new IF_SdUpdateVRBStatusController.InputHeader();        
        input.IV_ZZORDER_ID = tmpOppty.OpportunityCode__c;
        input.IV_BUKRS = tmpOppty.CompanyCode__c;
        input.IV_VERSION = 'XP73';
        input.VRB_APPROVAL_TYPE = '10';
        input.VRB_NEW = 'Y';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateVRBStatusController.doPost();

        Test.stopTest();
    }


    @isTest
    static void restServiceTest7() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        Opportunity tmpOppty = [SELECT Id, OpportunityCode__c, CompanyCode__c FROM Opportunity ];

       
        IF_SdUpdateVRBStatusController.InputHeader input = new IF_SdUpdateVRBStatusController.InputHeader();        
        input.IV_ZZORDER_ID = tmpOppty.OpportunityCode__c;
        input.IV_BUKRS = tmpOppty.CompanyCode__c;
        input.IV_VERSION = 'XP63';
        input.VRB_APPROVAL_TYPE = '10';
        input.REQ_DATE = '20201122';
        input.CONDUCT_DATE = '20220202';
        input.RFP_ANNOUNCE_DATE = '20220202';
        input.PROPOSAL_SUBMIT_DATE = '20220202';
        input.BO_OVERVIEW = '20220202';
        input.VRB_NEW = '';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateVRBStatusController.doPost();

        Test.stopTest();
    }

     @isTest
    static void restServiceTest8() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        Opportunity tmpOppty = [SELECT Id, OpportunityCode__c, CompanyCode__c FROM Opportunity ];

       
        IF_SdUpdateVRBStatusController.InputHeader input = new IF_SdUpdateVRBStatusController.InputHeader();        
        input.IV_ZZORDER_ID = tmpOppty.OpportunityCode__c;
        input.IV_BUKRS = tmpOppty.CompanyCode__c;
        input.IV_VERSION = 'XP63';
        input.VRB_APPROVAL_TYPE = '10';
        input.REQ_DATE = '20201122';
        input.CHK_DATE = '20201122';
        input.CONDUCT_DATE = '20220202';
        input.RFP_ANNOUNCE_DATE = '20220202';
        input.PROPOSAL_SUBMIT_DATE = '20220202';
        input.BO_OVERVIEW = '20220202';
        input.VRB_NEW = '';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateVRBStatusController.doPost();

        Test.stopTest();
    }

     @isTest
    static void restServiceTest9() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        Opportunity tmpOppty = [SELECT Id, OpportunityCode__c, CompanyCode__c FROM Opportunity ];

       
        IF_SdUpdateVRBStatusController.InputHeader input = new IF_SdUpdateVRBStatusController.InputHeader();        
        input.IV_ZZORDER_ID = tmpOppty.OpportunityCode__c;
        input.IV_BUKRS = tmpOppty.CompanyCode__c;
        input.IV_VERSION = 'XP63';
        input.VRB_APPROVAL_TYPE = '10';
        input.REQ_DATE = '20201122';
        input.CHK_DATE = '20201122';
        input.COST_DATE = '20201122';
        input.CONDUCT_DATE = '20220202';
        input.RFP_ANNOUNCE_DATE = '20220202';
        input.PROPOSAL_SUBMIT_DATE = '20220202';
        input.BO_OVERVIEW = '20220202';
        input.VRB_NEW = '';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateVRBStatusController.doPost();

        Test.stopTest();
    }

     @isTest
    static void restServiceTest10() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        Opportunity tmpOppty = [SELECT Id, OpportunityCode__c, CompanyCode__c FROM Opportunity ];

       
        IF_SdUpdateVRBStatusController.InputHeader input = new IF_SdUpdateVRBStatusController.InputHeader();        
        input.IV_ZZORDER_ID = tmpOppty.OpportunityCode__c;
        input.IV_BUKRS = tmpOppty.CompanyCode__c;
        input.IV_VERSION = 'XP63';
        input.VRB_APPROVAL_TYPE = '10';
        input.REQ_DATE = '20201122';
        input.CHK_DATE = '20201122';
        input.COST_DATE = '20201122';
        input.APPR_DATE = '20201122';
        input.CONDUCT_DATE = '20220202';
        input.RFP_ANNOUNCE_DATE = '20220202';
        input.PROPOSAL_SUBMIT_DATE = '20220202';
        input.BO_OVERVIEW = '20220202';
        input.VRB_NEW = '';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateVRBStatusController.doPost();

        Test.stopTest();
    }

        @isTest
    static void restServiceTest11() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        Opportunity tmpOppty = [SELECT Id, OpportunityCode__c, CompanyCode__c FROM Opportunity ];

       
        IF_SdUpdateVRBStatusController.InputHeader input = new IF_SdUpdateVRBStatusController.InputHeader();        
        input.IV_ZZORDER_ID = tmpOppty.OpportunityCode__c;
        input.IV_BUKRS = tmpOppty.CompanyCode__c;
        input.IV_VERSION = 'XP63';
        input.VRB_APPROVAL_TYPE = '10';
        input.REQ_DATE = '20201122';
        input.CHK_DATE = '20201122';
        input.COST_DATE = '20201122';
        input.APPR_DATE = '20201122';
        input.CONDUCT_DATE = '20220202';
        input.RFP_ANNOUNCE_DATE = '20220202';
        input.PROPOSAL_SUBMIT_DATE = '20220202';
        input.BO_OVERVIEW = '20220202';
        input.VRB_NEW = 'Y';
        input.IV_VRB_TYPE = '10';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateVRBStatusController.doPost();

        Test.stopTest();
    }

    @isTest
    static void restServiceTest12() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        Opportunity tmpOppty = [SELECT Id, OpportunityCode__c, CompanyCode__c FROM Opportunity ];

       
        IF_SdUpdateVRBStatusController.InputHeader input = new IF_SdUpdateVRBStatusController.InputHeader();        
        input.IV_ZZORDER_ID = tmpOppty.OpportunityCode__c;
        input.IV_BUKRS = tmpOppty.CompanyCode__c;
        input.IV_VERSION = 'XP73';
        input.VRB_APPROVAL_TYPE = '10';
        input.REQ_DATE = '20201122';
        input.CHK_DATE = '20201122';
        input.COST_DATE = '20201122';
        input.APPR_DATE = '20201122';
        input.CONDUCT_DATE = '20220202';
        input.RFP_ANNOUNCE_DATE = '20220202';
        input.PROPOSAL_SUBMIT_DATE = '20220202';
        input.BO_OVERVIEW = '20220202';
        input.VRB_NEW = 'Y';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateVRBStatusController.doPost();

        Test.stopTest();
    }


    @isTest
    static void errorTest01() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        Opportunity tmpOppty = [SELECT Id, OpportunityCode__c, CompanyCode__c FROM Opportunity ];

       
        IF_SdUpdateVRBStatusController.InputHeader input = new IF_SdUpdateVRBStatusController.InputHeader();        
        input.IV_ZZORDER_ID = '';
        input.IV_BUKRS = tmpOppty.CompanyCode__c;
        input.IV_VERSION = 'XP73';
        input.VRB_APPROVAL_TYPE = '10';
        input.REQ_DATE = '20201122';
        input.CHK_DATE = '20201122';
        input.COST_DATE = '20201122';
        input.APPR_DATE = '20201122';
        input.CONDUCT_DATE = '20220202';
        input.RFP_ANNOUNCE_DATE = '20220202';
        input.PROPOSAL_SUBMIT_DATE = '20220202';
        input.BO_OVERVIEW = '20220202';
        input.VRB_NEW = 'Y';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateVRBStatusController.doPost();

        Test.stopTest();
    }


     @isTest
    static void errorTest02() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        Opportunity tmpOppty = [SELECT Id, OpportunityCode__c, CompanyCode__c FROM Opportunity ];

       
        IF_SdUpdateVRBStatusController.InputHeader input = new IF_SdUpdateVRBStatusController.InputHeader();        
        input.IV_ZZORDER_ID = tmpOppty.OpportunityCode__c;
        //input.IV_BUKRS = tmpOppty.CompanyCode__c;
        input.IV_BUKRS = '';
        input.IV_VERSION = 'XP73';
        input.VRB_APPROVAL_TYPE = '10';
        input.REQ_DATE = '20201122';
        input.CHK_DATE = '20201122';
        input.COST_DATE = '20201122';
        input.APPR_DATE = '20201122';
        input.CONDUCT_DATE = '20220202';
        input.RFP_ANNOUNCE_DATE = '20220202';
        input.PROPOSAL_SUBMIT_DATE = '20220202';
        input.BO_OVERVIEW = '20220202';
        input.VRB_NEW = 'Y';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateVRBStatusController.doPost();

        Test.stopTest();
    }

     @isTest
    static void errorTest03() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        Opportunity tmpOppty = [SELECT Id, OpportunityCode__c, CompanyCode__c FROM Opportunity ];

       
        IF_SdUpdateVRBStatusController.InputHeader input = new IF_SdUpdateVRBStatusController.InputHeader();        
        input.IV_ZZORDER_ID = tmpOppty.OpportunityCode__c;
        input.IV_BUKRS = tmpOppty.CompanyCode__c;
        input.IV_VERSION = '';
        //input.IV_VERSION = 'XP73';
        input.VRB_APPROVAL_TYPE = '10';
        input.REQ_DATE = '20201122';
        input.CHK_DATE = '20201122';
        input.COST_DATE = '20201122';
        input.APPR_DATE = '20201122';
        input.CONDUCT_DATE = '20220202';
        input.RFP_ANNOUNCE_DATE = '20220202';
        input.PROPOSAL_SUBMIT_DATE = '20220202';
        input.BO_OVERVIEW = '20220202';
        input.VRB_NEW = 'Y';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateVRBStatusController.doPost();

        Test.stopTest();
    }

     @isTest
    static void errorTest04() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        Opportunity tmpOppty = [SELECT Id, OpportunityCode__c, CompanyCode__c FROM Opportunity ];

       
        IF_SdUpdateVRBStatusController.InputHeader input = new IF_SdUpdateVRBStatusController.InputHeader();        
        input.IV_ZZORDER_ID = tmpOppty.OpportunityCode__c;
        input.IV_BUKRS = tmpOppty.CompanyCode__c;
        input.IV_VERSION = 'XP74';
        input.VRB_APPROVAL_TYPE = '10';
        input.REQ_DATE = '20201122';
        input.CHK_DATE = '20201122';
        input.COST_DATE = '20201122';
        input.APPR_DATE = '20201122';
        input.CONDUCT_DATE = '20220202';
        input.RFP_ANNOUNCE_DATE = '20220202';
        input.PROPOSAL_SUBMIT_DATE = '20220202';
        input.BO_OVERVIEW = '20220202';
        input.VRB_NEW = 'Y';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateVRBStatusController.doPost();

        Test.stopTest();
    }

        @isTest
    static void errorTest05() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        Opportunity tmpOppty = [SELECT Id, OpportunityCode__c, CompanyCode__c FROM Opportunity ];

       
        IF_SdUpdateVRBStatusController.InputHeader input = new IF_SdUpdateVRBStatusController.InputHeader();        
        input.IV_ZZORDER_ID = tmpOppty.OpportunityCode__c;
        input.IV_BUKRS = tmpOppty.CompanyCode__c;
        input.IV_VERSION = 'XP73';
        input.VRB_APPROVAL_TYPE = '10';
        input.REQ_DATE = '2020112';
        input.CHK_DATE = '20201122';
        input.COST_DATE = '20201122';
        input.APPR_DATE = '20201122';
        input.CONDUCT_DATE = '20220202';
        input.RFP_ANNOUNCE_DATE = '20220202';
        input.PROPOSAL_SUBMIT_DATE = '20220202';
        input.BO_OVERVIEW = '20220202';
        input.VRB_NEW = 'Y';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateVRBStatusController.doPost();

        Test.stopTest();
    }
    
    @isTest
    static void errorTest06() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        Opportunity tmpOppty = [SELECT Id, OpportunityCode__c, CompanyCode__c FROM Opportunity ];

       
        IF_SdUpdateVRBStatusController.InputHeader input = new IF_SdUpdateVRBStatusController.InputHeader();        
        input.IV_ZZORDER_ID = tmpOppty.OpportunityCode__c;
        input.IV_BUKRS = tmpOppty.CompanyCode__c;
        input.IV_VERSION = 'XP73';
        input.VRB_APPROVAL_TYPE = '10';
        input.REQ_DATE = '20201122';
        input.CHK_DATE = '2020112';
        input.COST_DATE = '20201122';
        input.APPR_DATE = '20201122';
        input.CONDUCT_DATE = '20220202';
        input.RFP_ANNOUNCE_DATE = '20220202';
        input.PROPOSAL_SUBMIT_DATE = '20220202';
        input.BO_OVERVIEW = '20220202';
        input.VRB_NEW = 'Y';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateVRBStatusController.doPost();

        Test.stopTest();
    }
    @isTest
    static void errorTest07() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        Opportunity tmpOppty = [SELECT Id, OpportunityCode__c, CompanyCode__c FROM Opportunity ];

       
        IF_SdUpdateVRBStatusController.InputHeader input = new IF_SdUpdateVRBStatusController.InputHeader();        
        input.IV_ZZORDER_ID = tmpOppty.OpportunityCode__c;
        input.IV_BUKRS = tmpOppty.CompanyCode__c;
        input.IV_VERSION = 'XP73';
        input.VRB_APPROVAL_TYPE = '10';
        input.REQ_DATE = '20201122';
        input.CHK_DATE = '20201122';
        input.COST_DATE = '2020112';
        input.APPR_DATE = '20201122';
        input.CONDUCT_DATE = '20220202';
        input.RFP_ANNOUNCE_DATE = '20220202';
        input.PROPOSAL_SUBMIT_DATE = '20220202';
        input.BO_OVERVIEW = '20220202';
        input.VRB_NEW = 'Y';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateVRBStatusController.doPost();

        Test.stopTest();
    }
    @isTest
    static void errorTest08() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        Opportunity tmpOppty = [SELECT Id, OpportunityCode__c, CompanyCode__c FROM Opportunity ];

       
        IF_SdUpdateVRBStatusController.InputHeader input = new IF_SdUpdateVRBStatusController.InputHeader();        
        input.IV_ZZORDER_ID = tmpOppty.OpportunityCode__c;
        input.IV_BUKRS = tmpOppty.CompanyCode__c;
        input.IV_VERSION = 'XP73';
        input.VRB_APPROVAL_TYPE = '10';
        input.REQ_DATE = '20201122';
        input.CHK_DATE = '20201122';
        input.COST_DATE = '20201122';
        input.APPR_DATE = '2020112';
        input.CONDUCT_DATE = '20220202';
        input.RFP_ANNOUNCE_DATE = '20220202';
        input.PROPOSAL_SUBMIT_DATE = '20220202';
        input.BO_OVERVIEW = '20220202';
        input.VRB_NEW = 'Y';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateVRBStatusController.doPost();

        Test.stopTest();
    }
    @isTest
    static void errorTest09() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        Opportunity tmpOppty = [SELECT Id, OpportunityCode__c, CompanyCode__c FROM Opportunity ];

       
        IF_SdUpdateVRBStatusController.InputHeader input = new IF_SdUpdateVRBStatusController.InputHeader();        
        input.IV_ZZORDER_ID = tmpOppty.OpportunityCode__c;
        input.IV_BUKRS = tmpOppty.CompanyCode__c;
        input.IV_VERSION = 'XP73';
        input.VRB_APPROVAL_TYPE = '11';
        input.REQ_DATE = '20201122';
        input.CHK_DATE = '20201122';
        input.COST_DATE = '20201122';
        input.APPR_DATE = '20201122';
        input.CONDUCT_DATE = '20220202';
        input.RFP_ANNOUNCE_DATE = '20220202';
        input.PROPOSAL_SUBMIT_DATE = '20220202';
        input.BO_OVERVIEW = '20220202';
        input.VRB_NEW = 'Y';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateVRBStatusController.doPost();

        Test.stopTest();
    }
    @isTest
    static void errorTest10() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        Opportunity tmpOppty = [SELECT Id, OpportunityCode__c, CompanyCode__c FROM Opportunity ];

       
        IF_SdUpdateVRBStatusController.InputHeader input = new IF_SdUpdateVRBStatusController.InputHeader();        
        input.IV_ZZORDER_ID = tmpOppty.OpportunityCode__c;
        input.IV_BUKRS = tmpOppty.CompanyCode__c;
        input.IV_VERSION = 'XP73';
        input.VRB_APPROVAL_TYPE = '';
        input.REQ_DATE = '20201122';
        input.CHK_DATE = '2020112';
        input.COST_DATE = '20201122';
        input.APPR_DATE = '20201122';
        input.CONDUCT_DATE = '20220202';
        input.RFP_ANNOUNCE_DATE = '20220202';
        input.PROPOSAL_SUBMIT_DATE = '20220202';
        input.BO_OVERVIEW = '20220202';
        input.VRB_NEW = 'Y';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateVRBStatusController.doPost();

        Test.stopTest();
    }
}