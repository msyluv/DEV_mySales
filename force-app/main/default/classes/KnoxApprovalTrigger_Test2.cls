/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2023-11-06
 * @last modified by  : divyam.gupta@samsung.com
 *  1.1   2023-11-06   divyam.gupta@samsung.com  Mysales-343 Put If-Logs inside knox approval of drop /lost functionality.

**/
@isTest(SeeAllData = true)
public class KnoxApprovalTrigger_Test2 {
    static Opportunity oppty;
    static Opportunity_Activity__c opptyAct_ZP82;
    static Opportunity_Activity__c opptyAct_ZPZ1;
    static Opportunity_Activity__c opptyAct_ZPZ2;
    static Opportunity_Activity__c opptyAct_ZPZ3;
    static Opportunity_Activity__c opptyAct_ZPG1;
    static KnoxApproval__c knoxApp1;
    static KnoxApproval__c knoxApp2;
    static KnoxApproval__c preKnoxApp;
    //START V 1.1 Divyam 
     static KnoxApproval__c knoxApp3;
     static User testuser;
    static Employee__c emp1;
    static Employee__c migEmp;
    // END V 1.1

    static {
        TriggerSwitch__c ts = [SELECT Id, Name, SetupOwnerId, SetupOwner.Name, All__c, Event__c, Opportunity__c, OpportunityActivity__c, OpportunityCodeSetting__c, 
                                      OpportunityBizLvSetting__c, OpportunityDeleteSetting__c, OpportunityLogisticsValidation__c, OpportunitySendToSAP__c, 
                                      RevenueScheduleOpportunity__c, CollaboApproval__c, Migration__c, WeeklyReportSend__c, FakeTest__c
                                 FROM TriggerSwitch__c 
                                WHERE SetupOwner.Name = 'SAMSUNG SDS'];
        ts.CollaboApproval__c = false;
        ts.FakeTest__c = true;
        update ts;
        //START V 1.1
           migEmp  = Utils_TestDataFactory.createEmployee('migEmp', 'migEmp');

        testuser = Utils_TestDataFactory.createUserFull(Utils_TestDataFactory.getProfile('System Administrator')
                                                        , migEmp.EvMailAddr__c
                                                        , migEmp.EvUniqID__c);
        
        // Mig User Switch insert (SetupOwnerId 에 특정 프로필 또는 User 셋팅하여 Test 제어)
        TriggerSwitch__c trSwitch_migUser = new TriggerSwitch__c(
            Opportunity__c = false,
            SetupOwnerId = testuser.Id
        );        
        insert trSwitch_migUser;
       // END V 1.1
        knoxApp2 = [SELECT Id, Name, Opportunity__c, Opportunity__r.StageName, Opportunity__r.Amount, OpportunityActivity__c, OpportunityActivity__r.TransactionName__c 
                      FROM KnoxApproval__c 
                     WHERE Opportunity__r.StageName = 'Z05' 
                       AND Opportunity__r.Amount = 0 
                       AND OpportunityActivity__r.TransactionName__c = 'ZP82' 
                     LIMIT 1];

        opptyAct_ZP82 = [SELECT Id, Name, WhatId__c, WhatId__r.Name, WhatId__r.CompanyCode__c, WhatId__r.OpportunityCode__c, WhatId__r.CollaborationBOId__c, TransactionName__c, Status__c 
                           FROM Opportunity_Activity__c 
                          WHERE OpportunityStage__c = 'Z05' 
                            AND TransactionName__c = :OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL
                          LIMIT 1];

                          /*
        opptyAct_ZPZ1 = [SELECT Id, Name, WhatId__c, WhatId__r.Name, WhatId__r.CompanyCode__c, WhatId__r.OpportunityCode__c, WhatId__r.CollaborationBOId__c, TransactionName__c, Status__c 
                           FROM Opportunity_Activity__c 
                          WHERE TransactionName__c = :OpportunityActivityHelper.ACT_CODE_LOST_OPPORTUNITY
                            AND LostType__c IN ('Z06', 'Z07')
                          LIMIT 1];
                          */

        opptyAct_ZPZ1 = [SELECT Id, Name, WhatId__c, WhatId__r.Name, WhatId__r.CompanyCode__c, WhatId__r.OpportunityCode__c, WhatId__r.CollaborationBOId__c, TransactionName__c, Status__c 
                           FROM Opportunity_Activity__c
                          WHERE Id = :knoxApp2.OpportunityActivity__c];

        opptyAct_ZPZ2 = [SELECT Id, Name, WhatId__c, WhatId__r.Name, WhatId__r.CompanyCode__c, WhatId__r.OpportunityCode__c, WhatId__r.CollaborationBOId__c, TransactionName__c, Status__c 
                           FROM Opportunity_Activity__c 
                          WHERE TransactionName__c = :OpportunityActivityHelper.ACT_CODE_DROP_OPPORTUNITY
                          LIMIT 1];
        opptyAct_ZPZ3 = [SELECT Id, Name, WhatId__c, WhatId__r.Name, WhatId__r.CompanyCode__c, WhatId__r.OpportunityCode__c, WhatId__r.CollaborationBOId__c, TransactionName__c, Status__c 
                           FROM Opportunity_Activity__c 
                          WHERE TransactionName__c = :OpportunityActivityHelper.ACT_CODE_AGENCY_CONTRACT_EXCEPTION
                          LIMIT 1];

        opptyAct_ZPG1 = [SELECT Id, Name, WhatId__c, WhatId__r.Name, WhatId__r.CompanyCode__c, WhatId__r.OpportunityCode__c, WhatId__r.CollaborationBOId__c, TransactionName__c, Status__c 
                           FROM Opportunity_Activity__c 
                          WHERE TransactionName__c = :OpportunityActivityHelper.ACT_CODE_CHANGE_APPROVAL_REQUEST
                          LIMIT 1];
                          

        oppty = [SELECT Id, Name 
                   FROM Opportunity 
                  WHERE Id = :opptyAct_ZP82.WhatId__c];

        preKnoxApp = new KnoxApproval__c(
            Opportunity__c = oppty.Id,
            OpportunityActivity__c = opptyAct_ZP82.Id,
            Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED,
            RequestBusinessLevel__c = 'S',
            MISID__c = 'SDSSFDC2021000000000000000000001'
        );
        insert preKnoxApp;
    }

    @isTest 
    static void test_method_1() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        knoxApp1 = new KnoxApproval__c(
            Opportunity__c = oppty.Id,
            OpportunityActivity__c = opptyAct_ZP82.Id,
            Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS,
            RequestBusinessLevel__c = 'S'
        );
        insert knoxApp1;

        knoxApp1.Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED;
        update knoxApp1;

        Test.stopTest();
    }

    @isTest 
    static void test_method_2() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        knoxApp1 = new KnoxApproval__c(
            Opportunity__c = oppty.Id,
            OpportunityActivity__c = opptyAct_ZPZ1.Id,
            Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS,
            RequestBusinessLevel__c = 'S',
            syncFlag__c = 'N'
        );
        insert knoxApp1;

        Test.stopTest();
    }
	/*
    @isTest 
    static void test_method_3() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        knoxApp1 = new KnoxApproval__c(
            Opportunity__c = oppty.Id,
            OpportunityActivity__c = opptyAct_ZPZ2.Id,
            Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS,
            RequestBusinessLevel__c = 'S'
        );
        insert knoxApp1;

        knoxApp1.Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED;
        update knoxApp1;

        Test.stopTest();
    }
	*/

    @isTest 
    static void test_method_4() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        knoxApp1 = new KnoxApproval__c(
            Opportunity__c = oppty.Id,
            OpportunityActivity__c = opptyAct_ZPZ3.Id,
            Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS,
            RequestBusinessLevel__c = 'S'
        );
        insert knoxApp1;

        //knoxApp1.Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED;
        //update knoxApp1;

        Test.stopTest();
    }

    @isTest 
    static void test_method_5() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        knoxApp1 = new KnoxApproval__c(
            Opportunity__c = oppty.Id,
            OpportunityActivity__c = opptyAct_ZPG1.Id,
            Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS,
            RequestBusinessLevel__c = 'S'
        );
        insert knoxApp1;

        Test.stopTest();
    }
   // START V 1.1 Divyam    
     @isTest 
     static void test_method_6() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
         system.runAs(testuser){
             opptyAct_ZPZ2.LostType__c = 'Z07';
             update opptyAct_ZPZ2;
        knoxApp3 = new KnoxApproval__c(
            Opportunity__c = oppty.Id,
            OpportunityActivity__c = opptyAct_ZPZ2.Id,
            Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS,
            RequestBusinessLevel__c = 'S',
            syncFlag__c = 'N'
        );
        insert knoxApp3;
        knoxApp3.Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_AFTER_CONFIRMED;
         knoxApp3.syncFlag__c = 'S';
      
        update knoxApp3;
         }

        Test.stopTest();
    }
    // END V 1.1 
 
    
}