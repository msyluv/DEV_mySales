/**
 * @description       : 
 * @author            : zenith21c@test.com
 * @group             : 
 * @last modified on  : 03-23-2022
 * @last modified by  : zenith21c@test.com
**/
@isTest
public class UserInformation_Test {
    @testSetup static void setup() {
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'test1232dffs3rwefs@samsung.com.sds',
            Username = 'test1232dffs3rwefs@samsung.com.sds.test',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        
        insert u;
    }


    static testMethod void testgetData(){
        User u = [select id, username from User order by username desc limit 1];
        UserInformation.getUserInformation(u.id);        
    }
}