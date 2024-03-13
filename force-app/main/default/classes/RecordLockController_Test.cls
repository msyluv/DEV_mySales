/**
 * @description       : 
 * @author            : leehyo
 * @last modified on  : 2021-01-26
 * @last modified by  : hj.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   2020-12-16   leehyo   Initial Version
**/
@isTest
private class RecordLockController_Test {
    static RecordType RT_OPPTY_HQ;
    static RecordType RT_OPPTY_LOGISTICS;

    static {
        RT_OPPTY_HQ        = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
        RT_OPPTY_LOGISTICS = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Logistics' Limit 1];
    
        
        Account accAct = new Account(Name = 'accTest');
        insert accAct;

        Opportunity oper = new Opportunity(Name ='Test' , RecordTypeId = RT_OPPTY_HQ.Id ,AccountId =accAct.Id
                                             ,CloseDate =System.today() ,StageName = 'Z01');
        insert oper;
    }
    
    @isTest static void test_method_one() {
		Test.startTest();

        Opportunity oppty = [SELECT Id FROM Opportunity LIMIT 1];

        RecordLockController.initComponent(oppty.Id);
        RecordLockController.lockRecord(oppty.Id);
        RecordLockController.unlockRecord(oppty.Id);

		Test.stopTest();
	}
}