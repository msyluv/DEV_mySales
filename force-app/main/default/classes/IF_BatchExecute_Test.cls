@isTest
public class IF_BatchExecute_Test {
    public static User user1;
    
    static{
        Employee__c emp1  = Utils_TestDataFactory.createEmployee('emp1', 'emp1');
        user1 = Utils_TestDataFactory.createUserFull(Utils_TestDataFactory.getProfile('Sales Rep.(HQ)')
                                                    , emp1.EvMailAddr__c
                                                    , emp1.EvUniqID__c);
        
    }
    
    @isTest
    public static void method_01(){
        Test.startTest();
        IF_BatchExecute.getInfo();
        IF_BatchExecute.updateRestoreUserProfile();
        IF_BatchExecute.IFbatchExecute();
        IF_BatchExecute.getCronTriggerList();
        IF_BatchExecute.getBackupProfileList();
        IF_BatchExecute.updateReadOnlyProfile();
        Test.stopTest();
    }
    
    
}