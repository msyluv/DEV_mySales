/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-08-2021
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-12-29   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class IF_EccBoServiceSolutionController_Test {

    // IF_EccBoServiceSolutionController 테스트 클래스
    // INTERFACE_ID = 'IF-099';
    // APEX_CLASS   = 'IF_EccBoServiceSolutionController';
    // METHOD_NAME  = 'getBoServiceSolution';

    final static String REQUEST_URL = '/services/apexrest/WebService/IF099';

    public IF_EccBoServiceSolutionController_Test() {    }

    @TestSetup
    static void makeData(){

        IF_Callout_TestDataSetup.dataSetup();

    }

    @isTest
    static void restServiceTest() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';

        String reqeustBody =    '{ ' +
                                '   "DATA":[ ' +
                                '       { ' +
                                '           "IV_BUKRS": "T100", ' +
                                '           "IV_ZZORDER_ID": "SDS-20000200", ' +
                                '           "IV_BO_VER":"" ' +
                                '       } ' +
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_EccBoServiceSolutionController.getBoServiceSolution();

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

        String reqeustBody =    '{ ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_EccBoServiceSolutionController.getBoServiceSolution();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }
}