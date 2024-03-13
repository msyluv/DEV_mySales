/**
* @description       : Testclass for Logistics CP Review comp
* @author            : Kajal.c@samsung.com
* @group             : 
* @last modified on  : 2022-11-16
* @last modified by  : Kajal.c@samsung.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   2022-11-16   Kajal.c@samsung.com   Initial Version
**/
@isTest
public class LogisticsCPReviewComp_Test {

    @TestSetup
    static void setData(){
        Account acc = new Account (
        Name = 'Test123');
        Organization__c org = new Organization__c();
        insert org;
        List<Opportunity> OppList = new List<Opportunity>();
        Opportunity LogiOpportunity = new Opportunity(
            Name = 'MySales1',
            Type = 'New Opportunity',
            CurrencyIsoCode='EUR',
            OpportunityCode__c='SDS-22131801',
            StageName= 'Qualified',
            LogisticsBizDevelopmentType__c = '01',
            Amount = 78,
            BiddingDeadline__c = System.today() + 30,
            //LogisticsServiceType__c = '01',
            LogisticsBizType__c = '02',
            cRevenueStartDate__c = System.today() - 10,
            cRevenueEndDate__c = System.today() + 10,
            AccountId = acc.id,
            LogisticsCustomerType__c = 'SECSET',
            SubIndusrty__c = '01',
            SalesOrganization__c = org.id,
            DeliveryOrganization__c = org.id,
            CloseDate = System.today(),
            Opportunity_Logistics_CPReviewStatus_FIN__c = 'REQ'
            );
        
         Opportunity LogiOpportunity1 = new Opportunity(
            Name = 'MySales12',
            Type = 'New Opportunity',
            CurrencyIsoCode='EUR',
            OpportunityCode__c='SDS-22131801',
            StageName= 'Qualified',
            LogisticsBizDevelopmentType__c = '01',
            Amount = 78,
            BiddingDeadline__c = System.today() + 30,
            //LogisticsServiceType__c = '01',
            LogisticsBizType__c = '02',
            cRevenueStartDate__c = System.today() - 10,
            cRevenueEndDate__c = System.today() + 10,
            AccountId = acc.id,
            LogisticsCustomerType__c = 'SECSET',
            SubIndusrty__c = '01',
            SalesOrganization__c = org.id,
            DeliveryOrganization__c = org.id,
            CloseDate = System.today(),
            Opportunity_Logistics_CPReviewStatus_FIN__c = 'CNFM'
            );
        
        OppList.add(LogiOpportunity);
        OppList.add(LogiOpportunity1);
        insert OppList;
        Opportunity_Activity__c Oppact =new Opportunity_Activity__c(
        WhatId__c = LogiOpportunity.id,
        Status__c = null,
        TransactionName__c = '2.4.4'
        );
        
        insert Oppact;
        
        Logistics_CP_Review_YesorNo__c logis = new Logistics_CP_Review_YesorNo__c(
            Opportunity__c = LogiOpportunity1.id,
            	IsConfirm__c = true);
        insert logis ;
        
    }
     @IsTest
	   private static void testMethod1() {
        Test.startTest();
        LogisticsCPReviewComp.getLogisticsCPReviewData();
        Test.stopTest();
        }
     @IsTest
	   private static void testMethod2() {
        Test.startTest();
        List<opportunity> oppty = [Select ID from opportunity];
        for(Opportunity opp :oppty){
        LogisticsCPReviewComp.getURL(null,opp.id,null);
        LogisticsCPReviewComp.updateOpp(opp.id);
        LogisticsCPReviewComp.getOppData(opp.id);
        LogisticsCPReviewComp.getLevelvalue(opp.id);
        LogisticsCPReviewComp.updateAndInsertLogisticsYesorNo(opp.id ,'No','No','No','No');
        }
        Test.stopTest();   
}
 @IsTest
    private static void testIsConfirmData() {
        Test.startTest();
        Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Opportunity_Logistics_CPReviewStatus_FIN__c = 'CNFM' LIMIT 1];
        if (testOpp != null) {
            Boolean isConfirm = true;
            String result = LogisticsCPReviewComp.IsConfirmData(testOpp.Id, isConfirm);
            System.assertNotEquals(null, result);
        } else {
            System.debug('No Opportunity with status CNFM found. Skipping testIsConfirmData.');
        }
        Test.stopTest();
    }
     /**
        @IsTest
    private static void testSaveCargoesvalue() {
        Test.startTest();
        Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Opportunity_Logistics_CPReviewStatus_FIN__c = 'CNFM' LIMIT 1];
        if (testOpp != null) {
            String boId = testOpp.Id;
            String cargoesValue = 'TestCargoesValue';
            String result = LogisticsCPReviewComp.saveCargoesvalue(boId, cargoesValue);
            System.assertNotEquals(null, result);
        }
        Test.stopTest();
    }   
**/
}