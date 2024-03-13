/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-03-17
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2021-01-21   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class IF_RpaGetAccountInfoSchController_Test {
    public IF_RpaGetAccountInfoSchController_Test() {

    }

    static final String REQUEST_DATA = 	'{' +
                                        '	"CorporateNumber": "1018123421" ' +
                                        '}';

    @TestSetup
    static void makeData(){    }

    @isTest
    static void testCallout() {
        
        Test.startTest();             
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Map<String, Object> result = IF_RpaGetAccountInfoSchController.getAccountInfoSch(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 200);

        HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
        List<Object> dataList = (List<Object>)returnMap.get('IT_DATA');

        Map<String, Object> dataMap = (Map<String, Object>)dataList[0];
        System.assertEquals(String.valueOf(dataMap.get('CUST_REGNO')), '1018123421'); 

        Test.stopTest();
    }

    @isTest
    static void testCallout400() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        Map<String, Object> result = IF_RpaGetAccountInfoSchController.getAccountInfoSch(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 400);

        Test.stopTest();
    }

    @isTest
    static void testCalloutError() {
        Test.startTest();

        Map<String, Object> result = IF_RpaGetAccountInfoSchController.getAccountInfoSch('Error');        
        
        Test.stopTest();
    }
}