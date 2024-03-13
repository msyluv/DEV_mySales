/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 03-22-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   03-22-2021   soohong0.kim@partner.samsung.com   Initial Version
**/
@isTest
public class IF_SdUpdateCostVersionController_Test {
    final static String REQUEST_URL = '/services/apexrest/WebService/IF136';
    static Opportunity oppty;
    static Opportunity_Activity__c opptyAct = new Opportunity_Activity__c();
    static Account acc;
    @TestSetup
    static void setData(){

        Map<String,String> pickMap = new Map<String,String>();
        acc = Utils_TestDataFactory.createAccount('TestAcc');
        acc.AccountNumber = 'A2222233';
        acc.MDGCheck__c = true;
        update acc;

        oppty = Utils_TestDataFactory.createOpportunity('TestOppty', acc.id);
        oppty.cOriginAcc__c = acc.id;
        oppty.Amount = 1234124;
        oppty.BusinessLevel__c = pickMap.get('value');
        update oppty;

        pickMap = Utils.getPicklistOptionType('Opportunity_Activity__c','TransactionName__c')[0];
        opptyAct.WhatId__c = oppty.id;
        opptyAct.TransactionName__c = 'XP51';
        opptyAct.ExtId__c = oppty.id + '_'+pickMap.get('value');
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

        IF_SdUpdateCostVersionController.InputHeader input = new IF_SdUpdateCostVersionController.InputHeader();

        List<IF_SdUpdateCostVersionController.InputClass> dataList = new List<IF_SdUpdateCostVersionController.InputClass>();
        IF_SdUpdateCostVersionController.InputClass data = new IF_SdUpdateCostVersionController.InputClass();
        
        data.IV_ZZORDER_ID = tmpOppty.OpportunityCode__c;
        data.IV_BUKRS = tmpOppty.CompanyCode__c;
        data.IV_VERSION = 'S123';
        data.IV_GUBUN = 'X';
        dataList.add(data);
        input.DATA = dataList;
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateCostVersionController.doPost();

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

        IF_SdUpdateCostVersionController.InputHeader input = new IF_SdUpdateCostVersionController.InputHeader();

        List<IF_SdUpdateCostVersionController.InputClass> dataList = new List<IF_SdUpdateCostVersionController.InputClass>();
        IF_SdUpdateCostVersionController.InputClass data = new IF_SdUpdateCostVersionController.InputClass();
        
        data.IV_ZZORDER_ID = 'Test123';
        data.IV_BUKRS = 'Test123';
        data.IV_VERSION = 'S123';
        data.IV_GUBUN = 'X';
        dataList.add(data);
        input.DATA = dataList;
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdateCostVersionController.doPost();

        Test.stopTest();
    }
}