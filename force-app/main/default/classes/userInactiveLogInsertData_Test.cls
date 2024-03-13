/**
* @description       : 
* @author            : saurav.k@partner.samsung.com
* @group             : 
* @last modified on  :  17-05-2023
* @last modified by  : saurav.k@partner.samsung.com 
* Modifications Log 
* Ver   Date         Author                        Modification 
* 1.0   17-05-2023   saurav.k@partner.samsung.com  Add Inactive Log to UserActive_Logs for user inactivated by leaving the company(MYSALES-203)
**/
@isTest
public class userInactiveLogInsertData_Test {
    
    
    @isTest static void TestList(){
        List<ID> listofUser = new List<Id>();
        Profile prof = [select id from profile where name LIKE '%System Administrator%' limit 1];
        User user = new User();
        user.firstName = 'test158757';
        user.lastName = 'test24834';
        user.profileId = prof.id;
        user.username = 'test158757@test.com';
        user.email = 'test@test.com';
        user.UserRoleId = Null;
        user.IsActive = false;
        user.Title = 'title';
        user.Alias = 'alias';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'en_US';
        insert user;
        listofUser.add(user.Id);    
        Test.startTest();                 
        userInactiveLogInsertData updater = new userInactiveLogInsertData (listofUser);        
        System.enqueueJob(updater);
        ID jobID = System.enqueueJob(updater);
        Test.stopTest();       
    }   
    
}