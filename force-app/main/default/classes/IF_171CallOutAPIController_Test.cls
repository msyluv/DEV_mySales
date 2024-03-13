/**
* @author            : anish.jain@partner.samsung.com
* @description       : [IF-171] BO_실주중도종결_정보전송
*                     : Test Class coverage for Interface call for 'Save' button on Service/Solution tab of Review Opportunity
* @last modified on  : 2022-11-12
* @last modified by  : anish.jain@partner.samsung.com
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2022-11-08   anish.jain@partner.samsung.com  Initial Version
**/

@isTest
public class IF_171CallOutAPIController_Test {
    final static String REQUEST_URL = '/services/apexrest/WebService/IF171';
    static Opportunity oppty;
    public static Opportunity LogiOpportunity;
    @TestSetup
    static void setData(){

        LogiOpportunity = new Opportunity(
            Name = 'MySales12',
            CurrencyIsoCode='EUR',
            OpportunityCode__c='SDS-22131801',
            CloseDate = System.today() + 30,
            StageName= 'Z01',
            Amount = 78,
            CspMspType__c = 'N/A'
        );
        
        insert LogiOpportunity;
        
    }
    @isTest
    static void restServiceCatchTest() {
        Test.startTest();
        oppty = [Select ID from opportunity limit 1];
        System.debug('Opportunity id is :' +oppty.Id);
        IF_171CallOutAPIController.doCalloutSendingReviewOpportunityInfo(oppty.Id);
        Test.stopTest();
    }
}