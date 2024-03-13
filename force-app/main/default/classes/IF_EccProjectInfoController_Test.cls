/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-02-25
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2020-12-14   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class IF_EccProjectInfoController_Test {

    // IF_EccProjectInfoController 테스트 클래스
    // INTERFACE_ID = 'IF-004';
    // APEX_CLASS   = 'IF_EccProjectInfoController';
    // METHOD_NAME  = 'calloutProjectInfo';

    public IF_EccProjectInfoController_Test() {    }

    static final String REQUEST_DATA = 	'{' +
                                        '  "IV_ZZORDER_ID": "SDS-20054480", ' +
                                        '  "IV_PSPID": "SIC20054481A000", ' +
                                        '  "IV_BUKRS": "T100", ' +
                                        '  "IV_PROCESS_TYPE": "Z110", ' +
                                        '  "IT_PROJ":[ ' +
                                        '			    { ' + 
                                        '			        "ZZORDER_ID": "SDS-20054480", ' +
                                        '			        "ZZBUKRS_H": "T100", ' +
                                        '			        "PSPID": "SIC20054481A000", ' +
                                        '			        "SALES_EMP_NO": "16421", ' +
                                        '			        "SALES_EMP_NAME": "홍길동", ' +
                                        '			        "ZZSALES_C_NAME_M": "T100-12371", ' +
                                        '			        "ZZORDER_AMT": "1000000000" ' +
                                        '			    } ' +
                                        '	] ' +
                                        '}';   

    @TestSetup
    static void makeData(){    }

    @isTest
    static void testCallout() {
        
        Test.startTest();             
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Map<String, Object> result = IF_EccProjectInfoController.calloutProjectInfo(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 200);

        HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
        List<Object> dataList = (List<Object>)returnMap.get('IT_PROJ');

        Map<String, Object> dataMap = (Map<String, Object>)dataList[0];
        System.assertEquals(String.valueOf(dataMap.get('ZZORDER_ID')), 'SDS-20054480');

        Test.stopTest();
    }

    @isTest
    static void testCallout400() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        Map<String, Object> result = IF_EccProjectInfoController.calloutProjectInfo(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 400);

        Test.stopTest();
    }

    @isTest
    static void testCalloutError() {
        Test.startTest();

        Map<String, Object> result = IF_EccProjectInfoController.calloutProjectInfo('Error');        
        
        Test.stopTest();
    }

    @isTest
    static void testBatch() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        String jobId = 'testId';
        new IF_EccProjectInfoController(true, jobId);
        Batch_EccProjectInfoController.execCallout(REQUEST_DATA, jobId);
        
        Test.stopTest();
    }

    @isTest
    static void testBatch400() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        String jobId = 'testId';
        new IF_EccProjectInfoController(true, jobId);
        Batch_EccProjectInfoController.execCallout(REQUEST_DATA, jobId);
        
        Test.stopTest();
    }
}