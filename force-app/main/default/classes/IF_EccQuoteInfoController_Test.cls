/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-08-2021
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-12-02   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class IF_EccQuoteInfoController_Test {

    // IF_EccQuoteInfoController 테스트 클래스
    // INTERFACE_ID = 'IF-018';
    // APEX_CLASS   = 'IF_EccQuoteInfoController';
    // METHOD_NAME  = 'getQuoteInfo';

    public IF_EccQuoteInfoController_Test() { }

    static final String REQUEST_DATA = 	'{' +
                                        '  "INPUT": [ ' +
                                        '    { ' +
                                        '		"ZZCCODE": "SDS-18009210", ' +
                                        '		"BUKRS": "T100" ' +
                                        '    } ' +
                                        '  ] ' +
                                        '}';
                                        
    @TestSetup
    static void makeData(){    }

    @isTest
    static void testCallout() {
        Test.startTest();
    
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Map<String, Object> result = IF_EccQuoteInfoController.getQuoteInfo(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 200);

        HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
        List<Object> dataList = (List<Object>)returnMap.get('TT_SLAVE');

        Map<String, Object> dataMap = (Map<String, Object>)dataList[0];
        System.assertEquals(String.valueOf(dataMap.get('SYSTEM_ID')), 'MM21');        

        Test.stopTest();
    }

    @isTest
    static void testCallout400() {
        Test.startTest();
    
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        Map<String, Object> result = IF_EccQuoteInfoController.getQuoteInfo(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 400);

        Test.stopTest();
    }

    @isTest
    static void testCalloutError() {
        Test.startTest();

        IF_EccQuoteInfoController.getQuoteInfo('Error');

        Test.stopTest();
    }    
}