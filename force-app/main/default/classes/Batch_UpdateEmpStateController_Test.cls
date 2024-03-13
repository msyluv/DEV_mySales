/**
 * @description       : 
 * @author            : yeongju.baek@dkbmc.com
 * @group             : 
 * @last modified on  :  10-04-2023
 * @last modified by  : saurav.k@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   10-21-2021   yeongju.baek@dkbmc.com           Initial Version
 * 1.1   10-04-2023   saurav.k@partner.samsung.com     Handling user inactivation related to employee deletion(MySales- 164)
**/
@isTest
public class Batch_UpdateEmpStateController_Test {
    
    @TestSetup
    private static void setData(){
        Employee__c emp1 = new Employee__c();
        Employee__c emp2 = new Employee__c();

        //emp1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'EPID1');
        emp1.Status__c = 'R';
        emp1.EvCellTel__c = '0000-0000';
        emp1.EvCompTel__c = '1111-1111';
        emp1.CreatedDate = Datetime.now().addDays(-30);
        emp1.LastModifiedDate = Datetime.now().addDays(-20);
        emp1.EvMailAddr__c = 'testing2@samsung.com';//V 1.1- MYSALES: 164
        insert emp1;

        //emp2 = Utils_TestDataFactory.createEmployee('TestEmp2', 'EPID2');
        emp2.Status__c = null;
        emp2.EvCellTel__c = '+82-10-1111-0000';
        emp2.EvCompTel__c = '1111-1111';
        emp2.CreatedDate = Datetime.now().addDays(-44);
        emp2.LastModifiedDate = Datetime.now().addDays(-40);
		emp2.EvMailAddr__c = 'testing@samsung.com';//V 1.1- MYSALES: 164
        
        insert emp2;
    }
    @isTest
    public static void Test_Batch_UpdateEmpStatecontroller_excute1(){
        Test.startTest();
        System.debug([SELECT Id, Name, EmployeeNumber, FederationIdentifier, CompanyCode__c FROM User]);
        DataBase.executeBatch( new Batch_UpdateEmpStatecontroller(), 10);
        
        Test.stopTest();
    }
}