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
@IsTest(SeeAllData=true)
public class If_KnoxTaskCallInController_Test {

    @isTest
    static void testGetMySalesEventCalendar() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_SampleMock());
        If_KnoxTaskCallInController.getKnoxCalendarList();   
       
        Test.stopTest();
    }

    @isTest
    static void testGetMySalesTaskCalendar() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_SampleMock());
        If_KnoxTaskCallInController.getKnoxCalendarListTask();   
       
        Test.stopTest();
    }

    @isTest
    static void testGetAllCalendars() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_SampleMock());
        If_KnoxTaskCallInController.getAllKnoxCalendarList();   
       
        Test.stopTest();
    }
}