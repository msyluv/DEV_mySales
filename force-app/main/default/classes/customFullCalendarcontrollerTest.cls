@isTest
public class customFullCalendarcontrollerTest {

    
    static User u;
	static Account acc;
	static AccountPlan__c accPlan;
	static Opportunity pastOpp;
    static Opportunity futureOpp;
	static Opportunity_Activity__c pastOpptyAct;
    static Opportunity_Activity__c futureOpptyAct;
     static  Map<String,List<Object>>  eve;
    
    static {
        
        
        user admin = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		system.runAs (admin) {
			Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
			list<User> lu = new list<User>();
			u = new User(Alias = 'standt1', Email='user0001@samsung.com', 
						EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
						LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
						UserName='user0001@samsung.com');
			insert u;
		}
		Event ev = new Event(Subject='Test', StartDateTime=system.now(), EndDateTime=system.now(), OwnerId=u.Id,IsAllDayEvent=false);
		insert ev;
    }
    
     @isTest
    public static void knoxCalenderControllerTest_1(){
      Test.startTest();
        system.runAs (u) {
             
            eve=customFullCalendarcontroller.getAllEvendata();
        }
      Test.stopTest();
    }
}