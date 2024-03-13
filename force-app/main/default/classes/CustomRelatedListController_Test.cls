/**
 * @description       : Test Class for CustomRelatedListController
 * @author            : gitesh.s@samsung.com
 * @group             : 
 * @last modified on  : 20-12-2022
 * @last modified by  : gitesh.s@smsung.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   20-12-2022   gitesh.s@samsung.com   Initial Version
**/
@isTest
private class CustomRelatedListController_Test {
    static SCP_Account__c SCP_Acc;
    static MSP_Project__c MSP_Proj;
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
                                    SDS_AM__c = emp.Id, SDS_PDM__c = emp.Id,  Incentive__c = 'Y');
        insert SCP_Acc;
        MSP_Proj = new MSP_Project__C(SCP_Account_ID__c = SCP_Acc.Id,
                                     Name = 'PROJECT-1234', Project_Name__c = 'Test Project Name',
                                     Estimated_Monthly_Fee_Won__c = 100, Partner_AM__c = emp.Id,
                                     Partner_PM__c = emp.Id);
        insert MSP_Proj;
    }
    
    @isTest
    static void getObjectName_Test() {
        Test.startTest();
        CustomRelatedListController.getObjectName(SCP_Acc.Id);
        Test.stopTest();
    }

    @isTest
    static void getCurrentRecord_Test() {
        Test.startTest();
        CustomRelatedListController.getCurrentRecord(SCP_Acc.Id);
        Test.stopTest();
    }

    @isTest
    static void getRelatedRecords_Test() {
        Test.startTest();
        CustomRelatedListController.getRelatedRecords(SCP_Acc.Id);
        Test.stopTest();
    }

    @isTest
    static void getMSPRecord_Test() {
        Test.startTest();
        CustomRelatedListController.getMSPRecord(MSP_Proj.Id);
        Test.stopTest();
    }

    @isTest
    static void deleteMSPRecord_Test() {
        Test.startTest();
        CustomRelatedListController.deleteMSPRecord(MSP_Proj.Id);
        Test.stopTest();
    }

    @isTest
    static void checkApprovalStatus_Test() {
        Test.startTest();
        CustomRelatedListController.checkApprovalStatus(SCP_Acc.Id);
        Test.stopTest();
    }

    @isTest
    static void getProfileInfo_Test() {
        Test.startTest();
        CustomRelatedListController.getProfileInfo();
        Test.stopTest();
    }
}