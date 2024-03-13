/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2022-06-20
 * @last modified by  : younghoon.kim@dkbmc.com
**/
@isTest
public class Account_tr_Test {
    public static String RT_ACCOUNT_SALESFORCE_ID        = Account.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Salesforce').getRecordTypeId(); 
    public static String RT_ACCOUNT_MDG_ID = Account.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('MDG').getRecordTypeId();

    public static User user1;
    public static User user2;
    public static Account acc;
    public static Account accMDG;

    static {
        // Default Org Switch Setup (checkbox default true)
        TriggerSwitch__c trSwitch_default = new TriggerSwitch__c();        
        insert trSwitch_default;

        // Mig User Setting
        Employee__c emp1  = Utils_TestDataFactory.createEmployee('emp1', 'emp1');
        user1 = Utils_TestDataFactory.createUserFull(Utils_TestDataFactory.getProfile('Sales Rep.(HQ)')
                                                    , emp1.EvMailAddr__c
                                                    , emp1.EvUniqID__c);

        acc = new Account( 
            Name = 'Test Account'
            , RecordTypeId = RT_ACCOUNT_SALESFORCE_ID
            , OwnerId = user1.Id
        );
        
        accMDG = new Account( 
            Name = 'Test Account'
            , RecordTypeId = RT_ACCOUNT_MDG_ID
            , MDGCheck__c = true
            , OwnerId = user1.Id
        );
    }
    
    @isTest
    public static void deleteAccount_Test() {
        Test.startTest();
        System.runAs(user1) {            
            try {
                insert acc;
                delete acc;
                
                System.assert(true);
            } catch (Exception e) {
                System.assert(false, '[TEST ERROR] Account owners must be able to delete Salesforce record type Account. / ' + e.getMessage() );
            }            

            try {
                insert accMDG;
                delete accMDG;
                System.assert(false, '[TEST ERROR] All User cannot delete MDG Account.');
            } catch (Exception e) {
                System.assert(true);
            }
        }
        Test.stopTest();
    }

    @isTest
    public static void updateAccount_Test() {
        Test.startTest();
        // System.runAs(user1) {            
            accMDG.ITInvestmentCost__c = 'Test';
            accMDG.Innovation__c = '매우높음';
            accMDG.SDSPreference__c = '매우높음';
            insert accMDG;

            accMDG.Name = 'Test MDG Account';
            update accMDG;
        // }
        Test.stopTest();
    }
}