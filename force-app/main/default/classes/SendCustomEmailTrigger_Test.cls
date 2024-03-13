/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 08-31-2022
 * @last modified by  : gitesh.s@samsung.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   08-31-2022   gitesh.s@samsung.com    Added Community Login Profile
**/
@isTest
private class SendCustomEmailTrigger_Test {
    static User user, userLoginProfile, mspAdmin;
    static {
        Account a = new Account(Name='Test');
        insert a;
        
        Contact c = new Contact(LastName = 'Test', AccountId = a.id);
        insert c;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Partner Community Manager'];

        /*Ver 1.0 Added Community Login Profile*/
        Profile loginProfile = [SELECT Id FROM Profile WHERE Name = 'Partner Community Login Manager'];
        
        user = new User(Alias = 'Test', Email='Test@Test.com', ContactId = c.Id,
                     EmailEncodingKey='UTF-8', LastName='Test', FirstName='Test', LanguageLocaleKey='en_US', 
                     LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                     UserName='user0001@samsung.com');

        userLoginProfile = new User(Alias = 'Login', Email='TestLogin@Test.com', ContactId = c.Id, 
                        EmailEncodingKey='UTF-8', LastName='Login', FirstName='Community', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = loginProfile.Id, TimeZoneSidKey='Asia/Seoul', 
                        UserName='user0002@samsung.com');
        
        mspAdmin = [Select Id From User Where Profile.Name='MSP Admin' and isActive=true Limit 1];
    }
	
    @isTest
    public static void createUser() {
        Test.startTest();
        System.runAs(mspAdmin){
            insert user;
        }
        Test.stopTest();
    }

    @isTest
    public static void createCommunityLoginUser() {
        Test.startTest();
        System.runAs(mspAdmin){
            insert userLoginProfile;
        }
        Test.stopTest();
    }
}