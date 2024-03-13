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
private class PartnerNoticeEmailSenderController_Test {
    static Id recordId;
    static User user, userLoginProfile, mspAdmin;
    static Partner_Notice__c pn;
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

        /*Ver 1.0 Added Community Login Profile*/                
        userLoginProfile = new User(Alias = 'Login', Email='TestLogin@Test.com', ContactId = c.Id, 
                        EmailEncodingKey='UTF-8', LastName='Login', FirstName='Community', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = loginProfile.Id, TimeZoneSidKey='Asia/Seoul', 
                        UserName='user0002@samsung.com');
        
        mspAdmin = [Select Id From User Where Profile.Name='MSP Admin' and isActive=true Limit 1];
        
        pn =  new Partner_Notice__c(
            StartDate__c = Date.newInstance(2022,01,01),
            EndDate__c = Date.newInstance(2022,01,02),
            Subject__c = 'Test',
            Active_InActive__c=true,
            Contents__c = 'Test',
            Email_Send_Subject__c = 'Test'
        );

        insert pn;
        recordId = pn.id;

    }
    
    @isTest
    public static void getEmailInfo() {
        Test.startTest();
        PartnerNoticeEmailSenderController.getEmailInfo(recordId);
        Test.stopTest();
    }

    @isTest
    public static void sendEmailAndUpdateCount() {
        Test.startTest();
        PartnerNoticeEmailSenderController.sendEmailAndUpdateCount(recordId,'Test');
        Test.stopTest();
    }
}