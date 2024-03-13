/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-18
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2021-01-18   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class Batch_ProfitLossDeleteController_Test {
    public Batch_ProfitLossDeleteController_Test() {

    }

    @TestSetup
    static void makeData(){
        ProfitLoss__c profitLoss = new ProfitLoss__c(BizYear__c='2021', Version__c='000', REAL_FLAG2__c='R');
        insert profitLoss;
    }

    @isTest
    static void testBatch() {

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Id batchJobId = Database.executeBatch(new Batch_ProfitLossDeleteController(), 2000);

        Test.stopTest();
    }

    @isTest
    static void testCallout() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Batch_ProfitLossDeleteController controller = new Batch_ProfitLossDeleteController();
        String sch = '0 0 23 * * ?';
        system.schedule('Batch_ProfitLossDeleteController', sch, controller);

        //System.assertEquals(String.valueOf(result.get('EV_RESULT')), 'S');

        Test.stopTest();
    }

    @isTest
    static void testBatchError() {

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        Id batchJobId = Database.executeBatch(new Batch_ProfitLossDeleteController(), 2000);

        Test.stopTest();
    }
}