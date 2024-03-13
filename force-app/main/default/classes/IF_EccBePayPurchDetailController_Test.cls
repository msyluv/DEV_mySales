/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-08
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2021-01-08   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class IF_EccBePayPurchDetailController_Test {
    static final String REQUEST_DATA = 	
    '{' +
    '  "boCode": "SDS-20054480" ' +
    '}';

    public IF_EccBePayPurchDetailController_Test() {

    }

    @TestSetup
    static void makeData(){

    }

    @isTest
    static void testCallout() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        
        Map<String,Object> result =  IF_EccBePayPurchDetailController.bePayPurchDetailChk(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 200);

        HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());

        System.assertEquals(String.valueOf(returnMap.get('EV_MSGTY')), 'S');

        Test.stopTest();
    }

    @isTest
    static void testCallout400() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        Map<String, Object> result = IF_EccBePayPurchDetailController.bePayPurchDetailChk(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 400);

        Test.stopTest();
    }

    @isTest
    static void testCalloutError() {
        Test.startTest();
       
        Map<String,Object> resMap =  IF_EccBePayPurchDetailController.bePayPurchDetailChk(REQUEST_DATA);
        
        Test.stopTest();
    }
}