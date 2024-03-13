/**
 * @description       : 
 * @author            : kilhwan.an@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-05-26
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2021-05-17   kilhwan.an@partner.samsung.com   Initial Version
**/
@isTest
public class Batch_EccOpportunityHQMigController_Test {
    @TestSetup
    static void setup(){

        IF_Callout_TestDataSetup.dataSetup();

        Opportunity opp = [SELECT Id, OpportunityCode__c FROM Opportunity LIMIT 1];
        MigOppCode__c migCd = new MigOppCode__c();
        migCd.Name = opp.Id;
        migCd.OpportunityCode__c = opp.OpportunityCode__c;
        migCd.InterfaceId__c = 'IF-125';
        insert migCd;


    }

    static testMethod  void testBatch1() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        Test.stopTest();

        Id batchJobId = Database.executeBatch(new Batch_EccOpportunityHQMigController(), 2000);
    }


    static testMethod  void testBatch2() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(202));
        Test.stopTest();

        Id batchJobId = Database.executeBatch(new Batch_EccOpportunityHQMigController(), 2000);
    }
    

    static testMethod  void testBatch3() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));
        Test.stopTest();

        Id batchJobId = Database.executeBatch(new Batch_EccOpportunityHQMigController(), 2000);
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
        String jobId = System.schedule('Batch_EccOpportunityHQMigController', sch, new Batch_EccOpportunityHQMigController());
        List<CronTrigger> cronTrList = [ SELECT Id FROM CronTrigger WHERE Id = :jobId];
        System.assert( cronTrList.size() > 0);           
        Test.stopTest();
    }
}