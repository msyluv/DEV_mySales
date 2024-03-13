/**
* @description       : 
* @author            : Kajal.c@samsung.com
* @group             : 
* @last modified on  : 2022-11-2
* @last modified by  : Kajal.c@samsung.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   2022-11-2   Kajal.c@samsung.com     Initial Version 
**/

@isTest
public class IF_CelloCallinAPIControllerTest {
    final static String REQUEST_URL = '/services/apexrest/WebService/IF170';
    static Opportunity oppty;
    public static Opportunity LogiOpportunity;
    public static Opportunity LogiOpportunity1;
    @TestSetup
    static void setData(){
        Account acc = new Account (
        Name = 'Test1234');
        Organization__c org = new Organization__c();
        insert org;
        LogiOpportunity = new Opportunity(
            Name = 'MySales',
            Type = 'New Opportunity',
            CurrencyIsoCode='EUR',
            OpportunityCode__c='SDS-22131801',
            StageName= 'Qualified',
            LogisticsBizDevelopmentType__c = '01',
            Amount = 78,
            BiddingDeadline__c = System.today() + 30,
            //LogisticsServiceType__c = '01',
            LogisticsBizType__c = '02',
            cRevenueStartDate__c = System.today() - 10,
            cRevenueEndDate__c = System.today() + 10,
            AccountId = acc.id,
            LogisticsCustomerType__c = 'SECSET',
            SubIndusrty__c = '01',
            SalesOrganization__c = org.id,
            DeliveryOrganization__c = org.id,
            CloseDate = System.today()
            );
        
        insert LogiOpportunity;
        Opportunity_Activity__c Oppact =new Opportunity_Activity__c(
        WhatId__c = LogiOpportunity.id,
        StartDate__c = null,    
        Status__c = null,
        TransactionName__c = '2.3.1'
        );
        insert Oppact;
        Opportunity_Activity__c Oppact1 =new Opportunity_Activity__c(
        WhatId__c = LogiOpportunity.id,
        StartDate__c = null,    
        Status__c = null,
        TransactionName__c = '2.4.4'
        );
        insert Oppact1;

        LogiOpportunity1 = new Opportunity(
            Name = 'MySales3',
            Type = 'New Opportunity',
            CurrencyIsoCode='EUR',
            OpportunityCode__c='SDS-22131802',
            StageName= 'Qualified',
            LogisticsBizDevelopmentType__c = '01',
            Amount = 78,
            BiddingDeadline__c = System.today() + 30,
            //LogisticsServiceType__c = '01',
            LogisticsBizType__c = '02',
            cRevenueStartDate__c = System.today() - 10,
            cRevenueEndDate__c = System.today() + 10,
            AccountId = acc.id,
            LogisticsCustomerType__c = 'SECSET',
            SubIndusrty__c = '01',
            SalesOrganization__c = org.id,
            DeliveryOrganization__c = org.id,
            CloseDate = System.today()
            );
        
        insert LogiOpportunity1;
        
    }

      @IsTest
       static void restServiceCatchTestBID() {
        Test.startTest();
        oppty = [Select ID,OpportunityCode__c from opportunity limit 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        IF_CelloCallinAPIController.InputHeader input = new IF_CelloCallinAPIController.InputHeader();        
        input.BO_CODE = oppty.OpportunityCode__c;
        input.LOGI_CP_ID = '123AB';
        input.LOGI_CP_CCD ='BID';
        input.LOGI_CP_SCD = 'SAVE';
        input.LOGI_CP_RV_SCD = 'A';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_CelloCallinAPIController.doPost();
        Test.stopTest();
    }
    
    @IsTest
       static void restServiceCatchTestFIN() {
        Test.startTest();
        oppty = [Select ID,OpportunityCode__c from opportunity limit 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        IF_CelloCallinAPIController.InputHeader input = new IF_CelloCallinAPIController.InputHeader();        
        input.BO_CODE = oppty.OpportunityCode__c;
        input.LOGI_CP_ID = '123AB';
        input.LOGI_CP_CCD ='FIN';
        input.LOGI_CP_SCD = 'CNFM';
        input.LOGI_CP_RV_SCD = 'R';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_CelloCallinAPIController.doPost();
        Test.stopTest();
    }
    @IsTest
       static void restServiceCatchTestBID1() {
        Test.startTest();
        oppty = [Select ID,OpportunityCode__c from opportunity limit 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        IF_CelloCallinAPIController.InputHeader input = new IF_CelloCallinAPIController.InputHeader();        
        input.BO_CODE = oppty.OpportunityCode__c;
        input.LOGI_CP_ID = '123ABC';
        input.LOGI_CP_CCD ='BID';
        input.LOGI_CP_SCD = 'CNFM';
        input.LOGI_CP_RV_SCD = 'A';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_CelloCallinAPIController.doPost();
        Test.stopTest();
    }
    
   @IsTest
       static void restServiceCatchTestFIN1() {
        Test.startTest();
        oppty = [Select ID,OpportunityCode__c from opportunity limit 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        IF_CelloCallinAPIController.InputHeader input = new IF_CelloCallinAPIController.InputHeader();        
        input.BO_CODE = oppty.OpportunityCode__c;
        input.LOGI_CP_ID = '123ABCD';
        input.LOGI_CP_CCD ='FIN';
        input.LOGI_CP_SCD = 'SAVE';
        input.LOGI_CP_RV_SCD = 'A';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_CelloCallinAPIController.doPost();
        Test.stopTest();
    }
    
    @IsTest
       static void restServiceCatchTestBID2() {
        Test.startTest();
        oppty = [Select ID,OpportunityCode__c from opportunity where OpportunityCode__c = 'SDS-22131802'];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        IF_CelloCallinAPIController.InputHeader input = new IF_CelloCallinAPIController.InputHeader();        
        input.BO_CODE = oppty.OpportunityCode__c;
        input.LOGI_CP_ID = '123ABC';
        input.LOGI_CP_CCD ='BID';
        input.LOGI_CP_SCD = 'CNFM';
        input.LOGI_CP_RV_SCD = 'A';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_CelloCallinAPIController.doPost();
        Test.stopTest();
    }
    
    @IsTest
       static void restServiceCatchTestFIN2() {
        Test.startTest();
        oppty = [Select ID,OpportunityCode__c from opportunity where OpportunityCode__c = 'SDS-22131802'];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        IF_CelloCallinAPIController.InputHeader input = new IF_CelloCallinAPIController.InputHeader();        
        input.BO_CODE = oppty.OpportunityCode__c;
        input.LOGI_CP_ID = '123ABC';
        input.LOGI_CP_CCD ='FIN';
        input.LOGI_CP_SCD = 'CNFM';
        input.LOGI_CP_RV_SCD = 'A';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_CelloCallinAPIController.doPost();
        Test.stopTest();
    }
    @IsTest
       static void restServiceFailCatchTest() {//Vikrant
        Test.startTest();
        oppty = [Select ID,OpportunityCode__c from opportunity where OpportunityCode__c = 'SDS-22131802'];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        IF_CelloCallinAPIController.InputHeader input = new IF_CelloCallinAPIController.InputHeader();        
        input.BO_CODE = oppty.OpportunityCode__c;
        input.LOGI_CP_ID = '123ABC456789deiuytr';
        input.LOGI_CP_CCD ='FIN';
        input.LOGI_CP_SCD = 'CNFM';
        input.LOGI_CP_RV_SCD = 'A';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_CelloCallinAPIController.doPost();
        Test.stopTest();
    }
	@IsTest
       static void restServiceCatchTestFIN3() {
        Test.startTest();
        oppty = [Select ID,OpportunityCode__c from opportunity where OpportunityCode__c = 'SDS-22131802'];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        IF_CelloCallinAPIController.InputHeader input = new IF_CelloCallinAPIController.InputHeader();        
        input.BO_CODE = oppty.OpportunityCode__c;
        input.LOGI_CP_ID = '123ABC';
        input.LOGI_CP_CCD ='FIN';
        input.LOGI_CP_SCD = 'SAVE';
        input.LOGI_CP_RV_SCD = 'A';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_CelloCallinAPIController.doPost();
        Test.stopTest();
    }
    @IsTest
       static void restServiceCatchTestBID3() {
        Test.startTest();
        oppty = [Select ID,OpportunityCode__c from opportunity where OpportunityCode__c = 'SDS-22131802'];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        IF_CelloCallinAPIController.InputHeader input = new IF_CelloCallinAPIController.InputHeader();        
        input.BO_CODE = oppty.OpportunityCode__c;
        input.LOGI_CP_ID = '123ABC';
        input.LOGI_CP_CCD ='BID';
        input.LOGI_CP_SCD = 'SAVE';
        input.LOGI_CP_RV_SCD = 'A';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_CelloCallinAPIController.doPost();
        Test.stopTest();
    }
    
}