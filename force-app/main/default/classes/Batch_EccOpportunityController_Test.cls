/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-02-01
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-12-17   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class Batch_EccOpportunityController_Test  {

    // Batch_EccOpportunityController 테스트 클래스
    // private static final String INTERFACE_ID = 'IF-125';
    // private static final String APEX_CLASS   = 'Batch_EccOpportunityController'; 
    // private static final String METHOD_NAME  = 'Batch';
        
    public Batch_EccOpportunityController_Test() {    }

    @TestSetup
    static void setup(){

        IF_Callout_TestDataSetup.dataSetup();
    }

    static testMethod  void testBatch1() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        Test.stopTest();

        Id batchJobId = Database.executeBatch(new Batch_EccOpportunityController(), 2000);
    }


    static testMethod  void testBatch2() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(202));
        Test.stopTest();

        Id batchJobId = Database.executeBatch(new Batch_EccOpportunityController(), 2000);
    }
    

    static testMethod  void testBatch3() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));
        Test.stopTest();

        Id batchJobId = Database.executeBatch(new Batch_EccOpportunityController(), 2000);
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

        // IF_Callout_TestDataSetup.dataSetup();
        String sch = '0 0 23 * * ?';
        String jobId = System.schedule('Batch_EccOpportunityController', sch, new Batch_EccOpportunityController());
        List<CronTrigger> cronTrList = [ SELECT Id FROM CronTrigger WHERE Id = :jobId];
        System.assert( cronTrList.size() > 0);           
        Test.stopTest();
    }
}