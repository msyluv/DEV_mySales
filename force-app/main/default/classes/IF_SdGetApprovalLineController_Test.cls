/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2022-02-08
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   01-07-2021   soohong0.kim@partner.samsung.com   Initial Version
**/
@isTest
public class IF_SdGetApprovalLineController_Test {
    static Account acc;
    static Opportunity oppty;
    static Opportunity coOpp;
    static Profile p;
    static User user;
    static Opportunity_Activity__c opptyAct = new Opportunity_Activity__c();
    static approvaltype__c appType = new approvaltype__c();
    static ApprovalFactor__c factor = new ApprovalFactor__c();
    private static String transactionName;
    
    @TestSetup
    static void setData(){

        Map<String,String> pickMap = new Map<String,String>();
        acc = Utils_TestDataFactory.createAccount('TestAcc');
        acc.AccountNumber = 'A2222233';
        acc.MDGCheck__c = true;
        update acc;
        
        pickMap = Utils.getPicklistOptionType('Opportunity','BusinessLevel__c')[0];
        oppty = Utils_TestDataFactory.createOpportunity('TestOppty', acc.id);
        oppty.cOriginAcc__c = acc.id;
        oppty.Amount = 1234124;
        oppty.BusinessLevel__c = pickMap.get('value');

        coOpp = Utils_TestDataFactory.createOpportunity('TestCoOppty', acc.id);
        coOpp.cOriginAcc__c = acc.id;
        coOpp.Amount = 1234124;
        coOpp.BusinessLevel__c = pickMap.get('value');
        update coOpp;
        
        oppty.CollaborationBOId__c = coOpp.id;
        update oppty;

        appType.IsActive__c = true;
        appType.Name = 'test';
        appType.Type__c = 'ZCRM000020';
        insert appType;

        factor.Factor__c = 'test';
        factor.Name = 'test';
        factor.MultiCode__c = true;
        factor.isActive__c = true;
        factor.ApprovalType__c = appType.id;
        insert factor;


        pickMap = Utils.getPicklistOptionType('Opportunity_Activity__c','TransactionName__c')[0];
        opptyAct.WhatId__c = oppty.id;
        opptyAct.TransactionName__c = pickMap.get('value');
        opptyAct.ExtId__c = oppty.id + '_'+pickMap.get('value');
        opptyAct.StartDate__c = Date.today();
        opptyAct.EndDate__c = Date.today();
        opptyAct.DueDate__c = Date.today();
        insert opptyAct;
        transactionName = pickMap.get('value');
        
        Master_Service__c mSrv = new Master_Service__c();
        mSrv.Code__c = 'testcode';
        mSrv.Use__c = true;
        insert mSrv;

        Company__c company = new Company__c();
        company.Name = 'test';
        insert company;

        CostCenter__c cCenter = new CostCenter__c();
        cCenter.CostCenter__c = 'test12';
        cCenter.Company__c = company.id;
        insert cCenter;

        Service__c srv = new Service__c();
        srv.Opportunity__c = oppty.id;
        srv.ItemNumber__c = 123;
        srv.service__c = mSrv.id;
        srv.SalesDepartment__c = cCenter.id;
        srv.SendSAP__c = true;
        srv.DeletionFlag__c = false;
        insert srv;

        pickMap = Utils.getPicklistOptionType('Master_Solution__c','PLCStatus__c')[0];
        Master_Solution__c mSol = new Master_Solution__c();
        mSol.PLCStatus__c = pickMap.get('value');
        mSol.Use__c = true;
        mSol.Code__c = 'test';
        insert mSol;

        Solution__c sol = new Solution__c();
        sol.Service__c = srv.id;
        sol.Solution__c = mSol.id;
        sol.OwnerDept__c = cCenter.id;
        sol.Opportunity__c = oppty.id;
        sol.Amount__c = 123;
        insert sol;

        BizAttribute__c biz = new BizAttribute__c();
        biz.Name = 'test biz';
        biz.Code__c = 'test code';
        biz.Active__c = true;
        insert biz;


        pickMap = Utils.getPicklistOptionType('SvcSolBizAttr__c','WBSClass__c')[0];
        SvcSolBizAttr__c svcBiz = new SvcSolBizAttr__c();
        svcBiz.Solution__c = mSol.id;
        svcBiz.BizAttribute__c = biz.id;
        svcBiz.WBSClass__c = pickMap.get('value');
        pickMap = Utils.getPicklistOptionType('SvcSolBizAttr__c','BusinessType__c')[0];
        svcBiz.BusinessType__c = pickMap.get('value');
        insert svcBiz;
        
        WBS__c wbs = new WBS__c();
        wbs.OpportunityID__c = oppty.id;
        insert wbs;
        
        Project__c prj = new Project__c();
        prj.Opportunity__c = oppty.id;
        insert prj;

        Service__c coSrv = new Service__c();
        coSrv.Opportunity__c = coOpp.id;
        coSrv.ItemNumber__c = 123;
        coSrv.service__c = mSrv.id;
        coSrv.SalesDepartment__c = cCenter.id;
        coSrv.SendSAP__c = true;
        coSrv.DeletionFlag__c = false;
        insert coSrv;

    }
    private static testMethod void IF_SdGetApprovalLineControllerTest() {
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());
        Map<String,String> pickMap = Utils.getPicklistOptionType('Opportunity_Activity__c','TransactionName__c')[0];
        Opportunity_Activity__c opptyAct = [select id, WhatId__c from Opportunity_Activity__c where TransactionName__c =:pickMap.get('value') limit 1];
        IF_SdGetApprovalLineController.Param param = new IF_SdGetApprovalLineController.Param();
        param.corporationId = 'T100';
        param.opptyId = opptyAct.WhatId__c;
        param.actId = opptyAct.id;
        param.factorType = 'ZCRM000020';
        param.userEmpNo = 'AC100000';
        param.factor = 'X';
        param.pathlist = 'X';
        param.html = 'X';
        param.apInfId = '';
        
        Map<String, Object> returnMap = IF_SdGetApprovalLineController.getApprovalLine(param);
        Integer statusCode   = Util_String.nvlInt( returnMap.get( 'StatusCode'));
        System.assertEquals( statusCode, 200);
        Test.stopTest();
    }
}