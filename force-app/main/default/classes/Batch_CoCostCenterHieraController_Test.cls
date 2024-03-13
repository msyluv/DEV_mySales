/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-03-30
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2020-12-22   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class Batch_CoCostCenterHieraController_Test {
    public Batch_CoCostCenterHieraController_Test() {

    }

    @TestSetup
    static void setup(){
        Company__c company = new Company__c();
        company.Name = 'test';
        insert company;

        CostCenter__c cCenter = new CostCenter__c();
        cCenter.CostCenter__c = 'test12';
        cCenter.CostCenterName__c = 'test12';
        cCenter.Company__c = company.id;
        insert cCenter;
    }

    @isTest
    static void testBatch() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        Test.stopTest();

        Id batchJobId = Database.executeBatch(new Batch_CoCostCenterHieraController(), 500);        
    }
}