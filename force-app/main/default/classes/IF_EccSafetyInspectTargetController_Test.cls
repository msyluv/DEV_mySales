/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2020-12-29
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2020-12-11   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class IF_EccSafetyInspectTargetController_Test {
    static final String REQUEST_DATA = 	
    '{' +
    '   "IV_PSPID": "SCA07000285A000", ' +
    '   "IV_ZZCCODE": "SDS-20054480", ' +
    '	"IV_GUBUN": "S" ' +
    '}';

    public IF_EccSafetyInspectTargetController_Test() {

    }

    @TestSetup
    static void makeData(){
        
    }

    @isTest
    static void testCallout() {
        Test.startTest();
                        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Map<String,Object> result =  IF_EccSafetyInspectTargetController.getSafetyInspectTarget(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 200);

        HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());

        System.assertEquals(String.valueOf(returnMap.get('EV_RETURN')), 'Y');

        Test.stopTest();
    }

    @isTest
    static void testCallout400() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        Map<String, Object> result = IF_EccSafetyInspectTargetController.getSafetyInspectTarget(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 400);

        Test.stopTest();
    }

    @isTest
    static void testCalloutError() {
        Test.startTest();

        Map<String,Object> result =  IF_EccSafetyInspectTargetController.getSafetyInspectTarget(REQUEST_DATA);

        Test.stopTest();
    }
}