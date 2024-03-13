/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-02-18
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2021-02-18   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class Batch_InterfaceLogDeleteController_Test {
    
    // Batch_InterfaceLogDeleteController 테스트 클래스
    // INTERFACE_ID = 'IF-000';
    // APEX_CLASS   = 'Batch_InterfaceLogDeleteController';
    // METHOD_NAME  = 'Batch'; 

    public Batch_InterfaceLogDeleteController_Test() {    }

    @TestSetup
    static void makeData(){
        IF_Log__c insertLog = new IF_Log__c(
            LogType__c = 'Interface'
            , InterfaceId__c = 'IF-000'
        );

        Insert insertLog;
    }    
    
    @isTest
    static void testBatch1() {
        Test.startTest();

        Batch_InterfaceLogDeleteController batch = new Batch_InterfaceLogDeleteController();
        // batch.BATCH_CONDITION = date.valueOf('2020-11-04T00:00:00Z');
        batch.BATCH_CONDITION = date.valueOf(system.today().addDays(1));
        Id batchJobId = Database.executeBatch(batch, 2000);

        Test.stopTest();
    }

    @isTest
    static void testBatch2() {
        Test.startTest();

        Id batchJobId = Database.executeBatch(new Batch_InterfaceLogDeleteController(), 2000);

        Test.stopTest();
    }    
}