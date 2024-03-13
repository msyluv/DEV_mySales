/**
 * @author            : vikrant.ks@samsung.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2024-01-16
 * @last modified by  : vikrant.ks@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2024-01-16   vikrant.ks@samsung.com   Initial Version
**/
public class AddDefaultTeamCmpController {
    @AuraEnabled
    Public static String AddDefaultTeam(String salesLeadId){
        Sales_Lead__c SalesLead = [Select Id, OwnerId from Sales_Lead__c where Id =:salesLeadId Limit 1];
        
        if(SalesLead.OwnerId != UserInfo.getUserId()){
            return 'NOACCESS';
        }
        
        List<Default_Sales_Lead_Team__c> defaultsalesleadteam = [SELECT Id, OwnerId, User__r.Id,User__r.Name, AccessLevel__c,TeamRole__c FROM Default_Sales_Lead_Team__c WHERE OwnerId =: UserInfo.getUserId()];
        
        List<Sales_Lead_Team__c> SalesLeadTeam = [SELECT Id,OwnerId, AccessLevel__c, SalesLead_TeamMember__c, Sales_Lead__c,Team_Role__c FROM Sales_Lead_Team__c where SalesLead_TeamMember__r.IsActive = True And Sales_Lead__c = :SalesLead.Id];
        Map<String,Sales_Lead_Team__c> SalesTeamMap = new Map<String,Sales_Lead_Team__c>();
        for(Sales_Lead_Team__c slt:SalesLeadTeam){
            SalesTeamMap.put(slt.SalesLead_TeamMember__c,slt);
        }
        List<Sales_Lead_Team__c> NewSalesLeadTeam = new List<Sales_Lead_Team__c>();
        
        if(defaultsalesleadteam.size() > 0){
            for(Default_Sales_Lead_Team__c dslt:defaultsalesleadteam){
                if(SalesTeamMap.containsKey(dslt.User__r.Id)){
                    Sales_Lead_Team__c temp = SalesTeamMap.get(dslt.User__r.Id);
                    if(temp.AccessLevel__c == 'Read' && dslt.AccessLevel__c == 'Edit'){
                        temp.AccessLevel__c     = dslt.AccessLevel__c; 
                    	temp.Team_Role__c       = dslt.TeamRole__c;
                        NewSalesLeadTeam.add(temp);
                    }
                    else if(temp.AccessLevel__c == dslt.AccessLevel__c){
                        temp.Team_Role__c = dslt.TeamRole__c;
                        NewSalesLeadTeam.add(temp);
                    }
                }
                else{
                    Sales_Lead_Team__c temp = new Sales_Lead_Team__c();
                    temp.Sales_Lead__c      = SalesLead.Id;
                    temp.OwnerId            = dslt.OwnerId; 
                    temp.AccessLevel__c     = dslt.AccessLevel__c; 
                    temp.Team_Role__c       = dslt.TeamRole__c;
                    temp.SalesLead_TeamMember__c            = dslt.User__r.Id;
                    
                    NewSalesLeadTeam.add(temp);
                }
            }
            try{
                if(NewSalesLeadTeam.size() > 0) upsert NewSalesLeadTeam;
                
                return 'SUCCESS';
            }catch(Exception e){
                return String.valueOf(e.getMessage());
            }
        }
        else{
            return 'NORECORD';
        }
    }
}