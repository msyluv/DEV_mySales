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
@isTest(SeeAllData=true)
public class IF_KnoxUpdateTaskController_Test {

    @isTest
    static void testUpdateAllDayEventFromMysalesToKnox() {

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_SampleMock());
        Event eventObject =[SELECT Id,
                                   IsAllDayEvent 
                             FROM Event
                            WHERE IsAllDayEvent = TRUE 
                            LIMIT 1];
        IF_KnoxUpdateTaskController.doCalloutSendingUpdatedTaskInfo(eventObject.Id);   
       
        Test.stopTest();
    }

    @isTest
    static void testUpdateNotAllDayEventFromMysalesToKnox() {

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_SampleMock());
        Event eventObject =[SELECT Id,
                                   IsAllDayEvent 
                             FROM Event 
                            WHERE IsAllDayEvent = FALSE
                            LIMIT 1];
        IF_KnoxUpdateTaskController.doCalloutSendingUpdatedTaskInfo(eventObject.Id);   
       
        Test.stopTest();
    }

    
    @isTest
    static void testUpdateRecurrenceEventFromMysalesToKnox() {

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_SampleMock());
        Event eventObject =[SELECT Id,
                                   IsAllDayEvent,
                                   Isrecurrence__c
                             FROM Event 
                            WHERE IsAllDayEvent = FALSE
                              AND Isrecurrence__c = TRUE
                            LIMIT 1];
        IF_KnoxUpdateTaskController.doCalloutSendingUpdatedTaskInfo(eventObject.Id);   
       
        Test.stopTest();
    }
}