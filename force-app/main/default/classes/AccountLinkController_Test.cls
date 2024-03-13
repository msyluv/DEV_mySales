/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 02-03-2022
 * @last modified by  : ukhyeon.lee@samsung.com
**/
@isTest
private class AccountLinkController_Test {
    static Account acc;
    static final String ACC_NO = '12345';
    
    static {
        acc = new Account(
            Name = 'Test Account',
        	AccountNumber = ACC_NO
        );
        insert acc;
    }
	
    
    @isTest static void test_method_1() {
        Test.startTest();
        AccountLinkController.getAccountId(ACC_NO);
		Test.stopTest();
	}
}