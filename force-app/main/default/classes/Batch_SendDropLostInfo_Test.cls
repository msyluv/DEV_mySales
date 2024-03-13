/**
 * @description       : 
 * @author            : hyunhak.roh@dkbmc.com
 * @group             : 
 * @last modified on  : 
 * @last modified by  : 
 * Modifications Log 
 * Ver   Date         Author                    	Modification
 * 1.0   2022-04-05   hyunhak.roh@dkbmc.com   		Initial Version
**/
@isTest
public class Batch_SendDropLostInfo_Test {

    static Account acc;
	static Opportunity opp,opp_collabo;
    static TempKnoxApproval__c app;

    static CostCenter__c costCenter;
    static Company__c company;
    
    static MasterActivity__c ma_1;

    static Map<String, Object> ApprovalData;
    static List<Map<String, Object>> fileList;
    static String opptyActId;
    
    static{
        System.debug('##### Batch_SendDropLostInfo_Test, static ##### ');
        
        ma_1 = new MasterActivity__c(
            ObjectApiName__c = 'Opportunity',
            Stage__c = 'Z01',
            Order__c = 1,
            Type__c = 'HQ',
            TransactionName__c = 'ZPZ1',
            RequiredTransaction__c = 'XP11'
        );
        insert ma_1;
        
        company = new Company__c(
            CompanyCode__c = 'T100'
        );
        insert company;
        
        costCenter = new CostCenter__c(
            Name                = '기술전략팀(T100-11331)'
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T100'
            , CostCenterName__c = '기술전략팀'
            , CostCenter__c     = 'T100-11331'
            , Node1__c          = 'T100'
            , Node2__c          = 'T100SB'
            , Node3__c          = 'T100SB1'
            , Node4__c          = 'T100SB13'
            , Node5__c          = 'T100SB131'  
            , Company__c 		= company.Id
        );
        insert costCenter;
        
        // [Account]
        acc = Utils_TestDataFactory.createAccount('TestAccount');
        acc.MDGCheck__c = true;
        update acc;

        // [Opportunity]
		opp = Utils_TestDataFactory.createOpportunity('TestOpportunity', acc.Id);
        //opp.ownerId = user1.id;

        opp_collabo = Utils_TestDataFactory.createOpportunity('TestOpportunity Collabo', acc.Id);
        opp.CollaborationBOId__c = opp_collabo.Id;
        opp.CollaborationInOut__c = 'Out';
        //
        opp.SalesDepartment__c = costCenter.Id;
        opp.cPrimarySalesDepartment__c = costCenter.Id;
        opp.CurrencyIsoCode = 'USD';
        update opp;
        
        System.debug('### Batch_SendDropLostInfo_Test :: opp = ' + opp);
        
        Opportunity_Activity__c opptyAct = new Opportunity_Activity__c( 
            Status__c            = OpportunityActivityNewController.OPPTYACT_STATUS_COMPLETED	//'Completed'
            , DueDate__c         = System.today()
            , TransactionName__c = OpportunityActivityHelper.ACT_CODE_LOST_OPPORTUNITY		//'ZPZ1'
            , WhatId__c          = opp.Id 
            , LostType__c 		 = 'Z06'
            , LostReason__c		 = 'A1Z0000005A020'
            , Description__c	 = 'Description Test~~!!'
            , EndDate__c 		 = System.today()
        );
        opptyAct.ExtId__c = OpportunityActivityHelper.generateOpportunityActivityExtKey(opptyAct);
        insert  opptyAct;
        
        System.debug('### Batch_SendDropLostInfo_Test :: opptyAct = ' + opptyAct);
    }

    @isTest
    static void testMethod1() {
        
        System.debug('##### Batch_SendDropLostInfo_Test, testMethod1 Start ~~!! ##### ');       
        
        List<Opportunity_Activity__c> listOppAct = [SELECT ID, TransactionName__c, Status__c, WhatId__c, WhatId__r.CompanyCode__c FROM Opportunity_Activity__c WHERE TransactionName__c IN ('ZPZ1','ZPZ2') AND Status__c = 'Completed' AND WhatId__r.CompanyCode__c = 'T100' ];
        System.debug('### Batch_SendDropLostInfo_Test :: testMethod1 :: listOppAct = ' + listOppAct);

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());

        Set<Id> setDropLostBoActId = new Set<Id>();
        
        //        
        for(Opportunity_Activity__c oppyActy : listOppAct) {
            //
            setDropLostBoActId.add(oppyActy.Id);
            
            System.debug('##### Batch_SendDropLostInfo_Test, setDropLostBoActId add, ID : ' + oppyActy.Id);
        }
		        
        //
        System.debug('##### Batch_SendDropLostInfo_Test, setDropLostBoActId size : ' + setDropLostBoActId.size());
        
        Database.executeBatch(new Batch_SendDropLostInfo(setDropLostBoActId), 50);
        
        Test.stopTest();
        
        System.debug('##### Batch_SendDropLostInfo_Test, testMethod1 End ~~!! ##### ');
    }

}