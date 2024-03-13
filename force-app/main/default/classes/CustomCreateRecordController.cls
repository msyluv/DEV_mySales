/**
 * @description       : Create Custom Record (For SCP Account and MSP Project)
 * @author            : gitesh.s@samsung.com
 * @group             : 
 * @last modified on  : 18-11-2022
 * @last modified by  : gitesh.s@smsung.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   18-11-2022   gitesh.s@samsung.com   Initial Version
**/
public class CustomCreateRecordController {
    @AuraEnabled
    public static Id getPartnershipInfo(Id recordId) {
        return [SELECT Id, Name FROM Employee__c WHERE Id IN (
                SELECT SDS_PDM__c FROM Partnership_Info__c WHERE Account__c =: recordId)].Id;
    }

    @AuraEnabled
    public static List<SCP_Account__c> getSCPAccountInfo(Id recordId) {
        return [SELECT Id, Name, Customer__c, Partner__c, Contract_Start_Date__c, Incentive__c, SDS_AM__c, SDS_PDM__c FROM SCP_Account__c WHERE Id =: recordId];
    }

    @AuraEnabled
    public static Boolean getPartnerAccount(Id recordId) {
        return [SELECT Id, IsPartner FROM Account WHERE Id =: recordId].IsPartner;
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