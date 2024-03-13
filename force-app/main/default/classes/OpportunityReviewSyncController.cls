/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 09-15-2023 
 * @last modified by  : anish.jain@partner.samsung.com
 * 1.1   09-15-2023     anish.jain@partner.samsung.com  BO Review Confirm error on CollaborationBO - MS -298
**/
public without sharing class OpportunityReviewSyncController implements Queueable {
    public Id oppIDList;
    public OpportunityReviewSyncController(Id oppId) {
        system.debug('Akash3 Test');
        oppIDList = oppId;
        system.debug('oppIDList'+oppIDList);
    }
    
    public void execute(QueueableContext context){
        syncVRBType(oppIDList);
    }
    
    public static void syncVRBType(Id oppId){
        Opportunity opportunity = [Select Id,Opportunity_Review_Confirm__c,OpportunityCode__c,CompanyCode__c, Opportunity_Review_VRB_Type__c, Opportunity_Review_VRB_Type_Confirm__c
                                        FROM Opportunity where Id = : oppId];
        
        List<Opportunity> subsOpportunities = [SELECT Id, Opportunity_Review_Confirm__c, Opportunity_Review_VRB_Type__c, Opportunity_Review_VRB_Type_Confirm__c
                                        FROM Opportunity
                                        WHERE OpportunityCode__c =:opportunity.OpportunityCode__c
                                        AND CompanyCode__c !=:opportunity.CompanyCode__c
                                        AND Collaboration__c = true];

        if(subsOpportunities.size() > 0){
            System.debug('RBO Entry1');
            Opportunity subsOpportunity = subsOpportunities[0];
            System.debug('RBO Entry1 : ' + subsOpportunity.Id);            
            //1. 법인, 본사 모두 사업심의유형을 확정한 상태에서만 싱크를 맞춘다. 
            //2. 특수 케이스. 본사:21, 법인:20or30일 경우 법인 21로 업데이트
            if(opportunity.Opportunity_Review_Confirm__c && subsOpportunity.Opportunity_Review_Confirm__c 
            && opportunity.Opportunity_Review_VRB_Type_Confirm__c != null && subsOpportunity.Opportunity_Review_VRB_Type_Confirm__c != null){
                if('21'.equals(opportunity.Opportunity_Review_VRB_Type_Confirm__c) && ('20'.equals(subsOpportunity.Opportunity_Review_VRB_Type_Confirm__c) || '30'.equals(subsOpportunity.Opportunity_Review_VRB_Type_Confirm__c))){
                    System.debug('RBO Entry2');
                    subsOpportunity.Opportunity_Review_VRB_Type__c = opportunity.Opportunity_Review_VRB_Type_Confirm__c;
                    subsOpportunity.Opportunity_Review_VRB_Type_Confirm__c = opportunity.Opportunity_Review_VRB_Type_Confirm__c;
                    update subsOpportunity;
                }                
            }
        }
    }      
}