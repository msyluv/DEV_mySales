public class OpportunityReviewSessionOverride {
    @AuraEnabled
    public static String createOpportunityReviewSessionRecord(String sessionName,Date sessionDate, String Note,String sessionResult,String BotargetList){
        system.debug('Akash1' + BotargetList);
            List<targetBo> incomingBo = (List<targetBo>)JSON.deserialize(BotargetList, List<targetBo>.class);
            system.debug('Akash3' + incomingBo);
            OpportunityReviewSession__c oppReview = new OpportunityReviewSession__c();
            oppReview.Name = sessionName;
            oppReview.Session_Date__c = sessionDate;
            oppReview.Session_Result__c = sessionResult;
            oppReview.Note__c = Note;
            
            insert oppReview;
            List<OpportunityReviewTarget__c> targetList = new List<OpportunityReviewTarget__c>();
            
            for(targetBo opp : incomingBo){
                OpportunityReviewTarget__c target = new OpportunityReviewTarget__c();
                target.Opportunity__c = opp.BoId;
                target.Opportunity_Review_Session__c = oppReview.Id;
                target.Today_Review_Target__c = opp.Checked;
                targetList.add(target);
            }
            insert targetList;
            return 'Success'; 
        
      
        
    }
    @AuraEnabled
    public static listView getListViews(){
        system.debug('Akash1');
        List<listView> listViews = [select id,name from ListView where SobjectType = 'OpportunityReviewSession__c' Limit 1];
        return listViews[0];
    }
    @AuraEnabled
    public static OpportunityReviewSession__c getExistingReviewSession(Id recordId){
      List<OpportunityReviewSession__c> reviewList =   [Select id,Name,Session_Date__c,Session_Result__c,Note__c from OpportunityReviewSession__c where Id=: recordId limit 1];
        system.debug('Akash0' + reviewList);
       return reviewList[0];
    }
    @AuraEnabled
    public static List<OpportunityReviewTarget__c> getOpportunityReviewTarget(Id recordId){
      List<OpportunityReviewTarget__c> reviewList =   [Select id,Name,Opportunity__c,Opportunity__r.Name,Opportunity__r.OpportunityCode__c,Opportunity__r.Account.AccountNumber,Opportunity__r.Account.Name,Opportunity__r.Amount,Opportunity__r.CloseDate,Opportunity_Review_Session__c,Today_Review_Target__c from OpportunityReviewTarget__c where Opportunity_Review_Session__c=: recordId];
        system.debug('Akash0' + reviewList);
       return reviewList;
    }
    public class targetBo{
        public string BoId;
        public Boolean Checked;
    }
    
}