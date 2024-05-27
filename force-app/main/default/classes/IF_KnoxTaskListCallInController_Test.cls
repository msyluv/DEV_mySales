/**
* @description       : IF_KnoxTaskListCallInController Test Class
* @author            : sbest.han@samsung.com
* @group             : 

* @last modified on  : 05/17/2024
* @last modified by  : sbest.han@samsung.com
* Modifications Log 
* Ver   Date         Author                          Modification
* 1.0   05/17/2023   sbest.han@samsung.com           Initial Version
**/
@isTest(SeeAllData=true)
private class IF_KnoxTaskListCallInController_Test {

    @isTest
    static void testGetKnoxScheduleList() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        if_KnoxTaskListCallInController.getknoxScheduleList();
        Test.stopTest();
    }

    @isTest
    static void testGetKnoxScheduleListWithErrorCode() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(401));
        if_KnoxTaskListCallInController.getknoxScheduleList();
        Test.stopTest();
    }

    @isTest
    static void testGetKnoxScheduleListWithErrorCode403() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(403));
        if_KnoxTaskListCallInController.getknoxScheduleList();
        Test.stopTest();
    }
}