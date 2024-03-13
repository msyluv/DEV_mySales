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
public class IF_EccVrbRvReqCompController_Test {

    // IF_EccVrbRvReqCompController 테스트 클래스
    // INTERFACE_ID = 'IF-059';
    // APEX_CLASS   = 'IF_EccVrbRvReqCompController';
    // METHOD_NAME  = 'calloutVrbRvReqComp';

    public IF_EccVrbRvReqCompController_Test() {    }

    static final String REQUEST_DATA = 	'{' +
                                        '	"IV_ZZCCODE": "SDS-20054480" ' +
                                        '}';

    @TestSetup
    static void makeData(){    }

    @isTest
    static void testCallout() {
        
        Test.startTest();             
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Map<String, Object> result = IF_EccVrbRvReqCompController.calloutVrbRvReqComp(REQUEST_DATA);
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

        Map<String, Object> result = IF_EccVrbRvReqCompController.calloutVrbRvReqComp(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 400);

        Test.stopTest();
    }

    @isTest
    static void testCalloutError() {
        Test.startTest();

        Map<String, Object> result = IF_EccVrbRvReqCompController.calloutVrbRvReqComp('Error');        
        
        Test.stopTest();
    }    
}