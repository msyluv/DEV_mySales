/**
 * @description       : 
 * @author            : wonjune.oh@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-03-11
 * @last modified by  : hj.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-25   wonjune.oh@partner.samsung.com   Initial Version
 * 1.1   2021-01-28   Junghwa.Kim@dkbmc.com            sendKnoxEmail 메소드 추가
**/
public without sharing class VRBRequest {

    @AuraEnabled
    public static List<VRBRequest__c> initComponent(String parentActivityId){
        List<VRBRequest__c> vrbRequestList;
        try{
            vrbRequestList = [ 
                SELECT Id, Business_Level__c, VRBMethod__c, VRBDueDate__c, OwnerId, Owner.Name, Name ,Biz_Review__c,Biz_Review__r.Name
                      ,VRBRequester__c, VRBRequester__r.Name, Description__c, CreatedDate, Opportunity_Activity__r.Status__c
                FROM VRBRequest__c
                WHERE Opportunity_Activity__c = :parentActivityId
                ORDER BY CreatedDate DESC ];

        } catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage());
        }

        return vrbRequestList;
    }

    @AuraEnabled
    public static List<OpportunityTeamMember> getTeamMemberList(String oppId){
        List<OpportunityTeamMember> ot = new List<OpportunityTeamMember>();
        try {
            ot = [SELECT UserId, User.Name FROM OpportunityTeamMember WHERE OpportunityId = :oppId AND TeamMemberRole = 'Strategy Committee Manager'];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return ot;
    }
    
    @AuraEnabled
    public static void changeVRBOwner(String vrbRequestId){
        try {
            VRBRequest__c vrbRequest = [SELECT Id, OwnerId, VRBOwner__c FROM VRBRequest__C WHERE Id = :vrbRequestId];
            vrbRequest.OwnerId = vrbRequest.VRBOwner__c;
            
            update vrbRequest;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * VRBRequest__c Object ObjectLabel, FieldLabel 반환
     */
    @AuraEnabled
    public static Map<String, String> getLabel(String apiName){
        Map<String, String> labelMap = Utils.getFieldLabel(apiName);
        labelMap.put('ObjectLabel', Utils.getObjectLabel(apiName));
        
        return labelMap;
    }

    // sendKnoxEmail 추가 2021/01/28
    @AuraEnabled
    public static void sendKnoxEmail(String recordId){
        try {
            OpportunityEmailAlertController.StrategyCommitteeRequestEmailSend(recordId);
        } catch (Exception e) {
            throw new AuraHandledException('Send Knox Email : ' + e.getMessage());
        }
    }
}