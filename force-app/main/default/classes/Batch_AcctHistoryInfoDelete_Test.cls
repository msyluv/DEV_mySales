/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-27
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2021-01-25   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class Batch_AcctHistoryInfoDelete_Test {
    public Batch_AcctHistoryInfoDelete_Test() {

    }

    @TestSetup
    static void makeData(){
        Account acc = new Account(
            Name = 'AccTest'
        );
        
        insert acc;

        AccountHistory__c acctHistory = new AccountHistory__c(ExternalId__c='test1', Account__c=acc.Id, BizRegNo__c='test', InformationSource__c='OPENDART', HistoryDate__c='20210101', Description__c='test');
        insert acctHistory;
    }

    @isTest
    static void testBatch() {

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Id batchJobId = Database.executeBatch(new Batch_AcctHistoryInfoDeleteController(), 100);

        Test.stopTest();
    }

    @isTest
    static void testBatchError() {

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        Id batchJobId = Database.executeBatch(new Batch_AcctHistoryInfoDeleteController(), 100);

        Test.stopTest();
    }

    @isTest
    static void testBatchSchedule() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Batch_AcctHistoryInfoDeleteController controller = new Batch_AcctHistoryInfoDeleteController();
        String sch = '0 0 23 * * ?';
        system.schedule('Batch_AcctHistoryInfoDeleteController', sch, controller);

        //System.assertEquals(String.valueOf(result.get('EV_RESULT')), 'S');

        Test.stopTest();
    }
}