/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-03-05
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-12-28   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class IF_EccResourcePreInputController_Test {

    // IF_EccResourcePreInputController 테스트 클래스
    // INTERFACE_ID = 'IF-033';
    // APEX_CLASS   = 'IF_EccResourcePreInputController';
    // METHOD_NAME  = 'setResourcePreInput';    

    final static String REQUEST_URL = '/services/apexrest/WebService/IF033';

    public IF_EccResourcePreInputController_Test() {   }

    @TestSetup
    static void makeData(){

        IF_Callout_TestDataSetup.dataSetup();
    }

    @isTest
    static void restServiceTest() {
        Test.startTest();

        List<Opportunity> selectOpportunityList = [
            Select  Id
                    , OpportunityCode__c
            From    Opportunity
        ];

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';

        String reqeustBody =    '{ ' +
                                '   "DATA":[ ' +
                                '       { ' +
                                // '            "IV_PROJECT": "SDS-20000160", ' +
                                '            "IV_PROJECT": "' + selectOpportunityList[0].OpportunityCode__c + '", ' +
                                '            "IV_INPUT_P": "X" ' +
                                '        }, ' +
                                '        {  ' +
                                // '            "IV_PROJECT": "SDS-20000160", ' +
                                '            "IV_PROJECT": "' + selectOpportunityList[1].OpportunityCode__c + '", ' +
                                '            "IV_INPUT_P": "" ' +
                                '       } ' +
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_EccResourcePreInputController.setResourcePreInput();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }

    @isTest
    static void restServiceTest_Exception() {   // Exception Cover 되도록 해야 함
        Test.startTest();

        List<Opportunity> selectOpportunityList = [
            Select  Id
                    , OpportunityCode__c
            From    Opportunity
        ];

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';

        String reqeustBody =    '{ ' +
                                '   "DATA error":[ ' +
                                '       { ' +
                                '            "IV_PROJECT": "' + selectOpportunityList[0].OpportunityCode__c + '", ' +
                                '            "IV_INPUT_P": "X" ' +
                                '        }, ' +
                                '        {  ' +
                                '            "IV_PROJECT": "' + selectOpportunityList[1].OpportunityCode__c + '", ' +
                                '            "IV_INPUT_P": "" ' +
                                '       } ' +
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_EccResourcePreInputController.setResourcePreInput();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }

    @isTest
    static void restServiceTest_NoData() {   
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';

        String reqeustBody =    '{ ' +
                                '   "DATA":[ ' +
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_EccResourcePreInputController.setResourcePreInput();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }    
}