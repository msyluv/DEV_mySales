/**
 * @description       : 
 * @author            : jiiiiii.park@partner.samsung.com.sds.dev
 * @group             : 
 * @last modified on  : 2022-05-24
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   2020-12-01   jiiiiii.park@partner.samsung.com.sds.dev   Initial Version
**/
@isTest
public class MDGAccountNewControllerTest {
    static Account acc;
    static User user;
    static Employee__c emp;

    static{
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
        user = new User(
            Alias = 'standt1', 
            Email='user0001@samsung.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Seoul',
            UserName='user0001@samsung.com', 
            EmployeeNumber='1234');
        insert user;

        Employee__c emp = new Employee__c(
            Name = 'Test',
            EvCompany__c = 'C60',
            EvDept__c = 'C60AJ760',
            EvUniqId__c = 'M200810085139C603253',
            EvSapEmpNO__c = '36549',
            EvStatus__c = '1'
        );
        insert emp;

        acc = new Account(
            Name = 'accTest',
            mCountry__c = 'KR',
            BillingCountry = 'Korea, Republic of',
            BillingStreet = 'Test',
            BillingState = 'Seoul',
            BillingCity = 'Test',
            BillingPostalCode = '00000',
            mBizTypeL1Code__c = 'L100',
            mBizTypeL2Code__c = 'L101',
            CorporateNumber__c = '0000000000',
            mDomesticForeign__c = '10',
            mCEOName__c = 'TestCEO',
            OwnerId = user.Id
        );
        insert acc;
    }
    
    @isTest static void test_method_one() { //처음 저장
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        MDGAccountNewController.getAccountInfo(acc.Id);
		Test.stopTest();
    }
    
    @isTest static void test_method_two() {//사업자번호 10자리 x
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        acc.CorporateNumber__c = '123';
        update acc;
        MDGAccountNewController.getAccountInfo(acc.Id);
		Test.stopTest();
    }

    @isTest static void test_method_three() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        MDGAccountNewController.AccountTendencySync();
		Test.stopTest();
    }
}