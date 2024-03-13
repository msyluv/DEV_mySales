/**
 * @author            : vikrant.ks@samsung.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2024-01-24
 * @last modified by  : vikrant.ks@samsung.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2024-01-16   vikrant.ks@samsung.com   Initial Version(MySales-389)
**/
global class AddSalesTeamMemberCmpController {
    @AuraEnabled    
    global static String CheckOwner(String salesLeadId){
        Sales_Lead__c SalesLead = [Select Id, OwnerId from Sales_Lead__c where Id =:salesLeadId Limit 1];
        
        if(SalesLead.OwnerId == UserInfo.getUserId()){
            return 'PASS';
        }
        return System.Label.SalesLeadWrongOwner;
    }
    
    @AuraEnabled    
    global static Map<String, String> save(String jsonData,String salesLeadId){
        Sales_Lead__c SalesLead = [Select Id, OwnerId from Sales_Lead__c where Id =:salesLeadId Limit 1];
        Map<String, String> rtnMap = new Map<String, String>();
        
        if(SalesLead.OwnerId != UserInfo.getUserId()){
            rtnMap.put('RESULT', 'E');
            rtnMap.put('MSG', System.Label.SalesLeadWrongOwner);
            return rtnMap;
        }
        
        try{
            
            List<Sales_Lead_Team__c> SalesLeadTeam = [SELECT Id,OwnerId, AccessLevel__c, SalesLead_TeamMember__c, Sales_Lead__c,Team_Role__c FROM Sales_Lead_Team__c where SalesLead_TeamMember__r.IsActive = True And Sales_Lead__c = :SalesLead.Id];
            Map<String,Sales_Lead_Team__c> SalesTeamMap = new Map<String,Sales_Lead_Team__c>();
            for(Sales_Lead_Team__c slt:SalesLeadTeam){
                SalesTeamMap.put(slt.SalesLead_TeamMember__c,slt);
            }
            List<Sales_Lead_Team__c> NewSalesLeadTeam = new List<Sales_Lead_Team__c>();
            
            List<sltm> sltmList = (List<sltm>)JSON.deserialize(jsonData, List<sltm>.class);
            if(sltmList.size() > 0){
                for(sltm s : sltmList){
                    if(SalesTeamMap.containsKey(s.User.Id)){
                        Sales_Lead_Team__c temp = SalesTeamMap.get(s.User.Id);
                        if(temp.AccessLevel__c == 'Read' && s.AccessLevel == 'Edit'){
                            temp.AccessLevel__c     = s.AccessLevel; 
                            temp.Team_Role__c       = s.TeamRole;
                            NewSalesLeadTeam.add(temp);
                        }
                        else if(temp.AccessLevel__c == s.AccessLevel){
                            temp.Team_Role__c = s.TeamRole;
                            NewSalesLeadTeam.add(temp);
                        }
                    }
                    else{
                        Sales_Lead_Team__c temp = new Sales_Lead_Team__c();
                        temp.Sales_Lead__c   = SalesLead.Id;
                        temp.AccessLevel__c  = s.AccessLevel; 
                        temp.Team_Role__c    = s.TeamRole;
                        temp.SalesLead_TeamMember__c = s.User.Id;
                        
                        NewSalesLeadTeam.add(temp);
                    }
                }
            }
            if(NewSalesLeadTeam.size() > 0) upsert NewSalesLeadTeam;
            
            rtnMap.put('RESULT', 'S');
            rtnMap.put('MSG', System.Label.SalesLeadTeamMemberSuccess); // Sales lead team member add success
        }
        catch(Exception e){
            rtnMap.put('RESULT', 'E');
            rtnMap.put('MSG', e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
        return rtnMap;
    }
    
    global class sltm{
        @AuraEnabled
        global customUser User {get; set;}
        @AuraEnabled
        global String AccessLevel {get; set;}
        @AuraEnabled
        global String TeamRole {get; set;}
    }
    
    global class customUser{
        @AuraEnabled
        global String Id {get; set;}
        @AuraEnabled
        global String Name {get; set;}
    }
}