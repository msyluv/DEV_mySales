@isTest
private class PartnerPrivacyPolicyController_Test {
    @isTest 
    static void getPartnerPrivacyPolicyVersion_Test() {
        Test.startTest();
        PartnerPrivacyPolicyController.getPartnerPrivacyPolicyVersion();
		Test.stopTest();
    }

    @isTest 
    static void getTermsOfServiceVersion_Test() {
        Test.startTest();
        PartnerPrivacyPolicyController.getTermsOfServiceVersion();
		Test.stopTest();
    }
}