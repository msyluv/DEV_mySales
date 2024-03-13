/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-08-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   12-29-2020   soohong0.kim@partner.samsung.com   Initial Version
**/
@isTest
private class IF_KnoxDeleteScheduleController_Test {
    //IF-072
    private static testMethod void IF_KnoxDeleteScheduleControllerTest() {

        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());

        IF_KnoxDeleteScheduleController.InputClass input = new IF_KnoxDeleteScheduleController.InputClass();
        input.System_ID  = '00U1s000003NEp2EAG';
        input.calendarId = 'CAL202012090105406736306323';
        input.scheduleId = 'SCH202012220806182504025420';
        input.userId     = 'hyojinn.lee';
        
        Map<String, Object> returnMap = IF_KnoxDeleteScheduleController.deleteSchedule(input);
        Integer statusCode = Util_String.nvlInt( returnMap.get( 'StatusCode'));
        System.assertEquals( statusCode, 200);
/*
{
  "result": "success",
  "data": {
    "result": "SUCCESS"
  },
  "statusCode": "200"
}
*/        

        Test.stopTest();
    }
}