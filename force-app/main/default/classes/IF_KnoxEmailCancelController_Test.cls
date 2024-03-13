/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2020-12-29
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   12-29-2020   soohong0.kim@partner.samsung.com   Initial Version
**/
@isTest
private class IF_KnoxEmailCancelController_Test {
    private static testMethod void IF_KnoxEmailCancelControllerTest() {

        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());


        IF_KnoxEmailCancelController.InputClass input = new IF_KnoxEmailCancelController.InputClass();
        input.mailId = '20201119012141nwcms1s165d85e91072731e41c8c805c0ad5dccb';
        input.sfdcId = 'test';
        input.userId = 'hyojinn.lee';
        
        List<String> strList = new List<String>();
        strList.add('hyojinn.lee@stage.partner.samsung.com');
        input.recipients = strList;
        Map<String, Object> returnMap = IF_KnoxEmailCancelController.cancelMail(input);

        Integer statusCode  = Util_String.nvlInt( returnMap.get( 'StatusCode'));
        System.assertEquals( statusCode, 200);
        /*{
  "result": "success",
  "statusCode": "200"
}
*/


        Test.stopTest(); 
    }
}