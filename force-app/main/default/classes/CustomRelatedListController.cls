/**
 * @description       : Custom Related List Component (SCP Account)
 * @author            : gitesh.s@samsung.com
 * @group             : 
 * @last modified on  : 20-12-2022
 * @last modified by  : gitesh.s@smsung.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   20-12-2022   gitesh.s@samsung.com   Initial Version
**/
public class CustomRelatedListController {
    @AuraEnabled
    public static String getObjectName(Id recordId) {
        return recordId.getSObjectType().getDescribe().getName();
    }

    @AuraEnabled
    public static List<SCP_Account__c> getCurrentRecord(Id recordId) {
        return [SELECT Name, Contract_Start_Date__c, Customer__c, Incentive__c, Partner__c, SCP_Account_ID__c, SDS_AM__c, SDS_PDM__c FROM SCP_Account__c WHERE Id =: recordId];
    }

    @AuraEnabled
    public static List<MSP_Project__c> getRelatedRecords(Id recordId) {
        return [SELECT Id, Name, Project_Name__c, Estimated_Monthly_Fee_Won__c, New_Business__c, Approve__c FROM MSP_Project__c WHERE SCP_Account_ID__c =: recordId LIMIT 6];
    }

    @AuraEnabled
    public static List<MSP_Project__c> getMSPRecord(Id recordId) {
        return [SELECT Id, Name, Project_Name__c, Project_Summary__c, Partner_AM__c, Partner_PM__c, Estimated_Monthly_Fee_Won__c, New_Business__c FROM MSP_Project__c WHERE Id =: recordId];
    }

    @AuraEnabled
    public static void deleteMSPRecord(Id recordId) {
        List<MSP_Project__c> record = [SELECT Id FROM MSP_Project__c WHERE Id =: recordId];
        delete record;
    }

    @AuraEnabled
    public static Boolean checkApprovalStatus(Id recordId) {
        return Approval.isLocked(recordId);
    }

    @AuraEnabled
    public static Profile getProfileInfo() {
        String profileId = UserInfo.getProfileId();
        Profile profile = [SELECT Id, Name FROM Profile WHERE Id =:profileId];
        return profile;
    }
}