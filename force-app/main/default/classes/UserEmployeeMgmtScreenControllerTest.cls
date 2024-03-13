/**
* @description       : UserEmployeeManagementScreenController Test
* @author            : akash.g@samsung.com
* @group             : 
* @last modified on  : 2024-01-29
* @last modified by  : atul.k1@samsung.com
* Modifications Log 
* Ver   Date         Author                 Modification
* 1.0   2021-11-02   akash.g@samsung.com    Initial Version
* 1.1	2023-11-08	 sarthak.j1@samsung.com    UserEmployee Management function enhancement -> MYSALES-338
* 1.2	2024-01-29	 atul.k1@samsung.com       Mobile Permission Set Add -> MYSALES-420


**/
@isTest
public class UserEmployeeMgmtScreenControllerTest {
    
    static User u;
    static Employee__c	 emp1;
    
    static{
        user admin = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs (admin) {
            Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
            u = new User(Alias = 'standt1', Email='test1@samsung.com', 
                         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                         LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                         UserName='user0001@samsung.com');
            insert u;
        }
       
    }
    
    
    
    @isTest static void test_createUserFun(){
        Test.startTest();
        UserEmployeeManagementScreenController.getLicenceDetail();
        UserEmployeeManagementScreenController.returnObject rtnObj = new UserEmployeeManagementScreenController.returnObject();
        rtnObj.name = 'test1';
        rtnObj.email = 'testingprod1@samsung.com';
        rtnObj.langLocalKey = 'en_US';
        UserEmployeeManagementScreenController.returnObject rtnObj1 = new UserEmployeeManagementScreenController.returnObject();
        rtnObj1.name = 'test11';
        rtnObj1.email = 'testingprod11@samsung.com';
        rtnObj1.langLocalKey = 'en_US';
        // Start v 1.1 (MYSALES-338)
        // adding TestCompCode, TestCompName, false arguments
        Id ids =UserEmployeeManagementScreenController.createUserFun('System Administrator', '제안PM' , false ,true, rtnObj , 'Testfirst', 'TestLast', 'TestCompCode', 'TestCompName', false);
        Id idsNew =UserEmployeeManagementScreenController.createUserFun('System Administrator', '제안PM' , true ,true, rtnObj1 , 'Testfirst1', 'TestLast1', 'TestCompCode1', 'TestCompName1', true);
        // End v 1.1 (MYSALES-338)
        Test.stopTest();
    }
    @isTest static void test_getEmployeeResult1(){
        emp1 = new Employee__c(
            EvMailAddr__c = 'test1@samsung.com'
        );
        insert emp1;
        Map<String, String> strMap = UserEmployeeManagementScreenController.getEmployeeResult('test1@samsung.com');
    }
    
    @isTest static void test_getEmployeeResult2(){
        emp1 = new Employee__c(
            EvMailAddr__c = 'test1@samsung.com',
            EvSapBukrs__c = 'T100'
        );
        insert emp1;
        Map<String, String> strMap = UserEmployeeManagementScreenController.getEmployeeResult('test1@samsung.com');
    }
    
     @isTest static void test_getEmployeeResult3(){
        emp1 = new Employee__c(
            EvMailAddr__c = 'test1@samsung.com',
            EvSapBukrs__c = 'T100'
        );
        insert emp1;
        Employee__c emp2 = new Employee__c(
            EvMailAddr__c = 'test1@samsung.com',
            EvSapBukrs__c = 'T100'
        );
        insert emp2;
        
        Map<String, String> strMap = UserEmployeeManagementScreenController.getEmployeeResult('test1@samsung.com');
    }
    // Start v 1.1 (MYSALES-338)
    @isTest static void test_getEmployeeResult4(){
        emp1 = new Employee__c(
            EvMailAddr__c = 'test1@samsung.com',
            EvSapBukrs__c = 'T100'
        );
        insert emp1;
        Employee__c emp2 = new Employee__c(
            EvMailAddr__c = 'test1@samsung.com',
            EvSapBukrs__c = 'T101'
        );
        insert emp2;
        
        Map<String, String> strMap = UserEmployeeManagementScreenController.getEmployeeResult('test1@samsung.com');
    }
    // End v 1.1 (MYSALES-338)
    @isTest static void test_updateUser(){
        Test.startTest();
        
        // Start v 1.1 (MYSALES-338)
        UserEmployeeManagementScreenController.getLicenceDetail();
        UserEmployeeManagementScreenController.returnObject rtnObj = new UserEmployeeManagementScreenController.returnObject();
        rtnObj.name = 'test1';
        rtnObj.email = 'testingprod1@samsung.com';
        rtnObj.langLocalKey = 'en_US';
        // adding TestCompCode, TestCompName, false, rtnObj arguments
        UserEmployeeManagementScreenController.updateUser('System Administrator', '제안PM' , true,true, u.Id , 'testFirst' , 'testLast', 'TestCompCode', 'TestCompName', false, rtnObj);
        // End v 1.1 (MYSALES-338)
        Test.stopTest();
    }
    
}