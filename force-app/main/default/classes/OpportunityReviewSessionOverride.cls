/**
* @description       : 
* @author            : akash.g@samsung.com
* @group             : 
* @last modified on  : 2024-05-09
* @last modified by  : akash.g@samsung.com 
* Modifications Log 
* Ver   Date         Author                              Modification
* 1.0   2024-05-09   akash.g@samsung.com                 Initial Version(MYSALES-499)
**/
public class OpportunityReviewSessionOverride {
    @AuraEnabled
    public static String createOpportunityReviewSessionRecord(String sessionName,Date sessionDate, String Note,String sessionResult,String BotargetList){
        List<targetBo> incomingBo = (List<targetBo>)JSON.deserialize(BotargetList, List<targetBo>.class);
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
        return oppReview.Id; 
    }
    @AuraEnabled
    public static listView getListViews(){
        List<listView> listViews = [select id,name from ListView where SobjectType = 'OpportunityReviewSession__c' Limit 1];
        return listViews[0];
    }
    @AuraEnabled
    public static OpportunityReviewSession__c getExistingReviewSession(Id recordId){
        
        List<OpportunityReviewSession__c> reviewList =   [Select id,Name,Session_Date__c,Session_Result__c,Note__c,
                                                          CreatedBy.Name,LastModifiedBy.Name,CreatedDate,LastModifiedDate from OpportunityReviewSession__c where Id=: recordId limit 1];
        system.debug('akash test 1'+ reviewList[0].LastModifiedDate);
        return reviewList[0];
    }
    @AuraEnabled
    public static OpportunityDataTableWrapper getOpportunityReviewTarget(Id recordId){
        List<OpportunityReviewTarget__c> reviewList = [Select id,Name,Opportunity__c,Today_Review_Target__c from OpportunityReviewTarget__c where Opportunity_Review_Session__c=: recordId  order by Today_Review_Target__c desc];
        Set<String> OppIdSet = new Set<String>();
        OpportunityDataTableWrapper objDT =  new OpportunityDataTableWrapper();  
        if(reviewList.size() > 0){
            Map<String,Boolean> CheckedMap = new Map<String,Boolean>();
            for(OpportunityReviewTarget__c ORT : reviewList){
                OppIdSet.add(ORT.Opportunity__c);
                CheckedMap.put(ORT.Opportunity__c,ORT.Today_Review_Target__c);
            }
            objDT.opptyCheckedMap = CheckedMap;
            objDT.opportunityList = [SELECT Id, Name, OpportunityCode__c, toLabel(OpportunityStatus__c), toLabel(StageName), CompanyCode__c, Account.Name, Account.AccountNumber,cOriginAcc__r.Name,Amount,CurrencyIsoCode, cOriginAcc__r.AccountNumber,Owner.Name, SalesDivision__c, SalesDepartment__r.Name, cPrimarySalesDepartment__c, cPrimarySalesDepartment__r.Name, CloseDate FROM Opportunity where Id IN :OppIdSet];
            
            Set<String> resultIdSet = new Set<String>();
            Map<String, Boolean> opptyPermissionMap = new Map<String, Boolean>();
            if(objDT.opportunityList.size() > 0){
                for(Opportunity opp : objDT.opportunityList){
                    resultIdSet.add(opp.Id);
                }
                
                List<UserRecordAccess> accessList = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :resultIdSet];
                for(UserRecordAccess access : accessList){
                    opptyPermissionMap.put(access.RecordId, access.HasReadAccess);
                }
            }
            objDT.opptyPermissionMap = opptyPermissionMap;
        }
        return objDT;
    }
    @AuraEnabled
    public static String updateOpportunityReviewSessionRecord(String sessionName,Date sessionDate, String Note,String sessionResult,String BotargetList,Id recordId){
        List<targetBo> incomingBo = (List<targetBo>)JSON.deserialize(BotargetList, List<targetBo>.class);
        OpportunityReviewSession__c oppReview = new OpportunityReviewSession__c(Id=recordId);
        oppReview.Name = sessionName;
        oppReview.Session_Date__c = sessionDate;
        oppReview.Session_Result__c = sessionResult;
        oppReview.Note__c = Note;
        update oppReview;
        List<OpportunityReviewTarget__c> targetListDeleted =  [Select id from OpportunityReviewTarget__c where Opportunity_Review_Session__r.Id =: recordId];
        if(targetListDeleted.size() >0){
            Delete targetListDeleted;
        }
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
    public class targetBo{
        public string BoId;
        public Boolean Checked;
    }
    public class OpportunityDataTableWrapper {
        @AuraEnabled
        public List<Opportunity> opportunityList {get;set;}
        @AuraEnabled
        public Map<String,Boolean> opptyPermissionMap {get;set;}
        @AuraEnabled
        public Map<String,Boolean> opptyCheckedMap {get;set;}
    }
}