/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2020-12-29
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   11-30-2020   soohong0.kim@partner.samsung.com   Initial Version
**/
@isTest
private class IF_KnoxGetCalendarsController_Test {
    private static testMethod void IF_KnoxGetCalendarsControllerTest() {

        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());

        IF_KnoxGetCalendarsController.InputClass input = new IF_KnoxGetCalendarsController.InputClass();
        input.System_ID     = '00U1s000003NEp2EAG';
        input.userId        = 'hyojinn.lee';
        Map<String, Object> returnMap = IF_KnoxGetCalendarsController.getCalendars(input);
        Integer statusCode  = Util_String.nvlInt( returnMap.get( 'StatusCode'));
        System.assertEquals( statusCode, 200);


        Test.stopTest();
    }
}