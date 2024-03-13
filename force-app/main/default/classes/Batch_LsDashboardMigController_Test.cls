/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-05-26
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2021-05-26   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class Batch_LsDashboardMigController_Test {


    @TestSetup
    static void setup(){

        IF_Callout_TestDataSetup.dataSetup();
        List<Opportunity>   oppList      = [SELECT Id, OpportunityCode__c from Opportunity WHERE Name = 'testOpp1'];
        List<MigOppCode__c> migOppCdList = new List<MigOppCode__c>();
        for( Opportunity opp: oppList){

            MigOppCode__c  migOppCd = new MigOppCode__c(
                 Name               = opp.Id
                ,OpportunityCode__c = opp.OpportunityCode__c
                ,InterfaceId__c     = 'IF-042'
            );
            migOppCdList.add( migOppCd);
        }
        insert migOppCdList;
    }

    static testMethod  void testBatch1() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));       
        Test.stopTest();

        Id batchJobId = Database.executeBatch(new Batch_LsDashboardMigController(), 2000);
    }

}