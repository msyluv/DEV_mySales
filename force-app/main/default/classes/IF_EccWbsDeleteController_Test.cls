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
public class IF_EccWbsDeleteController_Test {

    // IF_EccWbsDeleteController 테스트 클래스
    // INTERFACE_ID = 'IF-058';
    // APEX_CLASS   = 'IF_EccWbsDeleteController';
    // METHOD_NAME  = 'calloutWbsDelete';

    public IF_EccWbsDeleteController_Test() { }

    static final String REQUEST_DATA = 	'{' +
                                        '  "IT_SOLUTION": [ ' +
                                        '    { ' +
                                        '      "ZZWBS_CLASS_S": "SC", ' +
                                        '      "ZZORDER_TYPE_S": "S124", ' +
                                        '      "ZZBIZ_TYPE_S": "TD", ' +
                                        '      "SOLUTION_NAME": "NETWORK IMPLEMENTATION", ' +
                                        '      "SOLUTION_CODE": "SCC18065191C20131", ' +
                                        '      "SOLUTION": "30000067", ' +
                                        '      "SERVICE_CODE": "SCC18065191C201", ' +
                                        '      "OPTION": "D", ' +
                                        '      "NUMBER_INT": 10, ' +
                                        '      "GUBUN": "1" ' +
                                        '    }, ' +
                                        '    { ' +
                                        '      "ZZWBS_CLASS_S": "SC", ' +
                                        '      "ZZORDER_TYPE_S": "S124", ' +
                                        '      "ZZBIZ_TYPE_S": "TD", ' +
                                        '      "SOLUTION_NAME": "NETWORK IMPLEMENTATION", ' +
                                        '      "SOLUTION_CODE": "SCC18065191C20121", ' +
                                        '      "SOLUTION": "30000067", ' +
                                        '      "SERVICE_CODE": "SCC18065191C201", ' +
                                        '      "OPTION": "D", ' +
                                        '      "NUMBER_INT": 10, ' +
                                        '      "GUBUN": "1" ' +
                                        '    }, ' +
                                        '    { ' +
                                        '      "ZZWBS_CLASS_S": "SC", ' +
                                        '      "ZZORDER_TYPE_S": "S124", ' +
                                        '      "ZZBIZ_TYPE_S": "TD", ' +
                                        '      "SOLUTION_NAME": "NETWORK IMPLEMENTATION", ' +
                                        '      "SOLUTION_CODE": "SCC18065191C20111", ' +
                                        '      "SOLUTION": "30000067", ' +
                                        '      "SERVICE_CODE": "SCC18065191C201", ' +
                                        '      "OPTION": "D", ' +
                                        '      "NUMBER_INT": 10, ' +
                                        '      "GUBUN": "1" ' +
                                        '    } ' +
                                        '  ], ' +
                                        '  "IT_SERVICE": [ ' +
                                        '    { ' +
                                        '      "ZZSERVICE_REP_X": "", ' +
                                        '      "SUB_FKSTL": "T320-80050", ' +
                                        '      "SUB_AKSTL": "T320-80050", ' +
                                        '      "SERVICE_NAME": "NETWORK", ' +
                                        '      "SERVICE_CODE": "SCC18065191C201", ' +
                                        '      "SERVICE": "20000020", ' +
                                        '      "OPTION": "C", ' +
                                        '      "NUMBER_INT": 10 ' +
                                        '    } ' +
                                        '  ] ' +
                                        '} ';
                                        
    @TestSetup
    static void makeData(){    }

    @isTest
    static void testCallout() {
        Test.startTest();
                     
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Map<String, Object> result = IF_EccWbsDeleteController.calloutWbsDelete(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 200);

        HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
        List<Object> dataList = (List<Object>)returnMap.get('ET_MESSAGE');

        Map<String, Object> dataMap = (Map<String, Object>)dataList[0];
        System.assertEquals(String.valueOf(dataMap.get('TYPE')), 'S');

        Test.stopTest();
    }

    @isTest
    static void testCallout400() {
        Test.startTest();
                     
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        Map<String, Object> result = IF_EccWbsDeleteController.calloutWbsDelete(REQUEST_DATA);
        // System.assertEquals(result.get('StatusCode'), 400);

        Test.stopTest();
    }

    @isTest
    static void testCalloutError() {
        Test.startTest();

        Map<String, Object> result = IF_EccWbsDeleteController.calloutWbsDelete('Error');

        Test.stopTest();
    }    
}