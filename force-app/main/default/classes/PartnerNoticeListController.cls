/**
 * @description       : 
 * @author            : zenith21c@test.com
 * @group             : 
 * @last modified on  : 03-22-2022
 * @last modified by  : zenith21c@test.com
**/
public with sharing class PartnerNoticeListController {
    @AuraEnabled(cacheable=true)
    public static List<Partner_Notice__c> getPartnerNoticeList() {
        return [SELECT Id, Name, Subject__c, StartDate__c, EndDate__c FROM Partner_Notice__c 
                WHERE Active_InActive__c =: true AND StartDate__c <= TODAY AND EndDate__c >= TODAY ORDER BY CreatedDate DESC limit 3];
    }
}