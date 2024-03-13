/**
* @description       : Test Class for Batch_Employee_Deletion
* @author            : waris.m@samsung.com
* @group             : 
* @last modified on  : 2024-03-07
* @last modified by  : waris.m@samsung.com 
* Modifications Log 
* Ver   Date         Author                      Modification
* 1.0   2024-03-07   waris.m@samsung.com          MYSALES-455
**/
@isTest
public class Batch_Employee_Deletion_Test {
    @isTest
    static void batchTest()
    {
      Employee__c emp1= new Employee__c();
      emp1.Name='Test Employee1';
      emp1.Status__c='R';
      insert emp1;
      Test.startTest();
      Batch_Employee_Deletion batch1= new Batch_Employee_Deletion();
      Id batchID = Database.executeBatch(batch1);
      Test.stopTest();
      
    }
}