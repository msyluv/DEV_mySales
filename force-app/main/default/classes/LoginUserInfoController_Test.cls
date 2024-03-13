/**
 * @description       : 
 * @author            : jiiiiii.park@partner.samsung.com.sds.dev
 * @group             : 
 * @last modified on  : 2020-11-17
 * @last modified by  : jiiiiii.park@partner.samsung.com.sds.dev
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   2020-11-17   jiiiiii.park@partner.samsung.com.sds.dev   Initial Version
**/
@isTest
private class LoginUserInfoController_Test {
    @isTest static void test_method_1() {
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
        	LoginUserInfoController.getLoginUserInfo();    
        }
		Test.stopTest();
    }
}