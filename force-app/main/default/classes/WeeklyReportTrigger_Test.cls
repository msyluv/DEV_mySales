@isTest
private class WeeklyReportTrigger_Test {
    static TriggerSwitch__c trSwitch_default;
    static User user; 
    static WeeklyReport__c wr;
    
    static {
        // Default Org Switch Setup (checkbox default true)
        trSwitch_default = new TriggerSwitch__c();        
        insert trSwitch_default;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
        list<User> lu = new list<User>();
        user = new User(Alias = 'standt1', Email='user0001@samsung.com', 
                     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                     LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                     UserName='user0001@samsung.com');
        insert user;
                
        wr = new WeeklyReport__c(
        	Name = 'Test Weekly Report',
            ReportingDate__c = Date.today()
       	);
        insert wr;
    }
	@isTest static void test_method_1(){
        Test.startTest();
        System.runAs(user){
        	delete wr;    
        }        
		Test.stopTest();
    }
}