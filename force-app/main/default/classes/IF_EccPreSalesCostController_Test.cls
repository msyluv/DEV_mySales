/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-08-2021
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2020-12-10   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class IF_EccPreSalesCostController_Test {

    // IF_EccPreSalesCostController 테스트 클래스
    // INTERFACE_ID = 'IF-036';
    // APEX_CLASS   = 'IF_EccPreSalesCostController';
    // METHOD_NAME  = 'getPreSalesCost';

    public IF_EccPreSalesCostController_Test() {    }

    static final String REQUEST_DATA = 	'{' +
                                        '  "IV_ZZCCODE": "SDS-20054480", ' +
                                        '  "IV_PSPID": "SIC20054481A000", ' +
                                        '  "IV_BUKRS": "T100", ' +
                                        '  "IV_CLOSE": "X" ' +
                                        '}';
    @TestSetup
    static void makeData(){    }

    @isTest
    static void testCallout() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Map<String, Object> result = IF_EccPreSalesCostController.getPreSalesCost(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 200);

        HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
        List<Object> dataList = (List<Object>)returnMap.get('TT_PLANAMT');

        Map<String, Object> dataMap = (Map<String, Object>)dataList[0];
        System.assertEquals(String.valueOf(dataMap.get('PSPID')), 'SIC-20001421-A0');

        Test.stopTest();
    }

    @isTest
    static void testCallout400() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        Map<String, Object> result = IF_EccPreSalesCostController.getPreSalesCost(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 400);

        Test.stopTest();
    }

    @isTest
    static void testCalloutError() {
        Test.startTest();

        Map<String, Object> result = IF_EccPreSalesCostController.getPreSalesCost('Error');

        Test.stopTest();
    }
}