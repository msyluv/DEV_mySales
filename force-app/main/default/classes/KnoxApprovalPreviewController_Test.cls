/**
 * @description       : 
 * @author            : dongyoung.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2023-06-15
 * @last modified by  : anish.jain@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-01-25   dongyoung.kim@dkbmc.com   Initial Version
 * 1.1   2022-10-17   anish.jain@partner.samsung.com   Change on 'Knox Preview' Tab according to 'Analysis of Competition'
 * 1.2   2023-06-06   anish.jain@partner.samsung.com   Add department validation logic for contract approval activity -> My Sales - 215
 * 1.3   2023-06-15   anish.jain@partner.samsung.com   Knox Approval Preview/Approval/History tab development -> My Sales - 228
**/
@isTest
public class KnoxApprovalPreviewController_Test {
    static Account acc;
    static Opportunity opty;
    static Opportunity_Activity__c  optyacty;
    static TempKnoxApproval__c Temp;
    static Profile pf = [select Id from Profile where Name = 'System Administrator' limit 1];
    static Profile pf1 = [select Id from Profile where Name = 'Sales Rep.(HQ)' limit 1];
    static User user;
    static User user1;
    static Biz_Review__c bizReview;
    static List<Opportunity_Activity__c> opptyActList;
    
    static{
        acc = new Account(
            Name = 'a_name',
            MDGCheck__c = true
        );
        insert acc;
        
        CostCenter__c costCenter = new CostCenter__c(
            Name                = '기술전략팀(T604-11331)'
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T604'
            , CostCenterName__c = '기술전략팀'
            , CostCenter__c     = 'T604-11331'
            , Node1__c          = 'T604'
            , Node2__c          = 'T604SB'
            , Node3__c          = 'T604SB1'
            , Node4__c          = 'T604SB13'
            , Node5__c          = 'T604SB131'            
        );
        insert costCenter;
        
        opty = new Opportunity(
            Name = 'a_name',
            AccountId = acc.Id,
            OpportunityCode__c = 'oppCode',
            ActivityStatus__c = 'XP11',
            StageName = 'Qualification',
            CloseDate = Utils.getCurDatetime().date().addDays(1),
            cPrimarySalesDepartment__c = costCenter.Id,
            SalesDepartment__c = costCenter.Id
        );
        insert opty;
         
        optyacty= new Opportunity_Activity__c(
            TransactionName__c = 'XPX1',
            WhatId__c = opty.id,
            ExtID__c = opty.id+opty.ActivityStatus__c
        );
        insert optyacty;
        LostResult__c lostResult = new LostResult__c();
        lostResult.Opportunity__c = opty.Id;
        lostResult.LostActivity__c = optyacty.Id;
        lostResult.IsCheck__c = true;
        lostResult.LostTypeCode__c = 'XPX1';
        insert lostResult;
        
        Temp = new TempKnoxApproval__c();
        insert Temp;
        user = new User(
            Alias = 'testUser',
            Email='SysAdminTestuser@dkbmc.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            EmployeeNumber='AC100000',
            TimeZoneSidKey='Asia/Seoul',
            UserName='SysAdminTestuser@samsung.com',
            ProfileId = pf.Id
        );
        insert user;
        
        user1 = new User(
            Alias = 'testUse',
            Email='SysAdminTestuser1@dkbmc.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing1',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            EmployeeNumber='AC100001',
            TimeZoneSidKey='Asia/Seoul',
            UserName='SysAdminTestuser1@samsung.com',
            ProfileId = pf1.Id
        );
        insert user1;
        bizReview = new Biz_Review__c(Description__c = 'test', Version__c = 1, Opportunity__c = opty.Id);
        insert bizReview;
        
        
    }
    
    @isTest
    static void getchange() {
        Boolean useApprovalLineBody = true;
        System.runAs(user){
            KnoxAPprovalPreviewController.getApprovalBodyHtml(bizReview.Id, opty.Id, optyacty.Id, useApprovalLineBody, Utils.makeMisId(Utils.getCurDatetime()));
            optyacty.TransactionName__c = 'ZPZ3';
            update optyacty;
            KnoxAPprovalPreviewController.getApprovalBodyHtml(bizReview.Id, opty.Id, optyacty.Id, useApprovalLineBody, Utils.makeMisId(Utils.getCurDatetime()));
            
            KnoxAPprovalPreviewController.getConfirmMSG(opty.Id, optyacty.Id);
          //  KnoxAPprovalPreviewController.getLostResultRecord(opty.Id); //Added by Anish - v 1.1
        }
    }
    @isTest
    static void getchange1() {
        Boolean useApprovalLineBody = true;
        System.runAs(user){
            KnoxAPprovalPreviewController.getApprovalBodyHtml(bizReview.Id, opty.Id, optyacty.Id, useApprovalLineBody, Utils.makeMisId(Utils.getCurDatetime()));
            optyacty.TransactionName__c = 'ZPZ1';
            update optyacty;
            KnoxAPprovalPreviewController.getApprovalBodyHtml(bizReview.Id, opty.Id, optyacty.Id, useApprovalLineBody, Utils.makeMisId(Utils.getCurDatetime()));
            
            KnoxAPprovalPreviewController.getConfirmMSG(opty.Id, optyacty.Id);
          //  KnoxAPprovalPreviewController.getLostResultRecord(opty.Id); //Added by Anish - v 1.1
        }
    }
    @isTest
    static void getchange2() {
        Boolean useApprovalLineBody = true;
        System.runAs(user){
            KnoxAPprovalPreviewController.getApprovalBodyHtml(bizReview.Id, opty.Id, optyacty.Id, useApprovalLineBody, Utils.makeMisId(Utils.getCurDatetime()));
            optyacty.TransactionName__c = 'ZP62';
            update optyacty;
            KnoxAPprovalPreviewController.getApprovalBodyHtml(bizReview.Id, opty.Id, optyacty.Id, useApprovalLineBody, Utils.makeMisId(Utils.getCurDatetime()));
            
            KnoxAPprovalPreviewController.getConfirmMSG(opty.Id, optyacty.Id);
          //  KnoxAPprovalPreviewController.getLostResultRecord(opty.Id); //Added by Anish - v 1.1
        }
    }
    //Added by Anish - v 1.2
    @isTest
        static void getchange21() {
        Boolean useApprovalLineBody = true;
        System.runAs(user){
            KnoxAPprovalPreviewController.getApprovalBodyHtml(bizReview.Id, opty.Id, optyacty.Id, useApprovalLineBody, Utils.makeMisId(Utils.getCurDatetime()));
            optyacty.TransactionName__c = 'ZP82';
            update optyacty;
            KnoxAPprovalPreviewController.getApprovalBodyHtml(bizReview.Id, opty.Id, optyacty.Id, useApprovalLineBody, Utils.makeMisId(Utils.getCurDatetime()));
            
            KnoxAPprovalPreviewController.getConfirmMSG(opty.Id, optyacty.Id);
        }
    }
}