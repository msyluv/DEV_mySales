@isTest
private class AccountTeamMemberAddController_Test {
    static User user;
    static Account acc;
    
    static {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
        list<User> lu = new list<User>();
        user = new User(Alias = 'standt1', Email='user0001@samsung.com', 
                     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                     LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                     UserName='user0001@samsung.com');
        insert user;
        
        acc = new Account(
        	Name = 'Test Account'
        );
        insert acc;
    }
	
    
    @isTest static void test_method_2() {
        Test.startTest();
        AccountTeamMemberAddController.saveTeamMember(acc.Id, '[{"User":{"Id":"' + user.Id + '","Name":"' + user.Name + '"},"Role":"Executive Sponsor","AccountAccess":"Read"}]');
        AccountTeamMemberAddController.defaultSetting(acc.Id);
		Test.stopTest();
	}
}