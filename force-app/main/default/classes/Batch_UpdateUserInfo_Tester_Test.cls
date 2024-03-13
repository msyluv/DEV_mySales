@isTest(SeeAllData = false)
public class Batch_UpdateUserInfo_Tester_Test {
    static Employee__c emp1;
    static Employee__c emp2;
    static Employee__c emp3;
    static User user1;
    static User user2;
    
    static{
        List<Employee__c> empList = new List<Employee__c>();
        emp1 = new Employee__c(
            Name = 'TestEmp1',
            EvMailAddr__c = 'TestEmp1@samsung.com',
            EvUniqID__c = 'EPID1',
            EvSapBukrs__c = 'T500',
            Status__c = 'R'
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
            EvKostl__c = 'T100-12430',
            EvDept__c = 'C60AJ823'
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
            EvKostl__c = 'T100-12430',
            EvDept__c = 'C60AJ823'
        );
        empList.add(emp3);

        insert empList;

        List<User> userList = new List<User>();
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name = '시스템 관리자' OR Name = 'System Administrator'];
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

        insert userList;
    }
    
    @isTest
    public static void UpdateUserInfoTest_1(){
        Test.startTest();
        System.runAs(user1) {
            List<Employee__c> empList = [SELECT Id, Name, EvUniqID__c, EvSapBukrs__c, EvKostl__c FROM Employee__c];
            List<User> userList = [SELECT Id, Name, EmployeeNumber, FederationIdentifier, CompanyCode__c FROM User];
            //System.debug('empList@ : ' + empList);
            System.debug('userList@ : ' + userList);
            System.debug('userList@ : ' + userList.size());
            DataBase.executeBatch( new Batch_UpdateUserInfo_Tester(), userList.size());
        }
        Test.stopTest();
    }

    // static User user1;    
    // static Employee__c emp1;    
    // static Company__c comp1;
    // 
    // @TestSetup
    // static void makeData(){
    //     Profile profile = [SELECT Id, Name FROM Profile WHERE Name = '시스템 관리자' OR Name = 'System Administrator'];
    //     user1 = new User(
    //         Alias = 'testUser',
    //         Email = 'TestEmp1@samsung.com',
    //         EmailEncodingKey = 'UTF-8',
    //         LastName = 'Testing',
    //         LanguageLocaleKey = 'en_US',
    //         LocaleSidKey = 'en_US',
    //         EmployeeNumber = 'AC100000',
    //         TimeZoneSidKey = 'Asia/Seoul',
    //         ProfileId = profile.Id,
    //         UserName = 'TestEmp1@samsung.com',
    //         FederationIdentifier = 'EPID1',
    //         CompanyCode__c = 'T100'
    //     );
    //     insert user1;
    //     
    //     emp1 = new Employee__c(
    //         Name = 'TestEmp1',
    //         EvMailAddr__c = 'TestEmp1@samsung.com',
    //         EvUniqID__c = 'EPID1',
    //         EvSapBukrs__c = 'T100',
    //         Status__c = null,
    //         EvTitleJikChakNM__c = 'Principal Engineer',
    //         EvCellTel__c = '+82-10-1111-0000',
    //         EvCompNM__c = 'SDS',
    //         EvCompany__c = 'C60',
    //         EvKostl__c = 'T100-12430',
    //         EvDept__c = 'C60AJ823'
    //     );
    //     insert emp1;
    //     
    //     comp1 = new Company__c(
    //     	Name = 'Samsung SDS', 
    //         CompanyCode__c = 'T100', 
    //         EPCompanyName__c = 'SDS'
    //     );
    //     insert comp1;
    // }
    // 
    // @isTest
    // static void UpdateUserInfoTest_1(){
    //     Test.startTest();
    //     
    //     User user1 = [SELECT Id, Name, FederationIdentifier FROM User WHERE FederationIdentifier = 'EPID1'];
    //     System.runAs(user1) {
    //         DataBase.executeBatch( new Batch_UpdateUserInfoController(), 500);
    //     }
    //     
    //     Test.stopTest();
    // }
}