/**
* @description       : IF_KnoxTaskCallOutAPIController Test Class
* @author            : sbest.han@samsung.com
* @group             : 

* @last modified on  : 05/17/2024
* @last modified by  : sbest.han@samsung.com
* Modifications Log 
* Ver   Date         Author                          Modification
* 1.0   05/17/2023   sbest.han@samsung.com           Initial Version
**/
@isTest(SeeAllData=true)
private class IF_KnoxTaskCallOutAPIController_Test {

    @isTest
    static void testCreateMysalesEventCalendar() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_SampleMock());
        Event eventObject =[SELECT Id
                             FROM Event
                            LIMIT 1];
        IF_KnoxTaskCallOutAPIController.doCalloutCreatemySalesKnoxCalender(eventObject.Id);   
       
        Test.stopTest();
    }


    @isTest
    static void testCreateMysalesTaskCalendar() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_SampleMock());
        IF_KnoxTaskCallOutAPIController.doCalloutCreatemySalesKnoxCalenderTask();   
       
        Test.stopTest();
    }
}