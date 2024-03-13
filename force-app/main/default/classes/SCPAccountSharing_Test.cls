/**
 * @description       : 
 * @author            : gitesh.s@samsung.com
 * @group             : 
 * @last modified on  : 20-01-2023
 * @last modified by  : gitesh.s@samsung.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   20-01-2023   gitesh.s@samsung.com    Initial Version
**/
@isTest
private class SCPAccountSharing_Test {

    static User user;
    static SCP_Account__c scpAcc;
    static Contact con;
    static Employee__c emp;
    static Account acc;
    static SCP_Account__Share partnerShare;
    static {
        acc = new Account(Name = 'Test', MDGCheck__c = true);
        insert acc;
        acc.IsPartner = true;
        update acc;

        con = new Contact(LastName='Test', FirstName='User', AccountId = acc.Id);
        insert con;

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Partner Community Manager'];

        user = new User(LastName = 'User', Email = 'user0001@samsung.com', Username = 'user0001@samsung.com',
                        Alias = 'test', ProfileId = profile.Id, TimeZoneSidKey = 'Asia/Seoul',
                        LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', ContactId = con.Id);
        insert user;

        emp = new Employee__c(Name = 'Test Employee');
        insert emp;

        Date currentDate = System.today();
        Date nextDate = currentDate.addDays(1);

        scpAcc = new SCP_Account__c(SCP_Account_ID__c = 'ACCOUNT-12345', Name = 'Test Name',
                                    Customer__c = acc.Id, Contract_Start_Date__c = currentDate,
                                    WBS_Code__c = '1234', Partner__c = acc.Id,
                                    SDS_AM__c = emp.Id, SDS_PDM__c = emp.Id, Incentive__c = 'Y');
        insert scpAcc;
        
        partnerShare = new SCP_Account__Share(ParentId = scpAcc.Id, UserOrGroupId = user.Id, AccessLevel = 'read');
        insert partnerShare;
    }
    
    @isTest
    public static void sharingTestMethod() {
        Test.startTest();
        List<SCP_Account__Share> accountShare = [SELECT Id, UserOrGroupId, AccessLevel, RowCause FROM SCP_Account__Share WHERE ParentId =: partnerShare.ParentId AND UserOrGroupId =: partnerShare.UserOrGroupId];
        Test.stopTest();
    }
}