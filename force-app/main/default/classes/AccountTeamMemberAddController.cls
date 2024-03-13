/**
 * @description       : 
 * @author            : jiiiiii.park@partner.samsung.com.sds.dev
 * @group             : 
 * @last modified on  : 2022-09-09
 * @last modified by  : divyam.gupta@samsung.com
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   2020-12-01   jiiiiii.park@partner.samsung.com.sds.dev   Initial Version
 * 1.1   2022-09-09   divyam.gupta@samsung.com                   Prevention of Adding Account team member for profile Service Desk Agency.

**/
global without sharing class AccountTeamMemberAddController {
    @AuraEnabled    
    public static Map<String, String> defaultSetting(String recordId){
        // check sObject type
        String accountId = recordId;
        String sObjectType = Id.valueOf(accountId).getSObjectType().getDescribe().getName();
        if(sObjectType != 'Account') accountId = [SELECT Id, UserId, AccountId FROM AccountTeamMember WHERE Id =: accountId].AccountId;

        Map<String, String> returnMap = new Map<String, String>();
        
        //*Version: 1.1   --Start--  Prevention of Adding Account team member for profile Service Desk Agency.
        String profileNameUserInfo = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
        String Sdeskprofile = 'Service Desk Agency';

        if(profileNameUserInfo == Sdeskprofile ){
            returnMap.put('Permission','false');
        }
        //*Version: 1.1 --End--

        else {
        // Check edit permission
        UserRecordAccess permission = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess, HasTransferAccess, HasAllAccess 
                                         FROM UserRecordAccess 
                                        WHERE UserId =: UserInfo.getUserId() 
                                          AND RecordId =: accountId];

        returnMap.put('Permission', String.valueOf(permission.HasEditAccess));
        }

        // Get old Account team
        List<AccountTeamMember> accTeamMemberList = [SELECT Id, AccountId, UserId, User.Name, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, ContactAccessLevel 
                                                       FROM AccountTeamMember 
                                                      WHERE AccountId =: accountId
                                                   ORDER BY CreatedDate ASC];

        List<teamMember> oldMemberList = new List<teamMember>();
        for(AccountTeamMember tm :accTeamMemberList){
            customUser oldUser = new customUser();
            teamMember oldMember = new teamMember();
    
            oldUser.Id = tm.UserId;
            oldUser.Name = tm.User.Name;

            oldMember.User = oldUser;
            oldMember.Role = tm.TeamMemberRole;
            oldMember.AccountAccess = tm.AccountAccessLevel;
            oldMemberList.add(oldMember);
        }

        if(oldMemberList.size() > 0){
            returnMap.put('OldMember', JSON.serialize(oldMemberList));
        }
        
        // Get picklist value
        Map<String, List<Map<String, String>>> pickValMap = new Map<String, List<Map<String, String>>>();

        // [Picklist] Team Role
        List<Map<String, String>> teamRolePickList = Utils.getPicklistOptionType('AccountTeamMember', 'TeamMemberRole');
        pickValMap.put('TeamRole', teamRolePickList);
        
        // [Picklist] Account Access
        List<Map<String, String>> accAccessList = new List<Map<String, String>>();
        List<Map<String, String>> accountAccessPickList = Utils.getPicklistOptionType('AccountTeamMember', 'AccountAccessLevel');
        for(Integer i = 0; i < accountAccessPickList.size(); i++){
            if(accountAccessPickList[i].get('value') == 'Edit' || accountAccessPickList[i].get('value') == 'Read'){
                accAccessList.add(accountAccessPickList[i]);
            }
        }
        pickValMap.put('AccountAccess', accAccessList);

        returnMap.put('PickVal', JSON.serialize(pickValMap));

        return returnMap;
    }

    @AuraEnabled    
    public static Map<String, String> saveTeamMember(String recordId, String jsonTeamMemberInfo){
        
        system.debug('### saveTeamMember = ');
        
        Map<String, String> rtnMap = new Map<String, String>();

        // check sObject type
        String accountId = recordId;
        String sObjectType = Id.valueOf(accountId).getSObjectType().getDescribe().getName();
        if(sObjectType != 'Account') accountId = [SELECT Id, UserId, AccountId FROM AccountTeamMember WHERE Id =: accountId].AccountId;
        rtnMap.put('REDIRECT', accountId);

        List<AccountTeamMember> accTeamMemberList = new List<AccountTeamMember>();

        List<teamMember> teamMemberList = (List<teamMember>)JSON.deserialize(jsonTeamMemberInfo, List<teamMember>.class);
        for(teamMember tm :teamMemberList){
            AccountTeamMember newTeamMember = new AccountTeamMember();
            System.debug('accountId : ' + accountId);
            System.debug('tm.User.Id : ' + tm.User.Id);
            System.debug('tm.Role : ' + tm.Role);
            System.debug('tm.AccountAccess : ' + tm.AccountAccess);
            newTeamMember.AccountId = accountId;            
            newTeamMember.UserId = tm.User.Id;            
            newTeamMember.TeamMemberRole = tm.Role;
            newTeamMember.AccountAccessLevel = tm.AccountAccess;
            newTeamMember.OpportunityAccessLevel = 'None';
            newTeamMember.CaseAccessLevel = 'Edit';
            newTeamMember.ContactAccessLevel = 'None';

            accTeamMemberList.add(newTeamMember);
        }

        try{
            delete [SELECT id FROM AccountTeamMember WHERE AccountId = :accountId];
            if(accTeamMemberList.size() > 0){
                insert accTeamMemberList;
            }
            rtnMap.put('STATUS', 'SUCCESS');
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return rtnMap;
    }

    global class teamMember{
        @AuraEnabled
        global customUser User {get; set;}
        @AuraEnabled
        global String Role {get; set;}
        @AuraEnabled
        global String AccountAccess {get; set;}
    }

    global class customUser{
        @AuraEnabled
        global String Id {get; set;}
        @AuraEnabled
        global String Name {get; set;}
    }
}