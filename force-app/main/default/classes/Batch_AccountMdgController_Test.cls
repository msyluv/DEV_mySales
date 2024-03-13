/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 02-19-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   01-12-2021   soohong0.kim@partner.samsung.com   Initial Version
**/


//Batch_AccountController, Batch_AccountSalesAreaController 의 Test Class
@isTest
public class Batch_AccountMdgController_Test {
    @TestSetup
    static void setData(){

        MDGAccount__c mAcc = new MDGAccount__c();
        mAcc.Type__c = 'A';
        mAcc.BP_HEADER__c = 'test';
        mAcc.isBatch__c = 'N';
        mAcc.NAME1__c = 'test';
        mAcc.ExternalId__c = 'test1';
        insert mAcc;

        MDGAccount__c sales = new MDGAccount__c();
        sales.Type__c = 'S';
        sales.BP_HEADER__c = 'test';
        sales.AWAHR__c = '1';
        sales.ANTLF__c = '1';
        sales.LPRIO__c = '1';
        sales.isBatch__c = 'N';
        sales.ExternalId__c = 'test2';
        insert sales;
    }
    private static testMethod void test01() {
        Test.startTest();
        Database.executeBatch(new Batch_AccountController());
        Test.stopTest();
    }
}