/**
 * @author            : younghoon.kim@dkbmc.com
 * @description       : [IF-154] Batch_AccountInfoLegacy의 테스트 코드
 * @last modified on  : 2022-06-17
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2022-03-22   younghoon.kim@dkbmc.com  Initial Version
**/
@isTest
private class Batch_AccountInfoLegacy_Test {
    static Account acc;

    static {
        RecordType rt = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'MDG' AND IsActive = TRUE];
        Account acc = new Account( 
            Name = '테스트 고객사',
            AccountNumber = 'A1234567',
            mAccNameE__c = 'Test Account',
            mBizLoan__c = '999',
            ITInvestmentCost__c = '100억',
            ITOperationExpense__c = '100억',
            ITSummary__c = '없음',
            CRMSummary__c = '없음',
            MESSummary__c = '없음',
            PLMSummary__c = '없음',
            ERPSummary__c = '없음',
            SCMSummary__c = '없음',
            InfraSummary__c = '없음',
            AISummary__c = '없음',
            EtcSummary__c = '없음',
            Innovation__c = '매우높음',
            SDSPreference__c = '좋음',
            LegalConditions__c = '보통',
            PaymentConditions__c = '낮음',
            FinacialHealth__c = 'C이하',
            RequirementsChange__c = '거의없음',
            OperatingProfits__c = '15%~',
            ProjectRisk__c = '거의없음',
            RecordTypeId = rt.Id
        );
        insert acc;
    }

    @isTest
    public static void AccountInfoLegacy_Test_1(){
        Test.startTest();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = '테스트 고객사' LIMIT 1];
        Set<Id> idSet = new Set<Id>();
        idSet.add(acc.Id);
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        DataBase.executeBatch(new Batch_AccountInfoLegacy(0, idSet), 200);
        Test.stopTest();
    }

    @isTest
    public static void AccountInfoLegacy_Test_2(){
        Test.startTest();
        Set<Id> idSet = new Set<Id>();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        DataBase.executeBatch(new Batch_AccountInfoLegacy(0, idSet), 200);
        Test.stopTest();
    }

    @isTest
    public static void AccountInfoLegacy_Test_3(){
        Test.startTest();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = '테스트 고객사' LIMIT 1];
        Set<Id> idSet = new Set<Id>();
        idSet.add(acc.Id);
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        DataBase.executeBatch(new Batch_AccountInfoLegacy(2, idSet), 200);
        Test.stopTest();
    }

    @isTest
    public static void AccountInfoLegacy_Test_4(){
        Test.startTest();
        Set<Id> idSet = new Set<Id>();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        DataBase.executeBatch(new Batch_AccountInfoLegacy(2, idSet), 200);
        Test.stopTest();
    }
}