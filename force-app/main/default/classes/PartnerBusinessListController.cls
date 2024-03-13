/**
 * @description       : 
 * @author            : zenith21c@test.com
 * @group             : 
 * @last modified on  : 03-22-2022
 * @last modified by  : zenith21c@test.com
**/
public with sharing class PartnerBusinessListController {
    @AuraEnabled(cacheable=true)
    public static List<Partner_Business_Management__c> getPartnerBusinessList() {
        return [select Id
                    , Project_Name__c
                    , Name
                    , Partner_Sales__c
                    , Scheduled_Service_Opening_Date__c
                    , Partner_Account__c
                from Partner_Business_Management__c
                order by Scheduled_Service_Opening_Date__c desc
                limit 3];
    }
}