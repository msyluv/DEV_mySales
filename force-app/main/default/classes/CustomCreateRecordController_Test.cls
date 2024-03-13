/**
 * @description       : Test Class for CustomCreateRecordController
 * @author            : gitesh.s@samsung.com
 * @group             : 
 * @last modified on  : 18-11-2022
 * @last modified by  : gitesh.s@smsung.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   18-11-2022   gitesh.s@samsung.com   Initial Version
**/
@isTest
private class CustomCreateRecordController_Test {
    static Partnership_Info__c partnerInfo;
    static SCP_Account__c SCP_Acc;
    static Account acc;
    static Employee__c emp;

    static {
        acc = new Account(Name = 'Test Account', MDGCheck__c = true);
        insert acc;
        acc.IsPartner = true;
        update acc;
        emp = new Employee__c(Name = 'Test Employee');
        insert emp;
        Date currentDate = System.today();
        Date nextDate = currentDate.addDays(1);
        SCP_Acc = new SCP_Account__c(SCP_Account_ID__c = 'ACCOUNT-12345', Name = 'Test Name',
                                    Customer__c = acc.Id, Contract_Start_Date__c = currentDate,
                                    WBS_Code__c = '1234', Partner__c = acc.Id,
                                    SDS_AM__c = emp.Id, SDS_PDM__c = emp.Id, Incentive__c = 'Y');
        insert SCP_Acc;
        partnerInfo = new Partnership_Info__c(Contract_Start_Date__c = currentDate, Contract_End_Date__c = nextDate,
                                                Account__c = acc.Id, SDS_PDM__c = emp.Id);
        insert partnerInfo;
    }

    @isTest
    static void getPartnershipInfo_Test() {
        Test.startTest();
        CustomCreateRecordController.getPartnershipInfo(acc.Id);
        Test.stopTest();
    }

    @isTest
    static void getSCPAccountInfo_Test() {
        Test.startTest();
        CustomCreateRecordController.getSCPAccountInfo(SCP_Acc.Id);
        Test.stopTest();
    }

    @isTest
    static void getPartnerAccount_Test() {
        Test.startTest();
        CustomCreateRecordController.getPartnerAccount(acc.Id);
        Test.stopTest();
    }

    @isTest
    static void checkApprovalStatus_Test() {
        Test.startTest();
        CustomCreateRecordController.checkApprovalStatus(SCP_Acc.Id);
        Test.stopTest();
    }

    @isTest
    static void getProfileInfo_Test() {
        Test.startTest();
        CustomCreateRecordController.getProfileInfo();
        Test.stopTest();
    }
}