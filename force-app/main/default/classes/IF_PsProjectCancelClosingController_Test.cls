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
public class IF_PsProjectCancelClosingController_Test {

    // IF_PsProjectCancelClosingController 테스트 클래스
    // INTERFACE_ID = 'IF-008';
    // APEX_CLASS   = 'IF_PsProjectCancelClosingController';
    // METHOD_NAME  = 'calloutCancelRequest';

    public IF_PsProjectCancelClosingController_Test() { }

    static final String REQUEST_DATA = 	'{' +
                                        '  "I_PSPID": "SIC20054481A000" ' +
                                        '}';

    @TestSetup
    static void makeData(){    }

    @isTest
    static void testCallout() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Map<String, Object> result = IF_PsProjectCancelClosingController.calloutCancelRequest(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 200);

        HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
        System.assertEquals(String.valueOf(returnMap.get('E_RTNST')), 'S');

        Test.stopTest();
    }

    @isTest
    static void testCallout400() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        Map<String, Object> result = IF_PsProjectCancelClosingController.calloutCancelRequest(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 400);

        Test.stopTest();
    }

    @isTest
    static void testCalloutError() {
        Test.startTest();

        Map<String, Object> result = IF_PsProjectCancelClosingController.calloutCancelRequest('Error');

        Test.stopTest();
    }    
}