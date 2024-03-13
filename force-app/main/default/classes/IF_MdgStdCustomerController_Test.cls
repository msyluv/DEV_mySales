/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-08-2021
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-12-30   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class IF_MdgStdCustomerController_Test {
    
    // IF_MdgStdCustomerController 테스트 클래스
    // INTERFACE_ID = 'IF-117';
    // APEX_CLASS   = 'IF_MdgStdCustomerController';
    // METHOD_NAME  = 'regStandardCustomer';

    final static String REQUEST_URL = '/services/apexrest/WebService/IF117';

    public IF_MdgStdCustomerController_Test() {    }

    @TestSetup
    static void makeData(){

        // IF_Callout_TestDataSetup.dataSetup();

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
                                '            "ZZNStKun": "test1", ' +
                                '            "Land1": "2", ' +
                                '            "ZZStLevel": "3", ' +
                                '            "ZZHstLevel": "4", ' +
                                '            "ZZStcName1": "5", ' +
                                '            "ZZStcName2": "6", ' +
                                '            "ZZStcDesc": "7", ' +
                                '            "ZZDel": "N" ' +
                                '       } ' +
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_MdgStdCustomerController.regStandardCustomer();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }

    @isTest
    static void restServiceTest2() {    // 중복으로 Exception 체크
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';

        String reqeustBody =    '{ ' +
                                '   "DATA":[ ' +
                                '       { ' +
                                '            "ZZNStKun": "test1", ' +
                                '            "Land1": "2", ' +
                                '            "ZZStLevel": "3", ' +
                                '            "ZZHstLevel": "4", ' +
                                '            "ZZStcName1": "5", ' +
                                '            "ZZStcName2": "6", ' +
                                '            "ZZStcDesc": "7", ' +
                                '            "ZZDel": "N" ' +
                                '       }, ' +
                                '       { ' +
                                '            "ZZNStKun": "test1", ' +
                                '            "Land1": "2", ' +
                                '            "ZZStLevel": "3", ' +
                                '            "ZZHstLevel": "4", ' +
                                '            "ZZStcName1": "5", ' +
                                '            "ZZStcName2": "6", ' +
                                '            "ZZStcDesc": "7", ' +
                                '            "ZZDel": "N" ' +
                                '       } ' +                                
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_MdgStdCustomerController.regStandardCustomer();

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

        String reqeustBody =    '{ ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_MdgStdCustomerController.regStandardCustomer();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }    
}