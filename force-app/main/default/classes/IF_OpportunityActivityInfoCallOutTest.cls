/**
* @description       : 
* @author            : Kajal.c@samsung.com
* @group             : 
* @last modified on  : 2023-03-09
* @last modified by  : Kajal.c@samsung.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   2023-03-09   Kajal.c@samsung.com     Initial Version 
**/
@isTest
public class IF_OpportunityActivityInfoCallOutTest {

      final static String REQUEST_URL = '/services/apexrest/WebService/IF180';
      Set<Opportunity> oppty = new Set<Opportunity>();
      public static Opportunity HQOpportunity;
      public static CostCenter__c CostCenter;
      public static Opportunity_Activity__c OpAct;
      public static Opportunity_Activity__c OpAct1;
     @isTest
      static void setData(){
        Account acc = Utils_TestDataFactory.createAccount('TestAcc');
        acc.MDGCheck__c = true;
        update acc;
         
        Organization__c org = new Organization__c();
        insert org;
        HQOpportunity = new Opportunity(
            Name = 'MySales01',
            CurrencyIsoCode='EUR',
            OpportunityCode__c='SDS-22131801',
            CloseDate = System.today() + 30,
            StageName= 'Z01',
            Amount = 78,
            AccountId = acc.id,
            cOriginAcc__c = acc.id,
            CspMspType__c = 'N/A'
        );
        
        insert HQOpportunity;
      
        //Opportunity_Activity__c act1 = new Opportunity_Activity__c(WhatId__c  = HQOpportunity.Id, TransactionName__c = 'XP99', Status__c = 'Completed', EndDate__c = Date.today());
        Opportunity_Activity__c act2 = new Opportunity_Activity__c(WhatId__c  = HQOpportunity.Id, TransactionName__c = 'ZP21', Status__c = 'Completed', EndDate__c = Date.today());
        Opportunity_Activity__c act3 = new Opportunity_Activity__c(WhatId__c  = HQOpportunity.Id, TransactionName__c = 'XP61', Status__c = 'Completed', EndDate__c = Date.today());
        Opportunity_Activity__c act4 = new Opportunity_Activity__c(WhatId__c  = HQOpportunity.Id, TransactionName__c = 'XP62', Status__c = 'Completed', EndDate__c = Date.today());
        Opportunity_Activity__c act5 = new Opportunity_Activity__c(WhatId__c  = HQOpportunity.Id, TransactionName__c = 'XP63', Status__c = 'Completed', EndDate__c = Date.today());
        Opportunity_Activity__c act6 = new Opportunity_Activity__c(WhatId__c  = HQOpportunity.Id, TransactionName__c = 'XP71', Status__c = 'Completed', EndDate__c = Date.today());
        Opportunity_Activity__c act7 = new Opportunity_Activity__c(WhatId__c  = HQOpportunity.Id, TransactionName__c = 'XP72', Status__c = 'Completed', EndDate__c = Date.today());
        Opportunity_Activity__c act8 = new Opportunity_Activity__c(WhatId__c  = HQOpportunity.Id, TransactionName__c = 'XP73', Status__c = 'Completed', EndDate__c = Date.today());
        Opportunity_Activity__c act9 = new Opportunity_Activity__c(WhatId__c  = HQOpportunity.Id, TransactionName__c = 'ZP32', Status__c = 'Completed', EndDate__c = Date.today());
        Opportunity_Activity__c act10 = new Opportunity_Activity__c(WhatId__c  = HQOpportunity.Id, TransactionName__c = 'XP31', Status__c = 'Completed', EndDate__c = Date.today());
        Opportunity_Activity__c act11 = new Opportunity_Activity__c(WhatId__c  = HQOpportunity.Id, TransactionName__c = 'ZP61', Status__c = 'Completed', EndDate__c = Date.today());
        Opportunity_Activity__c act12 = new Opportunity_Activity__c(WhatId__c  = HQOpportunity.Id, TransactionName__c = 'XP41', Status__c = 'Completed', EndDate__c = Date.today());
        Opportunity_Activity__c act13 = new Opportunity_Activity__c(WhatId__c  = HQOpportunity.Id, TransactionName__c = 'XP42', Status__c = 'Completed', EndDate__c = Date.today());
        Opportunity_Activity__c act14 = new Opportunity_Activity__c(WhatId__c  = HQOpportunity.Id, TransactionName__c = 'XP43', Status__c = 'Completed', EndDate__c = Date.today());
        Opportunity_Activity__c act15 = new Opportunity_Activity__c(WhatId__c  = HQOpportunity.Id, TransactionName__c = 'XP44', Status__c = 'Completed', EndDate__c = Date.today());
        Opportunity_Activity__c act16 = new Opportunity_Activity__c(WhatId__c  = HQOpportunity.Id, TransactionName__c = 'XP51', Status__c = 'Completed', EndDate__c = Date.today());
        Opportunity_Activity__c act17 = new Opportunity_Activity__c(WhatId__c  = HQOpportunity.Id, TransactionName__c = 'XP52', Status__c = 'Completed', EndDate__c = Date.today());
        Opportunity_Activity__c act18 = new Opportunity_Activity__c(WhatId__c  = HQOpportunity.Id, TransactionName__c = 'ZP82', Status__c = 'Completed', EndDate__c = Date.today());
        //Opportunity_Activity__c act19 = new Opportunity_Activity__c(WhatId__c  = HQOpportunity.Id, TransactionName__c = '2.5.1', Status__c = 'Completed', EndDate__c = Date.today());
        Opportunity_Activity__c act20 = new Opportunity_Activity__c(WhatId__c  = HQOpportunity.Id, TransactionName__c = 'ZPZ3', Status__c = 'Completed', EndDate__c = Date.today());
        insert new List<Opportunity_Activity__c>{act2, act3, act4, act5, act6, act7,act8, act9, act10, act11, act12, act13,act14, act15, act16, act17, act18,act20};
        
       Test.startTest();
       Set<ID> idSet = new Set<ID>();
       List<Opportunity> oppIDList = [Select id from Opportunity];
       for(Opportunity opp : oppIDList){
       idSet.add(opp.ID);
       }
        IF_OpportunityActivityInfoCallOut If180callout = new IF_OpportunityActivityInfoCallOut();
        IF_OpportunityActivityInfoCallOut.doCalloutSendingOpportunityActivityInfo(idSet);
        Test.stopTest();
      }

}