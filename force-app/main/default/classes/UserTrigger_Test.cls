/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 2023-09-27            
 * @last modified by  : vikrant.ks@samsung.com  
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   08-31-2022   gitesh.s@samsung.com    Added Community Login Profile
 * 1.1   2023-09-27   vikrant.ks@samsung.com  Added record of different objects(MySales-307)
 * 1.2   2024-02-07   Atul.k1@samsung.com     MFA Application to MSP Portal (MySales-444)        
**/
@isTest
private class UserTrigger_Test {
    
    static User user, userLoginProfile, mspAdmin;
    //v1.1 Start
    static Employee__c emp1;
    static Employee__c emp2;
    static Employee__c emp3;
    static User user1;
    static User user2;
    static List<User> userList = new List<User>();
    //v1.1 End
    static {
        Account a = new Account(Name='Test');
        insert a;
        
        Contact c = new Contact(LastName = 'Test', AccountId = a.id);
        insert c;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Partner Community Manager'];

        /*Ver 1.0 Added Community Login Profile*/
        Profile loginProfile = [SELECT Id FROM Profile WHERE Name = 'Partner Community Login Manager'];

        userLoginProfile = new User(Alias = 'Login', Email='TestLogin@Test.com', ContactId = c.Id, 
                        EmailEncodingKey='UTF-8', LastName='Login', FirstName='Community', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = loginProfile.Id, TimeZoneSidKey='Asia/Seoul', 
                        UserName='user0002@samsung.com');
        
        mspAdmin = [Select Id From User Where Profile.Name='MSP Admin' and isActive=true Limit 1];
        user = new User(Alias = 'Test', Email='Test@Test.com', ContactId = c.Id, 
                        EmailEncodingKey='UTF-8', LastName='Test', FirstName='Test', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                        UserName='user0001@samsung.com');
        
        //v1.1 Start
        Company__c company = new Company__c();
        company.CompanyCode__c = 'T100';
        company.CompanyFullName__c = 'Samsung SDS';
        company.EPCompanyName__c = 'SDS';
        
        insert company;
        
        CostCenter__c costCenter = new CostCenter__c();
        costCenter.Text2__c = 'Business Management Division';
        costCenter.Text3__c = 'People Team';
        costCenter.Text4__c = 'People Team';
        costCenter.Text5__c = 'People Team';
        costCenter.CostCenter__c='T302-31000';
        insert costCenter;
        List<Employee__c> empList = new List<Employee__c>();
        emp1 = new Employee__c(
            Name = 'TestEmp1',
            EvMailAddr__c = 'TestEmp1@samsung.com',
            EvUniqID__c = 'EPID1',
            EvSapBukrs__c = 'T500',
            Status__c = 'R',
            EvKostl__c = 'T302-31000'
        );
        empList.add(emp1);

        emp2 = new Employee__c(
            Name = 'TestEmp2',
            EvMailAddr__c = 'TestEmp2@samsung.com',
            EvUniqID__c = 'EPID2',
            EvSapBukrs__c = 'T100',
            Status__c = null,
            EvTitleJikChakNM__c = 'Principal Engineer',
            EvCellTel__c = '+82-10-1111-0000',
            EvCompNM__c = 'SDS',
            EvCompany__c = 'C60',
            EvDept__c = 'C60AJ823',
            EvKostl__c = 'T302-31000'
        );
        empList.add(emp2);

        emp3 = new Employee__c(
            Name = 'TestEmp3',
            EvMailAddr__c = 'TestEmp3@samsung.com',
            EvUniqID__c = 'EPID3',
            EvSapBukrs__c = 'T100',
            Status__c = null,
            EvTitleJikChakNM__c = 'Principal Engineer',
            EvCellTel__c = '+82-10-1111-2222',
            EvCompNM__c = 'SDS',
            EvCompany__c = 'C60',
            EvDept__c = 'C60AJ823',
            EvKostl__c = 'T302-31000'
        );
        empList.add(emp3);

        insert empList;
        
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name = '시스템 관리자' OR Name = 'System Administrator'];
        
        userList.add(user);
        user1 = new User(
            Alias = 'testUser',
            Email = 'TestEmp2@samsung.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            EmployeeNumber = 'AC100000',
            TimeZoneSidKey = 'Asia/Seoul',
            ProfileId = profile.Id,
            UserName = 'TestEmp2@samsung.com',
            FederationIdentifier = 'EPID2',
            CompanyCode__c = 'T100'
        );
        userList.add(user1);

        user1 = new User(
            Alias = 'testUser',
            Email = 'TestEmp3@samsung.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            EmployeeNumber = 'AC100000',
            TimeZoneSidKey = 'Asia/Seoul',
            ProfileId = profile.Id,
            UserName = 'TestEmp3@samsung.com',
            FederationIdentifier = 'EPID3',
            CompanyCode__c = 'T100'
        );
        userList.add(user1);
		//v1.1 End
    }
    
    @isTest
    public static void createUser() {
        Test.startTest();
        System.runAs(mspAdmin){
            insert userList; //v1.1
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
    // V 1.2 MYSALES-444 Start
    @isTest
    public static void updateCommunityLoginUser() {
        Test.startTest();
        System.runAs(mspAdmin){
            user = [SELECT id,name,isActive FROM user where LastName='Login' limit 1];
            user.IsActive = false;
            update user;
            user.IsActive = true;
            update user;
            
        }
        Test.stopTest();
    }
    // V 1.2 MYSALES-444 End
   
}