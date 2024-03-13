@isTest
private class Batch_UserInfo_Test{
    
    @isTest(SeeAllData=false)
    static void testUpsert1(){
        
        
        //create test User record
        List<User> userList = new List<User>();
        for (Integer i = 1; i < 200; i++){
            
            User testUser = new User();
            //testUser.FirstName = 'John';
            testUser.LastName = 'Exampless' + i;
            testUser.Username = 'johnexampless' + i + '@test.com';
            testUser.Email = 'johnexampless@test.com';
            testUser.Alias = 'JE' +i;
            testUser.TimeZoneSidKey = 'America/Los_Angeles';
            testUser.LocaleSidKey = 'en_US';
            testUser.EmailEncodingKey = 'UTF-8';
            testUser.ProfileId = userInfo.getProfileId();
            testUser.LanguageLocaleKey = 'en_US';
            userList.add(testUser);
        }
        insert userList;
        List<User> temp=new List<User>([Select FirstName from User where Email= 'johnexample@test.com']);
        for(User user:temp)
        {
            user.FirstName = 'Sudhirr';
        }
        Test.startTest();
        Database.executeBatch(new Batch_UserInfo());
        
        update temp;
        Database.executeBatch(new Batch_UserInfo());
        Test.stopTest();
    }
    
}