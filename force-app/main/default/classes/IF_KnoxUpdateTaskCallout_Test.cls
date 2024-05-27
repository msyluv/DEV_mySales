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
public class IF_KnoxUpdateTaskCallout_Test {

    @isTest
    static void testUpdateTaskFromMysalesToKnox() {

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_SampleMock());
        Task taskObject =[SELECT Id
                              FROM Task 
                             LIMIT 1];
        IF_KnoxUpdateTaskCallout.doCalloutSendingUpdatedTasktoknox(taskObject.Id);   
       
        Test.stopTest();
    }

}