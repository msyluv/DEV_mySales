/**
 * @description       : 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-03-03
 * @last modified by  : hj.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2021-01-27   hj.lee@dkbmc.com   Initial Version
**/
public without sharing class KnoxApprovalActivityNewController {
    public KnoxApprovalActivityNewController() {}

    
    /**
     * @param recordId          Quick Action RecordId
     * @param transactionName   생성할 Activity Transaction Code
     */
    @AuraEnabled
    public static Map<String, Object> initComponent(Id recordId, String transactionName){
        Map<String, Object> responseMap = new Map<String, Object>{
            'opptyId'  => '',                   // Opportunity Id
            'opptyActId'  => '',                // Opportunity Activity Id
            'isPendingKnoxApproval' => false    // Activity에서 현재 진행중인 결재 여부
        };
        
        try {
            /**
             * 1. get Opportunity Id
             */
            String opptyId = '';
            
            String sObjectName = recordId.getSObjectType().getDescribe().getName();
            switch on sObjectName {
                when 'Opportunity' {
                    opptyId = recordId;
                }
                when 'Biz_Review__c' { // Strategy Committee
                    opptyId = [SELECT Id, Opportunity__c FROM Biz_Review__c WHERE Id = :recordId].Opportunity__c;                    
                }
                when else {
                }
            }

            /**
             * 2. get Activity Check & Upsert
             */
            String opptyActId = '';

             List<Opportunity_Activity__c> opptyActList = [
                SELECT Id 
                FROM Opportunity_Activity__c 
                WHERE WhatId__c = :opptyId AND transactionName__c = :transactionName
            ];
            if(opptyActList.size() == 0){
                opptyActId = upsertOpportunityActivity(opptyId, transactionName);

            } else {
                opptyActId = opptyActList[0].Id;
            }


            /**
             * 3. Activity에 진행중인 Knox Approval가 있는지 확인
             */
            Boolean isPendingKnoxApproval = false;
            String knoxPendingStatus = '1';
            List<KnoxApproval__c> pendingApprovalList = [
                SELECT  Id, Status__c
                FROM    KnoxApproval__c
                WHERE   OpportunityActivity__c = :opptyActId
                        AND Status__c = :knoxPendingStatus
            ];
            if(pendingApprovalList.size() > 0){
                isPendingKnoxApproval = true;
            }

            responseMap.put('opptyId', opptyId);
            responseMap.put('opptyActId', opptyActId);
            responseMap.put('isPendingKnoxApproval', isPendingKnoxApproval);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return responseMap;
    }

    /* OpportunityActivity 생성 */
    public static String upsertOpportunityActivity(String opptyId, String transactionName){
        
        String opptyActId = '';
        try {
            Opportunity_Activity__c opptyAct = new Opportunity_Activity__c(
                WhatId__c = opptyId,
                TransactionName__c = transactionName,
                ExtId__c = opptyId + '_' + transactionName
            );
            
            System.debug('### FIND Drop Activity Create :: KnoxApprovalActivityNewController :: upsertOpportunityActivity');
    
            Upsert opptyAct ExtId__c;
            opptyActId = opptyAct.Id;

        } catch (Exception e){    
            System.debug(' e.getMessage() : ' + e.getMessage());
        }

        return opptyActId;
    }
}