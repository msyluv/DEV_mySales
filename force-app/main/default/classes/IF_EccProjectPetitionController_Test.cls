/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-08-2021
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2020-12-29   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class IF_EccProjectPetitionController_Test {

    // IF_EccProjectPetitionController 테스트 클래스
    // INTERFACE_ID = 'IF-102';
    // APEX_CLASS   = 'IF_EccProjectPetitionController';
    // METHOD_NAME  = 'calloutProjectPetition';

    static final String REQUEST_DATA = 	
    '{' +
    '  "IV_BUKRS": "T100", ' +
    '  "IV_ORDERID": "SDS-20054480", ' +
    '  "IV_STEP": "S" ' +
    '}';

    public IF_EccProjectPetitionController_Test() {

    }

    @TestSetup
    static void makeData(){
        
    }

    @isTest
    static void testCallout() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Map<String,Object> result =  IF_EccProjectPetitionController.calloutProjectPetition(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 200);

        HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());

        System.assertEquals(String.valueOf(returnMap.get('EV_EXIST')), 'X');

        Test.stopTest();
    }

    @isTest
    static void testCallout400() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        Map<String, Object> result = IF_EccProjectPetitionController.calloutProjectPetition(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 400);

        Test.stopTest();
    }

    @isTest
    static void testCalloutError() {
        Test.startTest();

        Map<String,Object> result =  IF_EccProjectPetitionController.calloutProjectPetition(REQUEST_DATA);

        Test.stopTest();
    }
}