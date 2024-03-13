@isTest
private class Batch_UserPasswordResetTest {
    static User user;
    static List<Profile> profileList;
    
    static {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Rep.(HQ)'];
        
        profileList = new List<Profile>();
        profileList.add(p);
        
        user = new User(Alias = 'standt1', Email='user0001@samsung.com', 
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                        UserName='user0001@samsung.com', IsActive=TRUE);
        insert user;
    }
    
    @isTest static void test_1() {        
        Batch_UserPasswordReset batch = new Batch_UserPasswordReset();
        batch.profileList = profileList;
        batch.str_query = 'SELECT Id, Name, ProfileId, Profile.Name, Profile.UserLicenseId, Profile.UserLicense.Name, UserType, IsActive FROM User WHERE Id =\'' + user.Id + '\'';
        database.executebatch(batch, 1);
    }
}