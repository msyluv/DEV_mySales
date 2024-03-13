/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-22
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-12-28   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class IF_AirProposalController_Test {
    
    // IF_AirProposalController 테스트 클래스
    // INTERFACE_ID = 'IF-041';
    // APEX_CLASS   = 'IF_AirProposalController';
    // METHOD_NAME  = 'regPropsalCheck';

    final static String REQUEST_URL = '/services/apexrest/WebService/IF041';

    public IF_AirProposalController_Test() {    }

    @TestSetup
    static void makeData(){

        IF_Callout_TestDataSetup.dataSetup(); 
    }

    @isTest
    static void restServiceTest1() {
        Test.startTest();

        List<Opportunity> selectOpportunityList = [
            Select  Id
                    , OpportunityCode__c
            From    Opportunity
            Limit 10
        ];

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';

        String reqeustBody =    '{ ' +
                                '   "DATA":[ ' +
                                '       { ' +
                                '            "bo_code": "' + selectOpportunityList[0].OpportunityCode__c + '", ' +
                                '            "proposal_yn": "Y" ' +
                                '       }, ' +
                                '       { ' +
                                '            "bo_code": "' + selectOpportunityList[1].OpportunityCode__c + '", ' +
                                '            "proposal_yn": "N" ' +
                                '       } ' +                                
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_AirProposalController.regPropsalCheck();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }

    @isTest
    static void restServiceTest2() {
        Test.startTest();

        List<Opportunity> selectOpportunityList = [
            Select  Id
                    , OpportunityCode__c
            From    Opportunity
            Limit 10
        ];

        Opportunity_Activity__c insertOpportunityActivity = new Opportunity_Activity__c(
            WhatId__c = selectOpportunityList[0].Id
            , StartDate__c = Date.today()
            , EndDate__c = null
            , DueDate__c = Date.today()
            , Status__c = 'In Progress'
            , TransactionName__c = 'ZP61'
            , ExtID__c = selectOpportunityList[0].Id + '_' + 'ZP61'
        );
        Insert insertOpportunityActivity;

        Opportunity_Activity__c insertOpportunityActivity2 = new Opportunity_Activity__c(
            WhatId__c = selectOpportunityList[1].Id
            , StartDate__c = Date.today()
            , EndDate__c = null
            , DueDate__c = Date.today()
            , Status__c = 'In Progress'
            , TransactionName__c = 'ZP61'
            , ExtID__c = selectOpportunityList[1].Id + '_' + 'ZP61'
        );
        Insert insertOpportunityActivity2;

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';

        String reqeustBody =    '{ ' +
                                '   "DATA":[ ' +
                                '       { ' +
                                '            "bo_code": "' + selectOpportunityList[0].OpportunityCode__c + '", ' +
                                '            "proposal_yn": "Y" ' +
                                '       }, ' +
                                '       { ' +
                                '            "bo_code": "' + selectOpportunityList[1].OpportunityCode__c + '", ' +
                                '            "proposal_yn": "N" ' +
                                '       } ' +                                
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_AirProposalController.regPropsalCheck();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }
}