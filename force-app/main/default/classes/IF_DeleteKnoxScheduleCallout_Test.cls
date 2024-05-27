/**
* @description       : IF_DeleteKnoxScheduleCallout Test Class
* @author            : sbest.han@samsung.com
* @group             : 

* @last modified on  : 05/17/2024
* @last modified by  : sbest.han@samsung.com
* Modifications Log 
* Ver   Date         Author                          Modification
* 1.0   05/17/2023   sbest.han@samsung.com           Initial Version
**/
@IsTest(SeeAllData=true)
public class IF_DeleteKnoxScheduleCallout_Test {

    @isTest
    static void testDeleteKnoxSchedule() {
        Event eventObj = [SELECT Id,
                                 Knox_Schedule_ID__c,
                                 Knox_Calendar_Id__c
                            FROM Event 
                           WHERE Knox_Schedule_ID__c != null 
                             AND Knox_Calendar_Id__c != null 
                           LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_SampleMock());
        IF_DeleteKnoxScheduleCalloutController.deleteSingleKnoxSchedule(eventObj.Knox_Schedule_ID__c, eventObj.Knox_Calendar_Id__c);
        Test.stopTest();                            
    }
}