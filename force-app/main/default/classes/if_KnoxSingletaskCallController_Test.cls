/**
* @description       : if_KnoxSingletaskCallController Test Class
* @author            : sbest.han@samsung.com
* @group             : 

* @last modified on  : 05/17/2024
* @last modified by  : sbest.han@samsung.com
* Modifications Log 
* Ver   Date         Author                          Modification
* 1.0   05/17/2023   sbest.han@samsung.com           Initial Version
**/
@isTest(SeeAllData=true)
public class if_KnoxSingletaskCallController_Test {

    @isTest
    static void testGetSingleSchedule() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_SampleMock());
        Event eventObject =[SELECT Id
                              FROM Event 
                             LIMIT 1];
        if_KnoxSingletaskCallController.getSingleknoxSchedule(eventObject.Id);   
       
        Test.stopTest();
    }
}