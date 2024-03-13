/**
* @author            : vikrant.ks@samsung.com
* @group             : 
* @description       : 
* @last modified on  : 2024-02-07
* @last modified by  : vikrant.ks@samsung.com
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2024-01-16   vikrant.ks@samsung.com   Initial Version(MySales-389)
**/
trigger SalesLeadTeamTrigger on Sales_Lead_Team__c (Before insert,After insert,Before update,After update,Before delete,After delete){
    
    switch on trigger.operationType{    
            
        when BEFORE_INSERT{
            BeforeInsertSLT(Trigger.new);
        }
        when AFTER_INSERT{
            AfterInsertSLT(Trigger.new);
        }
        when BEFORE_UPDATE{
            BeforeUpdateSLT(Trigger.new,Trigger.old,Trigger.oldMap);
        }
    	when AFTER_UPDATE{
            AfterUpdateSLT(Trigger.new,Trigger.old);
        }
        when BEFORE_DELETE{
            BeforeDeleteSLT(Trigger.old);
        }
        when AFTER_DELETE{
            AfterDeleteSLT(Trigger.old);
        }
    }
    private static void BeforeInsertSLT(List<Sales_Lead_Team__c> newObjList){
        Set<String> SalesLeadList  = new Set<String>();
        Set<String> TeamMemberList = new Set<String>();
        Set<String> UniqueSLT = new Set<String>();
        
        for(Sales_Lead_Team__c slt : newObjList){
            if(slt.Sales_Lead__c == Null){
                slt.addError('Please choose a Sales Lead.');
            }
            if(slt.SalesLead_TeamMember__c == Null){
                slt.addError('Please choose a Sales Lead Team Member.');
            }
            SalesLeadList.add(slt.Sales_Lead__c);
            TeamMemberList.add(slt.SalesLead_TeamMember__c);
            
        }
        List<Sales_Lead_Team__c> sltList = [SELECT Id, OwnerId, AccessLevel__c, SalesLead_TeamMember__c, Sales_Lead__c, Team_Role__c FROM Sales_Lead_Team__c where SalesLead_TeamMember__c IN :TeamMemberList and Sales_Lead__c IN :SalesLeadList order by AccessLevel__c DESC];
        for(Sales_Lead_Team__c slt:sltList){
            UniqueSLT.add(slt.SalesLead_TeamMember__c+'_'+slt.Sales_Lead__c);
        }
        List<Sales_Lead__c> SLList = [Select Id,OwnerId from Sales_Lead__c where Id IN :SalesLeadList];
        Map<Id,Id> SalesLeadMap = new Map<Id,Id>();
        for(Sales_Lead__c sl: SLList){
            SalesLeadMap.put(sl.Id,sl.OwnerId);
        }
        for(Sales_Lead_Team__c slt : newObjList){
            if(UniqueSLT.contains(slt.SalesLead_TeamMember__c+'_'+slt.Sales_Lead__c)){
                slt.addError(System.Label.SalesLeadTeamAlreadyExist);
            }
            if(SalesLeadMap.get(slt.Sales_Lead__c) != Null && SalesLeadMap.get(slt.Sales_Lead__c) != UserInfo.getUserId()){
                slt.addError(System.Label.SalesLeadWrongOwner);
            }
        }
    }
    private static void AfterInsertSLT(List<Sales_Lead_Team__c> newObjList){
        
        List<Sales_Lead__Share> insertList = new List<Sales_Lead__Share>();
        for(Sales_Lead_Team__c slt : newObjList){
            if(slt.Sales_Lead__c != Null && slt.SalesLead_TeamMember__c != Null){
                if(UserInfo.getUserId() != slt.SalesLead_TeamMember__c){
                    Sales_Lead__Share sLeadShare = new Sales_Lead__Share();
                    sLeadShare.ParentId      = slt.Sales_Lead__c; 
                    sLeadShare.UserOrGroupId = slt.SalesLead_TeamMember__c; 
                    sLeadShare.AccessLevel   = slt.AccessLevel__c; 
                    sLeadShare.RowCause      = 'Manual'; 
    
                    insertList.add(sLeadShare);
                }
            }
        }
        
        System.debug('insertList : ' + insertList);
        if(insertList.size() > 0) insert insertList;
    }
	
    private static void AfterDeleteSLT(List<Sales_Lead_Team__c> oldObjList){
        Set<String> SalesLeadList  = new Set<String>();
        Set<String> TeamMemberList = new Set<String>();
        
        for(Sales_Lead_Team__c slt : oldObjList){
            if(slt.Sales_Lead__c != Null){
                SalesLeadList.add(slt.Sales_Lead__c);
                TeamMemberList.add(slt.SalesLead_TeamMember__c+'_'+slt.AccessLevel__c);//Can include created date for more accuracy
            }
        }
        List<Sales_Lead__Share> slsList = [Select Id,UserOrGroupId,ParentId,AccessLevel from Sales_Lead__Share where ParentId IN :SalesLeadList and RowCause = 'Manual'];
        List<Sales_Lead__Share> deleteList = new List<Sales_Lead__Share>();
        for(Sales_Lead__Share sls : slsList){
            if(TeamMemberList.contains(sls.UserOrGroupId+'_'+sls.AccessLevel)){
                deleteList.add(sls);
            }
        }
        
        System.debug('deleteList : ' + deleteList);
        if(deleteList.size() > 0) delete deleteList;
    }
	private static void BeforeDeleteSLT(List<Sales_Lead_Team__c> oldObjList){
        Set<Id> SalesLeadIdSet = new Set<Id>();
        for(Sales_Lead_Team__c slt:oldObjList){
            SalesLeadIdSet.add(slt.Sales_Lead__c);
        }
        DateTime temp = DateTime.now().addSeconds(-20);
        List<Sales_Lead__c> SLList = [Select Id from Sales_Lead__c where Id IN :SalesLeadIdSet and Owner_Change_Time__c > :temp and Owner_Change_Time__c != Null];
        Set<Id> OwnerChangedSalesLeadIdSet = new Set<Id>();
        for(Sales_Lead__c sl:SLList){
            OwnerChangedSalesLeadIdSet.add(sl.Id);
        }
        for(Sales_Lead_Team__c slt : oldObjList){
            if(slt.OwnerId != UserInfo.getUserId()){
                if(!OwnerChangedSalesLeadIdSet.contains(slt.Sales_Lead__c)){
                    slt.addError(System.Label.SalesLeadOnlyOwnerCanDelete);
                }
            }
        }
    }
    
    private static void AfterUpdateSLT(List<Sales_Lead_Team__c> NewObjList,List<Sales_Lead_Team__c> oldObjList){
        Set<String> SalesLeadList  = new Set<String>();
        Set<String> TeamMemberList  = new Set<String>();
        Map<String,String> TeamMemberMap = new Map<String,String>();
        
        for(Sales_Lead_Team__c slt : oldObjList){
            if(slt.Sales_Lead__c != Null && slt.SalesLead_TeamMember__c != Null){
                SalesLeadList.add(slt.Sales_Lead__c);
                TeamMemberList.add(slt.SalesLead_TeamMember__c);
                TeamMemberMap.put(slt.Sales_Lead__c+'_'+slt.SalesLead_TeamMember__c,slt.Id);
            }
        }
        List<Sales_Lead__Share> slsList = [Select Id,UserOrGroupId,ParentId,AccessLevel from Sales_Lead__Share where ParentId IN :SalesLeadList and UserOrGroupId IN :TeamMemberList and RowCause = 'Manual'];
        
        List<Sales_Lead__Share> DeleteSalesLeadShareList = new List<Sales_Lead__Share>();
        for(Sales_Lead__Share sls : slsList){
            if(TeamMemberMap.containsKey(sls.ParentId+'_'+sls.UserOrGroupId)){
                DeleteSalesLeadShareList.add(sls);
            }
        }
        List<Sales_Lead__Share> InsertList = new List<Sales_Lead__Share>();
        for(Sales_Lead_Team__c slt : NewObjList){
            if(slt.Sales_Lead__c != Null && slt.SalesLead_TeamMember__c != Null && UserInfo.getUserId() != slt.SalesLead_TeamMember__c){
                Sales_Lead__Share temp = new Sales_Lead__Share();
                temp.ParentId = slt.Sales_Lead__c;
                temp.UserOrGroupId = slt.SalesLead_TeamMember__c;
                temp.AccessLevel = slt.AccessLevel__c;
                temp.RowCause = 'Manual'; 
                InsertList.add(temp);
            }
        }
        if(DeleteSalesLeadShareList.size() > 0) Delete DeleteSalesLeadShareList;
        if(InsertList.size() > 0) Insert InsertList;
    }
    
    private static void BeforeUpdateSLT(List<Sales_Lead_Team__c> newObjList,List<Sales_Lead_Team__c> oldObjList,Map<Id,Sales_Lead_Team__c> OldMap){
        Set<String> SalesLeadList  = new Set<String>();
        Set<String> TeamMemberList = new Set<String>();
        
        for(Sales_Lead_Team__c slt : newObjList){
            SalesLeadList.add(slt.Sales_Lead__c);
            TeamMemberList.add(slt.SalesLead_TeamMember__c);
        }
        for(Sales_Lead_Team__c slt : oldObjList){
            SalesLeadList.add(slt.Sales_Lead__c);
            TeamMemberList.add(slt.SalesLead_TeamMember__c);
        }
        List<Sales_Lead_Team__c> sltList = [Select id,SalesLead_TeamMember__c,Sales_Lead__c from Sales_Lead_Team__c where SalesLead_TeamMember__c IN :TeamMemberList and Sales_Lead__c IN :SalesLeadList];
        Set<String> TeamMemberSet = new Set<String>();
        for(Sales_Lead_Team__c slt: sltList){
            TeamMemberSet.add(slt.SalesLead_TeamMember__c+'_'+slt.Sales_Lead__c);
        }
        List<Sales_Lead__c> SLList = [Select Id,OwnerId from Sales_Lead__c where Id IN :SalesLeadList];
        Map<Id,Id> SalesLeadMap = new Map<Id,Id>();
        for(Sales_Lead__c sl: SLList){
            SalesLeadMap.put(sl.Id,sl.OwnerId);
        }
        for(Sales_Lead_Team__c slt : newObjList){
            if(slt.OwnerId != UserInfo.getUserId()){
                slt.addError(System.Label.SalesLeadOnlyOwnercanChange);
            }
            if(OldMap.get(slt.Id).SalesLead_TeamMember__c != slt.SalesLead_TeamMember__c){
                System.debug('Sales Lead Team Member Change');
                if(TeamMemberSet.contains(slt.SalesLead_TeamMember__c+'_'+slt.Sales_Lead__c)){
                    slt.addError(System.Label.SalesLeadTeamAlreadyExist);
                }
            }
            if(OldMap.get(slt.Id).Sales_Lead__c != slt.Sales_Lead__c){
                System.debug('Sales Lead Change');
                if(SalesLeadMap.get(slt.Sales_Lead__c) != Null && SalesLeadMap.get(slt.Sales_Lead__c) != UserInfo.getUserId()){
                    slt.addError(System.Label.SalesLeadWrongOwner);
                }
                if(TeamMemberSet.contains(slt.SalesLead_TeamMember__c+'_'+slt.Sales_Lead__c)){
                    slt.addError(System.Label.SalesLeadTeamAlreadyExist);
                }
            }
        }
    }
}