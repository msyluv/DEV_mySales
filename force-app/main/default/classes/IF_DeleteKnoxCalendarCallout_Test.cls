/**
* @description       : IF_KnoxUpdateTaskController Test Class
* @author            : sbest.han@samsung.com
* @group             : 

* @last modified on  : 05/17/2024
* @last modified by  : sbest.han@samsung.com
* Modifications Log 
* Ver   Date         Author                          Modification
* 1.0   05/17/2023   sbest.han@samsung.com           Initial Version
**/
@isTest
private class IF_DeleteKnoxCalendarCallout_Test {

    @isTest
    static void testDeleteCalendar() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        IF_DeleteKnoxCalendarCallout.deleteKnoxTaskcalendarId();
        Test.stopTest();
    }
    
    @isTest
    static void testDeleteCalendarWithErrorCode() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(401));
        IF_DeleteKnoxCalendarCallout.deleteKnoxTaskcalendarId();
        Test.stopTest();
    }
}