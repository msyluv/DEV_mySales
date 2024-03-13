/**
 * @description       : 
 * @author            : chae_ho.yang@samsung.com
 * @group             : 
 * @last modified on  : 12-14-2022
 * @last modified by  : chae_ho.yang@samsung.com
**/
public with sharing class PartnerPrivacyPolicyController {
    @AuraEnabled(cacheable=true)
    public static List<Partner_Privacy_Policy_Master__c> getPartnerPrivacyPolicyVersion() {
        return [SELECT Id, Version__c, T_C_Detail__c FROM Partner_Privacy_Policy_Master__c WHERE T_C_Type__c = 'Privacy Policy' ORDER BY Apply_Date__c DESC];
    }

    @AuraEnabled(cacheable=true)
    public static List<Partner_Privacy_Policy_Master__c> getTermsOfServiceVersion() {
        return [SELECT Id, Version__c, T_C_Detail__c FROM Partner_Privacy_Policy_Master__c WHERE T_C_Type__c = 'Terms of Service' ORDER BY Apply_Date__c ASC];
    }
}