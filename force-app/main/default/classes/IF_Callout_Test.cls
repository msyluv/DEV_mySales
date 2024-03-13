/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-05-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-10-28   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class IF_Callout_Test {
    @testSetup
    static void Setup() {

    }

    @isTest // Mock으로 Test
    Static void IFCalloutSuccessMock() {       
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());

//        IF_Callout httpHandler = new IF_Callout('TestId001');
        IF_Callout httpHandler = new IF_Callout('IF-005');
        Map<String, Object> result = httpHandler.httpCallout('{"test":"test"}', '');
        Test.stopTest();

        System.assertEquals('200', String.valueOf(result.get('StatusCode')));
        System.assertEquals('System.HttpResponse[Status=OK, StatusCode=200]', String.valueOf(result.get('HttpResponse')));

        HttpResponse hRes = (HttpResponse)result.get('HttpResponse');

//        System.assertEquals('{"animals":["majestic badger","fluffy bunny","scary bear","chicken"]}', String.valueOf(hRes.getBody()));
            system.debug('Response Body : ' + hRes.getBody());
    }

    @isTest
    Static void IFCalloutExceptionMock() {

        Test.startTest();
        // Test.setMock(HttpCalloutMock.class, new InterfaceHttpHandler_TestMock());
//        IF_Callout httpHandler = new IF_Callout('TestId002');
        IF_Callout httpHandler = new IF_Callout('IF-005');
        // Map<String, Object> result = httpHandler.httpCallout('{"test":"test"}', '');
        Map<String, Object> result = httpHandler.httpCallout('body String.. Exception...', '');
        Test.stopTest();

        System.assertEquals('500', String.valueOf(result.get('StatusCode')));
    }
}