/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-05-10
 * @last modified by  : hj.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-11-24   younghoon.kim@dkbmc.com   Initial Version
 * 1.1   2021-03-26   leehyo                    [협업 BO 최초 수주품의 Activity 제어] Original KnoxApproval 이 있는경우, Original Knox 로 교체
**/
public class KnoxApprovalHistoryController {
    /*@AuraEnabled
    public static Map<String,Object> init(String opptyId, String opptyActId) {
        System.debug('opptyId : ' + opptyId);
        System.debug('opptyActId : ' + opptyActId);
        return null;
    }*/

    @AuraEnabled
    public static List<KnoxApproval__c> getOpptActyInfo(String opptyId, String opptyactId){
        List<Opportunity_Activity__c> optyactyId = [SELECT Id, TransactionName__c
                                                    FROM Opportunity_Activity__c
                                                    WHERE WhatId__c =:opptyId];

        List<KnoxApproval__c> getApprovalInfo = [SELECT Id
                                                        , Name
                                                        , Status__c
                                                        , MISID__c
                                                        , Cancel_Reason__c
                                                        , CreatedBy.Name
                                                        , CreatedDate
                                                        , CreatedById                                       
                                                        , OriginKnoxApproval__c
                                                        , OriginKnoxApproval__r.Id
                                                        , OriginKnoxApproval__r.Name
                                                        , OriginKnoxApproval__r.Status__c
                                                        , OriginKnoxApproval__r.MISID__c
                                                        , OriginKnoxApproval__r.Cancel_Reason__c
                                                        , OriginKnoxApproval__r.CreatedBy.Name
                                                        , OriginKnoxApproval__r.CreatedDate
                                                        , OriginKnoxApproval__r.CreatedById
                                                 FROM KnoxApproval__c
                                                 WHERE OpportunityActivity__c in : optyactyId AND OpportunityActivity__c =:opptyactId
                                                 ORDER BY CreatedDate DESC];
      
        System.debug('getOpptActyInfo=============================================');
        List<KnoxApproval__c> finalKnoxApprovalHistory = new  List<KnoxApproval__c>();
        for(KnoxApproval__c k : getApprovalInfo){
            if( String.isNotBlank(k.OriginKnoxApproval__c) ) {
                k = k.OriginKnoxApproval__r; // [협업 BO 최초 수주품의 Activity 제어] Original KnoxApproval 이 있는경우, Original Knox 로 교체
            }
            finalKnoxApprovalHistory.add(k);
        }
        System.debug('getOpptActyInfo=============================================');

        return finalKnoxApprovalHistory;
    }

    @AuraEnabled
    public static Map<String, String> getPickList(){
        Map<String, String> pickMap = new Map<String, String>();
        
        Schema.DescribeFieldResult StatusFieldResult = KnoxApproval__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> StatusList = StatusFieldResult.getPicklistValues();
        for (Schema.PicklistEntry Status: StatusList) {
            pickMap.put(String.ValueOf(Status.getValue()), String.ValueOf(status.getLabel()));
        }
        
        return pickMap;
    }
 
}