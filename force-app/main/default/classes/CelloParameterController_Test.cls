/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 10-24-2023
 * @last modified by  : divyam.gupta@samsung.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   12-30-2020   woomg@dkbmc.com   Initial Version
 * 1.1   2022-11-28   kajal.c@samsumg.com  added opportunity test data
 * 1.2   2023-10-24   divyam.gupta@samsung.com Mysales-331 (Logistics) CP Review logic change.

**/
@isTest
private class CelloParameterController_Test {
    // V1.1 added by kajal
    @TestSetup
    static void setData(){
        Account acc = new Account (
        Name = 'Test123');
        Organization__c org = new Organization__c();
        insert org;
        List<Opportunity> OppList = new List<Opportunity>();
        Opportunity LogiOpportunity = new Opportunity(
            Name = 'MySales1',
            Type = 'New Opportunity',
            CurrencyIsoCode='EUR',
            OpportunityCode__c='SDS-22131801',
            StageName= 'Qualified',
            LogisticsBizDevelopmentType__c = '01',
            Amount = 78,
            BiddingDeadline__c = System.today() + 30,
            //LogisticsServiceType__c = '01',
            LogisticsBizType__c = '02',
            cRevenueStartDate__c = System.today() - 10,
            cRevenueEndDate__c = System.today() + 10,
            AccountId = acc.id,
            LogisticsCustomerType__c = 'SECSET',
            SubIndusrty__c = '01',
            SalesOrganization__c = org.id,
            DeliveryOrganization__c = org.id,
            CloseDate = System.today(),
            Opportunity_Logistics_CPReviewStatus_FIN__c = 'REQ'
            );
        OppList.add(LogiOpportunity);
        insert OppList;
        List<MasterActivity__c> mslist = new List<MasterActivity__c>();
         MasterActivity__c ms = new MasterActivity__c(
              TransactionName__c = '2.4.4',
              IsActive__c = true
         );
        mslist.add(ms);
        MasterActivity__c ms1 = new MasterActivity__c(
              TransactionName__c = '2.4.5.',
              IsActive__c = true
         );
         mslist.add(ms1);
        insert mslist;
          }
    
	@IsTest
	private static void testMethod1() {
        Test.startTest();
        Opportunity oppt = [Select ID from opportunity];
        Id oppID = oppt.id;
        // V 1.2 Changes by Divyam Gupta
        system.debug(CelloParameterController.getCelloParameters('WKS_LBS_REG','NEW', 'FIN', 'BOID', 'BILLTOID',''));
        system.debug(CelloParameterController.getCelloParameters('WKS_CRAS_REG','NEW', 'FIN', 'BOID', 'BILLTOID',''));
         system.debug(CelloParameterController.getCelloParameters('WKS_LOGICP_REG','NEW', 'FIN', 'BOID', 'BILLTOID','REG'));

        CelloParameterController.getExceptionBoolean(oppID);
        Test.stopTest();
    }
}