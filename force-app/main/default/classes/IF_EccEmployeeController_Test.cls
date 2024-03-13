/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-08-2021
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-12-01   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class IF_EccEmployeeController_Test {

    // IF_EccEmployeeController 테스트 클래스
    // INTERFACE_ID = 'IF-090';
    // APEX_CLASS   = 'IF_EccEmployeeController';
    // METHOD_NAME  = 'calloutEmployee';

    public IF_EccEmployeeController_Test() { }

    static final String REQUEST_DATA = 	'{' +
                                        '  "IV_GUBUN": "1", ' +
                                        '  "IV_SABUN": "16241" ' +
                                        '}';

    @TestSetup
    static void makeData(){    }

    @isTest
    static void testCallout() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Map<String, Object> result = IF_EccEmployeeController.calloutEmployee(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 200);

        HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
        System.assertEquals(String.valueOf(returnMap.get('EV_SAP_EMPNO')), '00016241');

        Test.stopTest();
    }

    @isTest
    static void testCallout400() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        Map<String, Object> result = IF_EccEmployeeController.calloutEmployee(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 400);

        Test.stopTest();
    }

    @isTest
    static void testCalloutError() {
        Test.startTest();

        IF_EccEmployeeController.calloutEmployee('Error');

        Test.stopTest();
    }    
}