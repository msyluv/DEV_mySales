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
public class IF_EccTeamHeadController_Test {

    // IF_EccTeamHeadController 테스트 클래스
    // INTERFACE_ID = 'IF-062';
    // APEX_CLASS   = 'IF_EccTeamHeadController';
    // METHOD_NAME  = 'getTeamHeadInfo';

    public IF_EccTeamHeadController_Test() {    }

    static final String REQUEST_DATA = 	'{' +
                                        '  "IT_KOSTL_INFO": [' +
                                        '    {' +
                                        '      "KOSTL": "T100-12371"' +
                                        '    }' +
                                        '  ]' +
                                        '}';

    @isTest
    static void testCallout() {
        
        Test.startTest();             
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Map<String, Object> result = IF_EccTeamHeadController.getTeamHeadInfo(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 200);

        HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
        List<Object> dataList = (List<Object>)returnMap.get('ET_MANAGER_INFO');

        Map<String, Object> dataMap = (Map<String, Object>)dataList[0];
        System.assertEquals(String.valueOf(dataMap.get('EV_BUKRS')), 'T100');

        Test.stopTest();
    }

    @isTest
    static void testCallout400() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        Map<String, Object> result = IF_EccTeamHeadController.getTeamHeadInfo(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 400);

        Test.stopTest();
    }

    @isTest
    static void testCalloutError() {
        Test.startTest();

        Map<String, Object> result = IF_EccTeamHeadController.getTeamHeadInfo('Error');        
        
        Test.stopTest();
    }                                        

}