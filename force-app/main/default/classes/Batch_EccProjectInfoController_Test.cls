/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-04-30
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2021-01-05   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class Batch_EccProjectInfoController_Test {

    // Batch_EccProjectInfoController 테스트 클래스
    // INTERFACE_ID = 'IF-004'; // IF-004 (IF_EccProjectInfoController을 호출하는 Batch)
    // APEX_CLASS   = 'Batch_EccProjectInfoController'; 
    // METHOD_NAME  = 'Batch';

    public Batch_EccProjectInfoController_Test() {    }

    @TestSetup
    static void makeData(){

    }

    @isTest
    static void testBatch() {    
        Test.startTest();

        IF_Callout_TestDataSetup.dataSetup();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Id batchJobId = Database.executeBatch(new Batch_EccProjectInfoController(), 2000);

        Test.stopTest();
    }


    private static testMethod void testSchedule(){

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(202));

        String sch = '0 0 23 * * ?';
        String jobId = System.schedule('01_Batch_EccProjectInfoController', sch, new Batch_EccProjectInfoController());
        List<CronTrigger> cronTrList = [ SELECT Id FROM CronTrigger WHERE Id = :jobId];
        System.assert( cronTrList.size() > 0);           
        Test.stopTest();
    }       
}