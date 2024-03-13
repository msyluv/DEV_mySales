/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-08-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   11-24-2020   soohong0.kim@partner.samsung.com   Initial Version
**/
@isTest
private  class IF_SdCheckResaleClosingController_Test {
    //IF-049
    private static testMethod void IF_SdCheckResaleClosingControllerTest() {

        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());

        IF_SdCheckResaleClosingController.InputClass inClass = new IF_SdCheckResaleClosingController.InputClass();
        inClass.IV_PSPID = 'SMC20019661A000';

        Map<String, Object> returnMap = IF_SdCheckResaleClosingController.checkResaleClosing( inClass);
        Integer statusCode = Util_String.nvlInt( returnMap.get( 'StatusCode'));

        System.debug( 'returnMap::::' + returnMap);
        System.assertEquals( statusCode, 200);
        
        Test.stopTest();
    }
}