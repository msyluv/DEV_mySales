/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 03-08-2024
 * @last modified by  : waris.m@samsung.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   02-16-2021   woomg@dkbmc.com        Initial Version
 * 1.1   03-08-2024   waris.m@samsung.com    Changed Condition for isOwner to allow System Admin along with Record owner to view Contact (MYSALES-469)
**/
public with sharing class ContactDetailController {
    @AuraEnabled
    public static Boolean checkContactOwner(String recordId){
        try {
            Boolean isOwner = false;
            Id profileId=UserInfo.getProfileId();
            String profileName= [SELECT Id,Name FROM Profile WHERE Id=:profileId].Name;
            Contact con = [SELECT OwnerId FROM Contact WHERE Id = :recordId LIMIT 1];
           if(con.OwnerId == UserInfo.getUserId() || profileName.contains('Administrator') ||profileName.contains('관리자')) // V 1.1
            {
                isOwner = true;
            }
            return isOwner;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}