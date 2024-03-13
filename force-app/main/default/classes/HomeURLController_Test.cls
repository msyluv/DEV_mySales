/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2023-08-30
 * @last modified by  : atul.k1@samsung.com
 * Modifications Log 
 * 1.1   2022-11-28   anish.jain@partner.samsung.com   Logic coverage of user based button visibility
 * 1.2   2023-08-30   atul.k1@samsung.com   Logic coverage of user role and url based Link visibility.
**/
@isTest
public class HomeURLController_Test {
    public static User usr; //Added by Anish - v 1.1
    public static User usr1; //Added by Anish - v 1.1
    public static User usr5;//Added by Atul - v 1.2
    @TestSetup
    static void setup(){
        List<Home_URL__c> urlList = new List<Home_URL__c>();

        Home_URL__c url1 = new Home_URL__c(
            Name = '한글 제목 1',
            SystemName_EN__c = 'BO Dashboard',
            Role__c = '',   //Added by Anish - v 1.1
            User_Email__c = 'Test1@samsung.com;Test2@samsung.com;abc@samsung.com',//Added by Atul - v 1.2
            URL__c = 'https://naverNew22.com',
            Order__c = 1 //Added by Atul - v 1.2
            //User_Email__c = 'abc@samsung.com' //Added by Anish - v 1.1
        );
        urlList.add(url1);

        Home_URL__c url2 = new Home_URL__c(
            Name = '한글 제목 2',
            SystemName_EN__c = 'English Title 2',
            Role__c = 'SDS-총괄',
            URL__c = 'https://naver.com',
            Order__c = 2
        );
        urlList.add(url2);

        Home_URL__c url3 = new Home_URL__c(
            Name = '한글 제목 3',
            SystemName_EN__c = 'English Title 3',
            Role__c = 'Default', //Added by Anish - v 1.1
            URL__c = 'https://naver.com',
            Order__c = 1
        );
        urlList.add(url3);
         Home_URL__c url4 = new Home_URL__c(
            Name = '한글 제목 4',
            SystemName_EN__c = 'English Title 4',
            Role__c = 'Default', //Added by Anish - v 1.1
            URL__c = 'https://naver11.com',
            Order__c = 1
        );
        urlList.add(url4);
         Home_URL__c url5 = new Home_URL__c(
            Name = '한글 제목 1',
            SystemName_EN__c = 'English Title 1',
            Role__c = 'SDSI',
            //Role__c = '',   //Anish
            URL__c = 'https://naverTesting.com',
            Order__c = 3
            //User_Email__c = 'abcde@samsung.com'
        );
        urlList.add(url5);
       
        if(urlList.size() > 0) insert urlList;
    }
    
    
    //Start - Added by Anish - v 1.1
    static void setup1(){
                List<Home_URL__c> urlList = new List<Home_URL__c>();

        Home_URL__c url1 = new Home_URL__c(
            Name = '한글 제목 1',
            SystemName_EN__c = 'English Title 1',
            Role__c = 'Default',
            //Role__c = '',   //Anish
            URL__c = 'https://naver.com',
            Order__c = 1
            //User_Email__c = 'abcde@samsung.com'
        );
        urlList.add(url1);

        Home_URL__c url2 = new Home_URL__c(
            Name = '한글 제목 2',
            SystemName_EN__c = 'English Title 2',
            Role__c = 'SDS-총괄',
            URL__c = 'https://naver.com',
            Order__c = 2
        );
        urlList.add(url2); 
    }
     static void setup2(){
                List<Home_URL__c> urlList = new List<Home_URL__c>();

        Home_URL__c url1 = new Home_URL__c(
            Name = '한글 제목 1',
            SystemName_EN__c = 'English Title 1',
            Role__c = 'SDSI New',
            //Role__c = '',   //Anish
            URL__c = 'https://naverTesting.com',
            Order__c = 3
            //User_Email__c = 'abcde@samsung.com'
        );
        urlList.add(url1);

        Home_URL__c url2 = new Home_URL__c(
            Name = '한글 제목 2',
            SystemName_EN__c = 'English Title 2',
            Role__c = 'SDSI New',
            URL__c = 'https://naverTestingNew.com',
            Order__c = 5
        );
        urlList.add(url2); 
    }
      //Start - Added by Anish - v 1.1
     
    @isTest
    static void testBatch() { 
        //Start-Added by Anish - v 1.1
        Profile p = [SELECT id FROM Profile WHERE name = 'System Administrator'];
        UserRole usrRole = [SELECT Id,Name from UserRole WHERE Name = 'SDS-총괄' ];
        usr = new User(
            Alias = 'standt1', Email='abc@samsung.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='ko_KR', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
            UserName='user0001@ss-sds.com', Division = 'TW', UserRoleId = usrRole.Id,
            EmployeeNumber = '123455'
        );
        insert usr;
        //End-Added by Anish - v 1.1
        Test.startTest();
        System.runAs(usr){ //Added by Anish - v 1.1
        HomeURLController.urlSetting();
        }
        Test.stopTest();
    }
   //Modified by Atul - v 1.2
     @isTest
    static void testBatch3() { 
        //Start-Added by Anish - v 1.1
        Profile p = [SELECT id FROM Profile WHERE name = 'System Administrator'];
        UserRole usrRole = [SELECT Id,Name from UserRole WHERE Name = 'SDSI' ];
        usr = new User(
            Alias = 'standt1', Email='abc@samsung.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='ko_KR', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
            UserName='user0001@ss-sds.com', Division = 'TW', UserRoleId = usrRole.Id,
            EmployeeNumber = '123455'
        );
        insert usr;
        //End-Added by Anish - v 1.1
        Test.startTest();
        System.runAs(usr){ //Added by Anish - v 1.1
        HomeURLController.urlSetting();
        }
        Test.stopTest();
    }
   
    //Start - Added by Anish - v 1.1
     @isTest
    static void testBatch1() {
        setup1();
        Profile p = [SELECT id FROM Profile WHERE name = 'System Administrator'];
        UserRole usrRole = [SELECT Id,Name from UserRole WHERE Name = 'SDS-총괄' ];
        UserRole usrRole1 = [SELECT Id,Name from UserRole WHERE Name = 'SDS-본사' ];
        usr = new User(
            Alias = 'standt1', Email='abcd@samsung.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='ko_KR', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
            UserName='user0001@ss-sds.com', Division = 'TW', UserRoleId = usrRole.Id,
            EmployeeNumber = '123455'
        );
        insert usr;
        usr1 = new User(
            Alias = 'standt2', Email='abcde@samsung.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='ko_KR', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
            UserName='user00012@ss-sds.com', Division = 'TW', UserRoleId = usrRole1.Id,
            EmployeeNumber = '123455'
        );
        insert usr1; 
        Test.startTest();
        System.runAs(usr){
        HomeURLController.urlSetting();
        }
        System.runAs(usr1){
        HomeURLController.urlSetting();
        }
        
        Test.stopTest();
    }
    //End - Added by Anish - v 1.1
}