/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-02-03
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2021-02-03   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class IF_SdGetConfirmInfoController_Test {

    private static testMethod void IF_SdGetConfirmInfoControllerTest() {

        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());

        IF_SdGetConfirmInfoController.InputClass input = new IF_SdGetConfirmInfoController.InputClass();
        input.IV_ZZORDER_ID     = 'SDS-20017820';
        input.IV_VERSION        = 'F001';
        input.IV_BUKRS          = 'T100';
        Map<String, Object> returnMap = IF_SdGetConfirmInfoController.getInfo(input);
        Integer statusCode  = Util_String.nvlInt( returnMap.get( 'StatusCode'));
        System.assertEquals( statusCode, 200);


        Test.stopTest();
    }

    
}