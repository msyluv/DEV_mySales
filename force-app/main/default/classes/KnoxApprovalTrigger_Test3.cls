/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2022-01-03
 * @last modified by  : younghoon.kim@dkbmc.com
**/
@isTest
public class KnoxApprovalTrigger_Test3 {
    @TestSetup
    static void setData(){
        Employee__c emp_1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'EPID1');
        User user_1 = Utils_TestDataFactory.createUserFull(Utils_TestDataFactory.getProfile('Sales Rep.(HQ)'), emp_1.EvMailAddr__c, emp_1.EvUniqID__c);
    }

    private static testMethod void test01() {
        Test.startTest();
        Test.stopTest();
    }
}