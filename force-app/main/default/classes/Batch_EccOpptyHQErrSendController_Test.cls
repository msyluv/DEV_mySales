/**
 * @description       : 
 * @author            : yeongju.baek@dkbmc.com
 * @group             : 
 * @last modified on  : 11-09-2021
 * @last modified by  : yeongju.baek@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   10-25-2021   yeongju.baek@dkbmc.com   Initial Version
**/

@isTest
public class Batch_EccOpptyHQErrSendController_Test {

    // Batch_EccOpportunityHQErrSendController 테스트 클래스
    // INTERFACE_ID = 'IF-094';
    // APEX_CLASS   = 'Batch_EccOpportunityHQErrSendController'; 
    // METHOD_NAME  = 'Batch';
    @TestSetup
    static void setup(){

        IF_Callout_TestDataSetup.dataSetup();
        List<Opportunity>   oppList      = [SELECT Id, OpportunityCode__c from Opportunity WHERE Name = 'testOpp1'];
        List<MigOppCode__c> migOppCdList = new List<MigOppCode__c>();
        for( Opportunity opp: oppList){

            MigOppCode__c  migOppCd = new MigOppCode__c(
                 Name               = opp.Id
                ,OpportunityCode__c = opp.OpportunityCode__c
                ,InterfaceId__c     = 'IF-125ERROR'
            );
            migOppCdList.add( migOppCd);
        }
        insert migOppCdList;
    }

    static testMethod  void testBatch1() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));       
        Test.stopTest();

        Id batchJobId = Database.executeBatch(new Batch_EccOpportunityHQErrSendController(), 2000);
    }
    
}