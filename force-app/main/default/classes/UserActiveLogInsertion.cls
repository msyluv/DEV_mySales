/**
* @description       : This class is used to insert UserActive(UserActive_Logs__c) records whenever a user records is inserted or active status is updated
* @author            : Kajal.c@samsung.com
* @group             : 
* @last modified on  : 2023-02-06 
* @last modified by  : Kajal.c@samsung.com
* Modifications Log 
* Ver   Date         Author                           Modification
* 1.0   08-31-2022   rakshit.s@samsung.com           Initial Version
* 1.1   2023-02-06   Kajal.c@samsung.com             Added functionality related to MySales-123.
**/
public with sharing class UserActiveLogInsertion {
    
    @future
    public static void insertUserActiveLog(List<Id> userRecId){
        List<UserActive_Logs__c> userActiverecInsertionList = new list<UserActive_Logs__c>();
        List<Id> idList = new list<id>();
        List<User> userRec = new List<User>();
        userRec = [Select id, isActive,CompanyCode__c,Name,Email,Username,CreatedDate,CreatedById,LastModifiedDate from User where Id IN: userRecId];
        for(User uu : userRec){
            UserActive_Logs__c rec = new UserActive_Logs__c();
            // rec.Active__c = userRec.IsActive;
            rec.ChangedById__c = userinfo.getUserId();
            rec.Changeddate__c = uu.LastModifiedDate;
            rec.CompanyCode__c = uu.CompanyCode__c;
            rec.UserId__c = uu.Id;
            rec.Name__c = uu.Name;
            rec.Email__c = uu.Email;
            rec.UserName__c = uu.Username;
            rec.UserCreatedDate__c = uu.CreatedDate;
            rec.UserCreatedById__c = uu.CreatedById;
            rec.Active__c = uu.IsActive;
            userActiverecInsertionList.add(rec);
        }
        if(userActiverecInsertionList.size()>0){
            try{
                insert userActiverecInsertionList;
            }
            catch(DmlException e){
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
        }
    }
    
    /** START -- V1.1 MySales1-123 Added by Kajal  **/
    @future
    public static void insertUserActiveLogOnUpdate(List<Id> userRecId){
        List<UserInfo_Change_Logs__c> userActiverecUpdationList = new list<UserInfo_Change_Logs__c>();
        List<Id> idList = new list<id>();
        System.debug('ID List is' +userRecId);
        List<User> userInfoRec = new List<User>();
        userInfoRec = [Select id, isActive,CompanyCode__c,Name,Email,Username,UserRole.Name,Profile.Name,CreatedDate,CreatedById,LastModifiedDate from User where Id IN: userRecId];
         System.debug('User info List is' +userInfoRec);
         for(User uu : userInfoRec){
            UserInfo_Change_Logs__c rec = new UserInfo_Change_Logs__c();
            rec.UserId__c = uu.Id;
            rec.Name__c = uu.Name; 
            rec.CompanyCode__c = uu.CompanyCode__c; 
            rec.Email__c =  uu.Email; 
            rec.Username__c = uu.Username;
            rec.UserProfile__c = uu.Profile.Name;
            rec.UserRole__c    = uu.UserRole.Name;
            rec.ChangedById__c = userinfo.getUserId();
            rec.Changeddate__c = uu.LastModifiedDate;
            rec.Active__c = uu.IsActive;
            userActiverecUpdationList.add(rec);
        }
        if(userActiverecUpdationList.size()>0){
            try{
                System.debug('Active log list' +userActiverecUpdationList);
                insert userActiverecUpdationList;
            }
            catch(DmlException e){
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
        }
    }
     /** END -- V1.1 MySales-123 Added by Kajal  **/
}