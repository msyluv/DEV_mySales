@isTest
public class Batch_EccRegCurrencyTypeControllerTest {
    
     public Batch_EccRegCurrencyTypeControllerTest() {    }

    @TestSetup
    static void makeData(){
        
    }

    @isTest
    static void testBatch() {

        Test.startTest();

        Id batchJobId = Database.executeBatch(new Batch_EccRegCurrencyTypeController(), 100);

        Test.stopTest();
    }

    @isTest
    static void testBatchError() {

        Test.startTest();


        Id batchJobId = Database.executeBatch(new Batch_EccRegCurrencyTypeController(), 100);

        Test.stopTest();
    }

}