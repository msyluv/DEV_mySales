/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-02-01
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-12-29   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class Batch_LsWeeklyReportController_Test {

    // Batch_LsWeeklyReportController 테스트 클래스
    // INTERFACE_ID = 'IF-127';
    // APEX_CLASS   = 'Batch_LsWeeklyReportController';
    // METHOD_NAME  = 'Batch';    

    public Batch_LsWeeklyReportController_Test() {    }

    @TestSetup
    static void makeData(){

        IF_Callout_TestDataSetup.dataSetup();
    }

    @isTest
    static void testBatch1() {

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Id batchJobId = Database.executeBatch(new Batch_LsWeeklyReportController(), 2000);

        Test.stopTest();
    }

    @isTest
    static void testBatch2() {

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(202));

        Id batchJobId = Database.executeBatch(new Batch_LsWeeklyReportController(), 2000);

        Test.stopTest();
    }

    @isTest
    static void testBatch3() {

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        Id batchJobId = Database.executeBatch(new Batch_LsWeeklyReportController(), 2000);

        Test.stopTest();
    }    

    @isTest
    static void testSchedule() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(202));

        String sch = '0 0 23 * * ?';
        String jobId = System.schedule('Batch_LsWeeklyReportController', sch, new Batch_LsWeeklyReportController());
        List<CronTrigger> cronTrList = [ SELECT Id FROM CronTrigger WHERE Id = :jobId];
        System.assert(cronTrList.size() > 0);

        Test.stopTest();
    }
}