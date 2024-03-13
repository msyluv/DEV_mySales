/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2024-01-24
 * @last modified by  : vikrant.ks@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-02-05   younghoon.kim@dkbmc.com   Initial Version
 * 1.1   2024-01-16   vikrant.ks@samsung.com    Changed Sales_Lead_Team to Default_Sales_Lead_Team(MySales-389)
**/
global class AddSalesLeadTeamMemberController {
    @AuraEnabled    
    global static Map<String, String> defaultSetting(){
        Map<String, String> rtnMap = new Map<String, String>();
        List<sltm> rtnList = new List<sltm>();
        String rtnString = '';

        try{
            List<Default_Sales_Lead_Team__c> teamMemberList = [SELECT Id, User__c, User__r.Name, AccessLevel__c,TeamRole__c FROM Default_Sales_Lead_Team__c WHERE OwnerId =: UserInfo.getUserId() AND User__r.IsActive = True];
            if(teamMemberList.size() > 0){
                for(Default_Sales_Lead_Team__c sltm : teamMemberList){
                    customUser cu = new customUser();
                    cu.Id = sltm.User__c;
                    cu.Name = sltm.User__r.Name;

                    sltm s = new sltm();
                    s.User = cu;
                    s.AccessLevel = sltm.AccessLevel__c;
                    s.TeamRole = sltm.TeamRole__c;

                    rtnList.add(s);
                }
            }
            rtnMap.put('LIST', JSON.serialize(rtnList));

            ListView lv = [SELECT Id, Name, DeveloperName, SobjectType FROM ListView WHERE SobjectType = 'Sales_Lead__c' AND DeveloperName = 'All' LIMIT 1];
            rtnMap.put('URL', lv.Id);

            return rtnMap;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled    
    global static Map<String, String> save(String jsonData){
        Map<String, String> rtnMap = new Map<String, String>();

        try{
            List<Default_Sales_Lead_Team__c> oldList = [SELECT Id, OwnerId, User__r.Id, AccessLevel__c,TeamRole__c FROM Default_Sales_Lead_Team__c WHERE OwnerId =: UserInfo.getUserId()];
            if(oldList.size() > 0) delete oldList;

            List<Default_Sales_Lead_Team__c> isnertList = new List<Default_Sales_Lead_Team__c>();

            List<sltm> sltmList = (List<sltm>)JSON.deserialize(jsonData, List<sltm>.class);
            if(sltmList.size() > 0){
                for(sltm s : sltmList){
                    if(UserInfo.getUserId() != s.User.Id){
                        Default_Sales_Lead_Team__c slt = new Default_Sales_Lead_Team__c();
                        slt.OwnerId = UserInfo.getUserId();
                        slt.User__c = s.User.Id;
                        slt.AccessLevel__c = s.AccessLevel;
                        slt.TeamRole__c = s.TeamRole;
                        
                        isnertList.add(slt);
                    }
                }
        
                if(isnertList.size() > 0) insert isnertList;
            }
            rtnMap.put('RESULT', 'S');
            rtnMap.put('MSG', System.Label.SLTM_MSG_0001); // Sales lead team member add success
        }catch(Exception e){
            rtnMap.put('RESULT', 'E');
            rtnMap.put('MSG', 'ERROR : ' + e.getMessage());
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