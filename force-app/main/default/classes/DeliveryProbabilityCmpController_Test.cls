/**
 * @description       : 
 * @author            : vikrant.ks@samsung.com
 * @group             : 
 * @last modified on  : 02-26-2024
 * @last modified by  : vikrant.ks@samsung.com
 * Modifications Log 
 * Ver   Date         Author            			   Modification
 * 1.0   02-26-2024   vikrant.ks@samsung.com           Initial Version (MYSALES-447)
**/
@isTest
public class DeliveryProbabilityCmpController_Test {
    static Opportunity opptyHQ;
    static RecordType RT_OPPTY_HQ = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
    
    Static{
        opptyHQ = new Opportunity(
            Name = 'Test Opportunity',
            OpportunityCode__c = 'SDS-23205170',
            RecordTypeId = RT_OPPTY_HQ.Id,
            StageName = 'Z02',
            CloseDate = Date.today()
        );
        insert opptyHQ;
    }
    @IsTest
    private static void testMethod1() {
        Test.startTest();
        DeliveryProbabilityCmpController.DeliveryProbabilityList(opptyHQ.Id);
        Test.stopTest();
    }
}