/**
* @description       : 
* @author            : akash.g@samsung.com
* @group             : 
* @last modified on  : 2023-03-20
* @last modified by  : akash.g@samsung.com
* Modifications Log 
* Ver   Date         Author                         Modification
* 1.0   2023-03-20   akash.g@samsung.com   Initial Version (MySales -147)
**/
@isTest
public class Batch_IF180calloutTest {
    @TestSetup
    static void setup(){
        
        IF_Callout_TestDataSetup.dataSetup();
        List<Opportunity>   oppList      = [SELECT Id, OpportunityCode__c from Opportunity WHERE Name = 'testOpp1'];
        List<BO_Activity_Complete__c> migOppCdList = new List<BO_Activity_Complete__c>();
        for( Opportunity opp: oppList){
            
            BO_Activity_Complete__c  migOppCd = new BO_Activity_Complete__c(
                Name               = opp.Id
                ,OpportunityCode__c = opp.OpportunityCode__c
                ,InterfaceId__c     = 'IF-180'
            );
            migOppCdList.add( migOppCd);
        }
        insert migOppCdList;
    }
    
    static testMethod  void testBatch1() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));       
        Test.stopTest();
        
        Id batchJobId = Database.executeBatch(new Batch_IF180callout(), 2000);
    }
    
}