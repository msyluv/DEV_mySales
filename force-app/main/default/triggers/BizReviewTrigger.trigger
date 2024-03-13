/**
 * @description       : 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-03-17
 * @last modified by  : hj.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2020-12-17   hj.lee@dkbmc.com   Initial Version
**/
trigger BizReviewTrigger on Biz_Review__c (after update) {
    switch on Trigger.operationType {
        when AFTER_UPDATE {
            // 수전위 준비 Activity 비활성 (20201221)
            // completeOpptyAct(Trigger.new, Trigger.oldMap);
        }
    }

    /**
     * 수전위 체크리스트 작성 확정 시 Opportunity Activity Status Completed 변경
     */
    /*
    private static void completeOpptyAct(List<Biz_Review__c> newList, Map<Id, Biz_Review__c> oldMap){
        List<Opportunity_Activity__c> opptyActUpsertList = new List<Opportunity_Activity__c>();
        for(Biz_Review__c n : newList){
            Biz_Review__c o = oldMap.get(n.Id);
            Boolean isOpptyActCompleted = (o.Status__c != 'Confirm' && n.Status__c == 'Confirm');
            if(isOpptyActCompleted) {
                Opportunity_Activity__c opptyActPlanningBO = new Opportunity_Activity__c(
                    TransactionName__c = 'XP33', // 수전위 준비 (Strategy Committee Preparation)
                    WhatId__c = n.Opportunity__c,
                    Status__c = 'Completed'
                );
                opptyActPlanningBO.ExtId__c = OpportunityActivityHelper.generateOpportunityActivityExtKey(opptyActPlanningBO);

                opptyActUpsertList.add(opptyActPlanningBO);
            }
        }

        if(!opptyActUpsertList.isEmpty()) {
            upsert opptyActUpsertList ExtId__c;
        }
    }
    */
}