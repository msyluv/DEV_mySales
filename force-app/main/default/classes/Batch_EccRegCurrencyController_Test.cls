/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-21
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-12-23   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class Batch_EccRegCurrencyController_Test {

    // Batch_EccRegCurrencyController 테스트 클래스
    // private final String INTERFACE_ID    = 'IF-017';
    // private final String APEX_CLASS      = 'Batch_EccRegCurrencyController';
    // private final String METHOD_NAME     = 'Batch';    

    public Batch_EccRegCurrencyController_Test() {    }

    @TestSetup
    static void makeData(){
        
    }

    @isTest
    static void testBatch() {

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Id batchJobId = Database.executeBatch(new Batch_EccRegCurrencyController(), 2000);

        Test.stopTest();
    }

    @isTest
    static void testBatchError() {

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        Id batchJobId = Database.executeBatch(new Batch_EccRegCurrencyController(), 2000);

        Test.stopTest();
    }

}