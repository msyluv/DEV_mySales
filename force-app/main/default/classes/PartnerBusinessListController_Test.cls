/**
 * @description       : 
 * @author            : zenith21c@test.com
 * @group             : 
 * @last modified on  : 02-20-2022
 * @last modified by  : zenith21c@test.com
**/
@isTest
private class PartnerBusinessListController_Test {
    @isTest 
    static void partnerBusinessList_Test() {
        Test.startTest();
        PartnerBusinessListController.getPartnerBusinessList();
		Test.stopTest();
    }
}