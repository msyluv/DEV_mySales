/**
 * @description       : 
 * @author            : gitesh.s@samsung.com
 * @group             : 
 * @last modified on  : 28-10-2022
 * @last modified by  : gitesh.s@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   28-10-2022   gitesh.s@samsung.com      Intial Version
**/
public class OpportunityActivityLinkButtonController {
    @AuraEnabled
    public static String getRecordTypeHQ() {
        return Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HQ').getRecordTypeId();
    }
    @AuraEnabled
    public static String getRecordTypeLogistics() {
        return Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Logistics').getRecordTypeId();
    }
    @AuraEnabled
    public static Boolean checkOrg() {
        return [SELECT Id, IsSandbox, Name FROM Organization LIMIT 1].IsSandBox;
    }
}