/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-08-2021
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   01-08-2021   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class Batch_ApsOpptyCopyController_Test {

    // Batch_ApsOpptyCopyController 테스트 클래스
    // INTERFACE_ID = 'IF-094';
    // APEX_CLASS   = 'Batch_ApsOpptyCopyController';
    // METHOD_NAME  = 'Batch';

    public Batch_ApsOpptyCopyController_Test() {    }

    @TestSetup
    static void makeData(){
        IF_Callout_TestDataSetup.dataSetup();        
    }

    @isTest
    static void testBatch() {

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));        
        
        Test.stopTest();

        Id batchJobId = Database.executeBatch(new Batch_ApsOpptyCopyController(), 2000);
    }    
}