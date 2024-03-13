/**
 * @description       : 
 * @author            : Gitesh Saini
 * @last modified on  : 28-10-2022
 * @last modified by  : gitesh.s@samsung.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   28-10-2022   gitesh.s@samsung.com   Initial Version
**/
@isTest
private class OpportunityActivityLinkButtonCont_Test {
    @isTest
    static void getRecordTypeHQ_Test() {
        Test.startTest();
        OpportunityActivityLinkButtonController.getRecordTypeHQ();
		Test.stopTest();
    }

    @isTest
    static void getRecordTypeLogistics_Test() {
        Test.startTest();
        OpportunityActivityLinkButtonController.getRecordTypeLogistics();
		Test.stopTest();
    }

    @isTest
    static void checkOrg_Test() {
        Test.startTest();
        OpportunityActivityLinkButtonController.checkOrg();
		Test.stopTest();
    }
}