/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-13
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-12-18   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public  class IF_EccOpportunityDetailController_Test {

    // IF_EccOpportunityDetailController 테스트 클래스
    // INTERFACE_ID = 'IF-114';
    // APEX_CLASS   = 'IF_EccOpportunityDetailController';
    // METHOD_NAME  = 'getOpportunityDetailInfo';

    public IF_EccOpportunityDetailController_Test() {    }
    
    @isTest
    static void restServiceTest() {
        Test.startTest();

        IF_Callout_TestDataSetup.dataSetup();

        String OppCode = null;

        Opportunity oppList = [Select Id, OpportunityCode__c From Opportunity][0];

        OppCode = oppList.OpportunityCode__c;

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
//        request.requestURI = 'https://sdssfa--dev.my.salesforce.com/services/apexrest/WebService/IF114';
        request.requestURI = '/services/apexrest/WebService/IF114';        
        request.httpMethod = 'POST';

        String reqeustBody =    '{ ' +
                                '   "DATA":[ ' +
                                '       { ' +
                                '           "PJTCODE":"' + OppCode + '"' +
                                '       } ' +
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_EccOpportunityDetailController.getOpportunityDetailInfo();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }
}