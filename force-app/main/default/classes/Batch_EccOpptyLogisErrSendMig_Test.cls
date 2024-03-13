/**
 * @description       : 
 * @author            : yeongju.baek@dkbmc.com
 * @group             : 
 * @last modified on  : 11-09-2021
 * @last modified by  : yeongju.baek@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   11-02-2021   yeongju.baek@dkbmc.com   Initial Version
**/
@isTest
public class Batch_EccOpptyLogisErrSendMig_Test {

    @TestSetup
    static void setup(){

        IF_Callout_TestDataSetup.dataSetup();
        List<Opportunity>   oppList      = [SELECT Id, OpportunityCode__c from Opportunity WHERE Name = 'testOpp1'];
        List<MigOppCode__c> migOppCdList = new List<MigOppCode__c>();
        for( Opportunity opp: oppList){

            MigOppCode__c  migOppCd = new MigOppCode__c(
                 Name               = opp.Id
                ,OpportunityCode__c = opp.OpportunityCode__c
                ,InterfaceId__c     = 'IF-094ERROR'
            );
            migOppCdList.add( migOppCd);
        }
        insert migOppCdList;
    }

    static testMethod  void testBatch1() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));       
        Test.stopTest();

        Id batchJobId = Database.executeBatch(new Batch_EccOpptyLogisErrSendController(), 2000);
    }
    
}