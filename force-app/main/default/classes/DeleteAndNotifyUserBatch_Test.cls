/**
 * @description       : 
 * @author            : zenith21c@test.com
 * @group             : 
 * @last modified on  : 03-17-2022
 * @last modified by  : zenith21c@test.com
**/
@isTest
public class DeleteAndNotifyUserBatch_Test {
    static User user;
    
    static{

        Id profileId = [select id from profile where name='System Administrator'].id;


         //Account objAcc = new Account(name ='Test temp Account');
         //insert objAcc; 
        
        // Contact objContact = new Contact(LastName ='testCon',AccountId = objAcc.Id);
         //insert objContact;  

         user = new User(Alias = 'ttuser99', Email='wonjun98.lee@samsung.com', 
                     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                     LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='Asia/Seoul', 
                     UserName='ttuser99@samsung.com.sdspartner',
                     isActive = true
                  
                     );
        //Start- Added by Anish 
         String str = String.valueOf(System.Today()); 
         List<String> IntNo = new List<String>(); 
         IntNo = str.split('-');
         if(IntNo[1]=='01' || IntNo[1]=='03' || IntNo[1]=='05' || IntNo[1]=='07' || IntNo[1]=='8' || IntNo[1]=='10' || IntNo[1]=='12' ){
         user.Date_Last_Login__c = System.Today().addDays(-334);
         }
         if(IntNo[1]=='04' || IntNo[1]=='06' || IntNo[1]=='09' || IntNo[1]=='11' ){
         user.Date_Last_Login__c = System.Today().addDays(-335);
         }
         if(IntNo[1]=='02' ){
         user.Date_Last_Login__c = System.Today().addDays(-337);
         }
        //End- Added by Anish 
         user.Last_Notification_Date__c = null ; //Anish
         system.debug( 'test class user insert user.Date_Last_Login__c : ' + user.Date_Last_Login__c);
         insert user;

    }

    @isTest static void test_method_1() {
        Test.startTest();
        System.runAs(user){
        	DeleteAndNotifyUserBatch bb = new DeleteAndNotifyUserBatch();
            Database.executeBatch(bb);
        }
		Test.stopTest();
    }
}