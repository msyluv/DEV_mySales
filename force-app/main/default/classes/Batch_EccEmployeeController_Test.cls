/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-05-04
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2021-03-22   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class Batch_EccEmployeeController_Test {
    public Batch_EccEmployeeController_Test() {

    }

    @TestSetup
    static void setup(){
        
        List<User> uList = [SELECT Id, UserRole.DeveloperName FROM User WHERE Id = :UserInfo.getUserId()];

        Role_CostCenter__c rc = new Role_CostCenter__c();
        rc.Name = uList.get( 0).UserRole.DeveloperName;
        rc.CostCenter__c = 'T100-12345';
        insert rc;
    }

    static testMethod  void testBatch1() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        Test.stopTest();

        Id batchJobId = Database.executeBatch(new Batch_EccEmployeeController(), 1);
    }


    static testMethod  void testBatch2() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(202));
        Test.stopTest();

        Id batchJobId = Database.executeBatch(new Batch_EccEmployeeController(), 1);
    }
    

    static testMethod  void testBatch3() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));
        Test.stopTest();

        Id batchJobId = Database.executeBatch(new Batch_EccEmployeeController(), 1);
    }    

    private static testMethod void testSchedule(){

        Test.startTest();     
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(202));

        String sch = '0 0 23 * * ?';
        String jobId = System.schedule('Batch_EccEmployeeController_Test', sch, new Batch_EccEmployeeController());         
        Test.stopTest();
    }
}