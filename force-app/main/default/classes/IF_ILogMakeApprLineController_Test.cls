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
public class IF_ILogMakeApprLineController_Test {
    static final String REQUEST_DATA = 	
    '{' +
    '  "objectKey": "", ' +
    '  "corporationId": "T100", ' +
    '  "module": "CR", ' +
    '  "approvalProcessId": "ZCRM000050", ' +
    '  "draftId": "terius.kim", ' +
    '  "draftCompany": "C60", ' +
    '  "draftEmpNo": "16241", ' +
    '  "draftDept": "C60AJ760", ' +
    '  "T_CONTAINER": [ ' +
    '	{ ' +
    '     "name": "BSNE_ESTIMATED_AMT", ' +
    '     "value": "100000000" ' +
    '	} ' +
    '  ] ' +
    '}';

    public IF_ILogMakeApprLineController_Test() {

    }

    @TestSetup
    static void makeData(){

    }

    @isTest
    static void testCallout() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        
        Map<String,Object> result =  IF_ILogMakeApprLineController.calloutSearchApprList(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 200);

        HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());

        List<Object> dataList = (List<Object>)returnMap.get('T_PATHLIST');

        Map<String, Object> dataMap = (Map<String, Object>)dataList[0];

        System.assertEquals(String.valueOf(dataMap.get('draftId')), 'terius.kim');

        Test.stopTest();
    }

    @isTest
    static void testCallout400() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        Map<String, Object> result = IF_ILogMakeApprLineController.calloutSearchApprList(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 400);

        Test.stopTest();
    }

    @isTest
    static void testCalloutError() {
        Test.startTest();
       
        Map<String,Object> resMap =  IF_ILogMakeApprLineController.calloutSearchApprList(REQUEST_DATA);
        
        Test.stopTest();
    }
}