/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-02-01
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2021-01-27   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class Batch_EccOpportunityLogisController_Test {

    // Batch_EccOpportunityLogisController 테스트 클래스
    // INTERFACE_ID = 'IF-094';
    // APEX_CLASS   = 'Batch_EccOpportunityLogisController'; 
    // METHOD_NAME  = 'Batch';

    public Batch_EccOpportunityLogisController_Test() {    }

    @TestSetup
    static void setup(){

        IF_Callout_TestDataSetup.dataSetup();
    }

    static testMethod  void testBatch1() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));       
        Test.stopTest();

        Id batchJobId = Database.executeBatch(new Batch_EccOpportunityLogisController(), 2000);
    }


    static testMethod  void testBatch2() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(202));
        Test.stopTest();

        Id batchJobId = Database.executeBatch(new Batch_EccOpportunityLogisController(), 2000);
    }
    

    static testMethod  void testBatch3() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));
        Test.stopTest();

        Id batchJobId = Database.executeBatch(new Batch_EccOpportunityLogisController(), 2000);
    }    

    private static testMethod void testSchedule(){

        Test.startTest();
        // TriggerSwitch__c trSwitch_default = new TriggerSwitch__c(
        //     All__c = true,
        //     Opportunity__c = true,
        //     OpportunityLogisticsValidation__c = false,  // Stage Validation 해제
        //     OpportunityActivity__c = true
        // );
        // insert trSwitch_default;

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(202));

        String sch = '0 0 23 * * ?';
        String jobId = System.schedule('Batch_EccOpportunityLogisController', sch, new Batch_EccOpportunityLogisController());
        List<CronTrigger> cronTrList = [ SELECT Id FROM CronTrigger WHERE Id = :jobId];
        System.assert( cronTrList.size() > 0);           
        Test.stopTest();
    }    
}