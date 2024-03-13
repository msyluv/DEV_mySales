/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-10-20
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2020-12-31   raeganja@partner.samsung.com   Initial Version
**/
@isTest

public class IF_CelloLbsStatusController_Test {
    //IF-069
    final static String REQUEST_URL = '/services/apexrest/WebService/IF069';
    static Account acc = Utils_TestDataFactory.createAccount('TestAcc');
    static Opportunity_Activity__c opptyAct1;
    static Opportunity_Activity__c opptyAct2;

    static Opportunity  oppty;
    static{
        
        acc.MDGCheck__c = true;
        update acc;
        oppty = Utils_TestDataFactory.createOpportunity('TestOppty', acc.id);

        opptyAct1 = new Opportunity_Activity__c(
                WhatId__c = oppty.Id
                , TransactionName__c = OpportunityActivityHelper.ACT_CODE_BIDDING_LBS
                , Status__c = 'In Progress'
            );
        insert opptyAct1;
        opptyAct2 = new Opportunity_Activity__c(
                    WhatId__c = oppty.Id
                    , TransactionName__c = OpportunityActivityHelper.ACT_CODE_FINAL_LBS
                    , Status__c = 'In Progress'
                );
        insert opptyAct2;
    }
    static LBS__c lbs = Utils_TestDataFactory.createLBS('RL20082103599', oppty.id);
    

    @TestSetup
    private static void setData(){
        
    }

    @isTest 
    static void restServiceTest() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;        
        request.httpMethod = 'POST';

        String reqeustBody = 
        '{ ' +
        '   "DATA": [ ' +
        '       { ' +
        '           "Opportunity": [ ' +
        '               { ' +
        '                   "Id": "'+oppty.id+'", ' +
        '                   "BizDevelopmentType": "02", ' +
        '                   "Name": "중남미 포워딩사업 test2", ' +
        '                   "LogisticsBizType": "01,02", ' +
        '                   "OwnerID": "M160205072003C603452", ' +
        '                   "SalesRegionalHQ": "C", ' +
        '                   "SalesBranch": "T611", ' +
        '                   "DeliveryRegionalHQ": "C", ' +
        '                   "DeliveryBranch": "T611" ' +
        '               } ' +
        '           ], ' +
        '           "LBS": [ ' +
        '               { ' +
        '                   "OpportunityId": "'+oppty.id+'", ' +
        '                   "LBSID": "RL20082103599", ' +
        '                   "LogisticsServiceType": "01", ' +
        '                   "BiddingDeadline": "2020-10-01", ' +
        '                   "CloseDate": "2020-10-06", ' +
        '                   "cRevenueStartDate": "2020-12-10", ' +
        '                   "cRevenueEndDate": "2020-12-31", ' +
        '                   "Type": "01", ' +
        '                   "LBSStatus": "CMPT", ' +
        '                   "Amount": "0.0", ' +
        '                   "LEGAL_SYS_CNTRT_NO": "OA2018094379" ' +
        '               } ' +
        '           ] ' +
        '       } ' +
        '   ] ' +
        '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_CelloLbsStatusController.saveData();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }

    @isTest 
    static void restServiceTest2() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;        
        request.httpMethod = 'POST';

        String reqeustBody = 
        '{ ' +
        '   "DATA": [ ' +
        '       { ' +
        '           "Opportunity": [ ' +
        '               { ' +
        '                   "Id": "'+oppty.id+'", ' +
        '                   "BizDevelopmentType": "02", ' +
        '                   "Name": "중남미 포워딩사업 test2", ' +
        '                   "LogisticsBizType": "01,02", ' +
        '                   "OwnerID": "M160205072003C603452", ' +
        '                   "SalesRegionalHQ": "C", ' +
        '                   "SalesBranch": "T611", ' +
        '                   "DeliveryRegionalHQ": "C", ' +
        '                   "DeliveryBranch": "T611" ' +
        '               } ' +
        '           ], ' +
        '           "LBS": [ ' +
        '               { ' +
        '                   "OpportunityId": "'+oppty.id+'", ' +
        '                   "LBSID": "RL20082103599", ' +
        '                   "LogisticsServiceType": "01", ' +
        '                   "BiddingDeadline": "2020-10-01", ' +
        '                   "CloseDate": "2020-10-06", ' +
        '                   "cRevenueStartDate": "2020-12-10", ' +
        '                   "cRevenueEndDate": "2020-12-31", ' +
        '                   "Type": "01", ' +
        '                   "LBSStatus": "PASS", ' +
        '                   "Amount": "0.0", ' +
        '                   "LEGAL_SYS_CNTRT_NO": "OA2018094379" ' +
        '               } ' +
        '           ] ' +
        '       } ' +
        '   ] ' +
        '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_CelloLbsStatusController.saveData();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }

    @isTest 
    static void restServiceTest3() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;        
        request.httpMethod = 'POST';

        lbs.LBSStatus__c   = 'REG';
        String reqeustBody = 
        '{ ' +
        '   "DATA": [ ' +
        '       { ' +
        '           "Opportunity": [ ' +
        '               { ' +
        '                   "Id": "'+oppty.id+'", ' +
        '                   "BizDevelopmentType": "02", ' +
        '                   "Name": "중남미 포워딩사업 test2", ' +
        '                   "LogisticsBizType": "01,02", ' +
        '                   "OwnerID": "M160205072003C603452", ' +
        '                   "SalesRegionalHQ": "C", ' +
        '                   "SalesBranch": "T611", ' +
        '                   "DeliveryRegionalHQ": "C", ' +
        '                   "DeliveryBranch": "T611" ' +
        '               } ' +
        '           ], ' +
        '           "LBS": [ ' +
        '               { ' +
        '                   "OpportunityId": "'+oppty.id+'", ' +
        '                   "LBSID": "RL20082103599", ' +
        '                   "LogisticsServiceType": "01", ' +
        '                   "BiddingDeadline": "2020-10-01", ' +
        '                   "CloseDate": "2020-10-06", ' +
        '                   "cRevenueStartDate": "2020-12-10", ' +
        '                   "cRevenueEndDate": "2020-12-31", ' +
        '                   "Type": "01", ' +
        '                   "LBSStatus": "DEL", ' +
        '                   "Amount": "0.0", ' +
        '                   "LEGAL_SYS_CNTRT_NO": "OA2018094379" ' +
        '               } ' +
        '           ] ' +
        '       } ' +
        '   ] ' +
        '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_CelloLbsStatusController.saveData();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }

    @isTest 
    static void restServiceTest_DATA_NULL() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;        
        request.httpMethod = 'POST';

        String reqeustBody = 
        '{ ' +
        '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_CelloLbsStatusController.saveData();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }

    @isTest 
    static void restServiceTest_Exception() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;        
        request.httpMethod = 'POST';

        String reqeustBody = 
        '{ ' +
        '   "DATA_Exception": [ ' +
        '       { ' +
        '           "Opportunity": [ ' +
        '               { ' +
        '                   "Id": "'+oppty.id+'", ' +
        '                   "BizDevelopmentType": "02", ' +
        '                   "Name": "중남미 포워딩사업 test2", ' +
        '                   "LogisticsBizType": "01,02", ' +
        '                   "OwnerID": "M160205072003C603452", ' +
        '                   "SalesRegionalHQ": "C", ' +
        '                   "SalesBranch": "T611", ' +
        '                   "DeliveryRegionalHQ": "C", ' +
        '                   "DeliveryBranch": "T611" ' +
        '               } ' +
        '           ], ' +
        '           "LBS": [ ' +
        '               { ' +
        '                   "OpportunityId": "'+oppty.id+'", ' +
        '                   "LBSID": "RL20082103599", ' +
        '                   "LogisticsServiceType": "01", ' +
        '                   "BiddingDeadline": "2020-10-01", ' +
        '                   "CloseDate": "2020-10-06", ' +
        '                   "cRevenueStartDate": "2020-12-10", ' +
        '                   "cRevenueEndDate": "2020-12-31", ' +
        '                   "Type": "01", ' +
        '                   "LBSStatus": "CMPT", ' +
        '                   "Amount": "0.0", ' +
        '                   "LEGAL_SYS_CNTRT_NO": "OA2018094379" ' +
        '               } ' +
        '           ] ' +
        '       } ' +
        '   ] ' +
        '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_CelloLbsStatusController.saveData();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }

    
    @isTest 
    static void restServiceTes_DEL() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;        
        request.httpMethod = 'POST';

        String reqeustBody = 
        '{ ' +
        '   "DATA": [ ' +
        '       { ' +
        '           "Opportunity": [ ' +
        '               { ' +
        '                   "Id": "'+oppty.id+'", ' +
        '                   "BizDevelopmentType": "02", ' +
        '                   "Name": "중남미 포워딩사업 test2", ' +
        '                   "LogisticsBizType": "01,02", ' +
        '                   "OwnerID": "M160205072003C603452", ' +
        '                   "SalesRegionalHQ": "C", ' +
        '                   "SalesBranch": "T611", ' +
        '                   "DeliveryRegionalHQ": "C", ' +
        '                   "DeliveryBranch": "T611" ' +
        '               } ' +
        '           ], ' +
        '           "LBS": [ ' +
        '               { ' +
        '                   "OpportunityId": "'+oppty.id+'", ' +
        '                   "LBSID": "RL20082103599", ' +
        '                   "LogisticsServiceType": "01", ' +
        '                   "BiddingDeadline": "2020-10-01", ' +
        '                   "CloseDate": "2020-10-06", ' +
        '                   "cRevenueStartDate": "2020-12-10", ' +
        '                   "cRevenueEndDate": "2020-12-31", ' +
        '                   "Type": "01", ' +
        '                   "LBSStatus": "DEL", ' +
        '                   "Amount": "0.0", ' +
        '                   "LEGAL_SYS_CNTRT_NO": "OA2018094379" ' +
        '               } ' +
        '           ] ' +
        '       } ' +
        '   ] ' +
        '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_CelloLbsStatusController.saveData();
            system.debug('opptyAct1:' + [SELECT Id, Name, Status__c, TransactionName__c FROM Opportunity_Activity__c WHERE WhatId__c =: oppty.Id]);

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }
}