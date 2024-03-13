/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2020-12-30
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2020-12-10   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class IF_EccDeleteServiceCheckController_Test {
    static final String REQUEST_DATA = 	
    '{' +
    '  "IV_PSPID": "SCA07000285A000", ' +
    '  "IV_SRVCD": "20000001" ' +
    '}';

    public IF_EccDeleteServiceCheckController_Test() {

    }

    @TestSetup
    static void makeData(){

    }

    @isTest
    static void testCallout() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        
        Map<String,Object> result =  IF_EccDeleteServiceCheckController.deleteServiceCheck(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 200);

        HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());

        System.assertEquals(String.valueOf(returnMap.get('EV_RTNST')), 'S');

        Test.stopTest();
    }

    @isTest
    static void testCallout400() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        Map<String, Object> result = IF_EccDeleteServiceCheckController.deleteServiceCheck(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 400);

        Test.stopTest();
    }

    @isTest
    static void testCalloutError() {
        Test.startTest();
       
        Map<String,Object> resMap =  IF_EccDeleteServiceCheckController.deleteServiceCheck(REQUEST_DATA);
        
        Test.stopTest();
    }
}