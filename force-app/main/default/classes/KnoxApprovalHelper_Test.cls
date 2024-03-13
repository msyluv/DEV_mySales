/**
 * @description       : 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2022-02-23
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2021-05-05   hj.lee@dkbmc.com   Initial Version
**/
@isTest
public class KnoxApprovalHelper_Test {
    static Account acc;
    static Opportunity oppty;
    static Opportunity coOpp;
    static Profile p;
    static User user;
    static Opportunity_Activity__c opptyAct = new Opportunity_Activity__c();
    static Opportunity_Activity__c coOpptyAct = new Opportunity_Activity__c();
    static approvaltype__c appType = new approvaltype__c();
    static ApprovalFactor__c factor = new ApprovalFactor__c();
    private static String transactionName;

    @TestSetup
    static void makeData(){
        Map<String,String> pickMap = new Map<String,String>();
        acc = Utils_TestDataFactory.createAccount('TestAcc');
        acc.AccountNumber = 'A2222233';
        acc.MDGCheck__c = true;
        update acc;

        Company__c company = new Company__c();
        company.Name = 'test';
        insert company;

        CostCenter__c cCenter = new CostCenter__c();
        cCenter.CostCenter__c = 'T100-11975';
        cCenter.Company__c = company.id;
        insert cCenter;
        
        pickMap = Utils.getPicklistOptionType('Opportunity','BusinessLevel__c')[0];
        oppty = Utils_TestDataFactory.createOpportunity('TestOppty', acc.id);
        oppty.cOriginAcc__c = acc.id;
        oppty.Amount = 1234124;
        oppty.BusinessLevel__c = pickMap.get('value');
        oppty.AccountId = acc.id;
        
        coOpp = Utils_TestDataFactory.createOpportunity('TestCoOppty', acc.id);
        coOpp.cOriginAcc__c = acc.id;
        coOpp.Amount = 1234124;
        coOpp.BusinessLevel__c = pickMap.get('value');
        coOpp.AccountId = acc.id;
        coOpp.SalesDepartment__c = cCenter.Id;
        update coOpp;
        
        oppty.CollaborationBOId__c = coOpp.id;
        update oppty;

        pickMap = Utils.getPicklistOptionType('Opportunity_Activity__c','TransactionName__c')[0];
        opptyAct.WhatId__c = oppty.id;
        opptyAct.TransactionName__c = 'ZP82';
        opptyAct.ExtId__c = oppty.id + '_'+pickMap.get('value');
        opptyAct.StartDate__c = Date.today();
        opptyAct.EndDate__c = Date.today();
        opptyAct.DueDate__c = Date.today();
        insert opptyAct;

        coOpptyAct.WhatId__c = coOpp.id;
        coOpptyAct.TransactionName__c = 'ZP82';
        coOpptyAct.ExtId__c = coOpp.id + '_'+pickMap.get('value');
        coOpptyAct.StartDate__c = Date.today();
        coOpptyAct.EndDate__c = Date.today();
        coOpptyAct.DueDate__c = Date.today();
        insert coOpptyAct;

        transactionName = pickMap.get('value');
        
        appType.IsActive__c = true;
        appType.Name = 'test';
        appType.Type__c = 'ZCRM000020';
        appType.TransactionName__c = 'ZP82';
        insert appType;

        factor.Factor__c = 'test';
        factor.Name = 'test';
        factor.MultiCode__c = true;
        factor.isActive__c = true;
        factor.ApprovalType__c = appType.id;
        insert factor;

        Master_Service__c mSrv = new Master_Service__c();
        mSrv.Code__c = 'testcode';
        mSrv.Use__c = true;
        insert mSrv;

        Service__c srv = new Service__c();
        srv.Opportunity__c = oppty.id;
        srv.ItemNumber__c = 123;
        srv.service__c = mSrv.id;
        srv.SalesDepartment__c = cCenter.id;
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
        insert coSrv;

        KnoxApproval__c approval1 = new KnoxApproval__c();
        approval1.Status__c = '2';
        approval1.MISID__c = 'SDSSFDC2020121710344116081688819';
        approval1.Opportunity__c = oppty.id;
        approval1.OpportunityActivity__c = opptyAct.id;
        insert approval1;

        KnoxApproval__c approval3 = new KnoxApproval__c();
        approval3.Name = 'approval3';
        approval3.Status__c = '1';
        approval3.MISID__c = 'SDSSFDC2020121710344116081688821';
        approval3.syncFlag__c = 'Y';
        approval3.Opportunity__c = oppty.Id;
        approval3.OpportunityActivity__c = opptyAct.Id;
        insert approval3;

        KnoxApproval__c approval4 = new KnoxApproval__c();
        approval4.Name = 'approval4';
        approval4.Status__c = '1';
        approval4.MISID__c = 'SDSSFDC2020121710344116081688821';
        approval4.syncFlag__c = 'Y';
        approval4.Opportunity__c = coOpp.Id;
        approval4.OpportunityActivity__c = coOpptyAct.Id;
        approval4.OriginKnoxApproval__c = approval3.Id;
        insert approval4;
    }

    // @TestSetup
    // static void setData(){
    // 
    //     Opportunity oppty = new Opportunity(
	// 		Name = 'Test Opportunity', 
    //         StageName = 'Z01',
    //         Type = 'New Business',
    //         LeadSource = 'Other',
	// 		CloseDate = System.today()
	// 	);
    //     insert oppty;
    // 
    //     // *******************************************
    //     // OppoActivity 
    //     // **************************************************************
    // 
    //     // Request Resource
    //     Opportunity_Activity__c opptyAct_requestResource = new Opportunity_Activity__c(
    //         Status__c = 'Not Started',
    //         WhatId__c = oppty.id,
    //         TransactionName__c = OpportunityActivityHelper.ACT_CODE_REQUEST_RESOURCES
    //     );
    //     insert opptyAct_requestResource;
    // 
    // 
    //     Project__c project = new Project__c(
    //         Opportunity__c =  oppty.Id,
    //         Name = 'Test2',
    //         Description__c = 'Test2',
    //         ProjectCode__c = 'testProject002'
    //     );
    //     insert project;
    // 
    //     KnoxApproval__c approval = new KnoxApproval__c();
    //     approval.Status__c = '1';
    //     approval.MISID__c = 'SDSSFDC2020121710344116081688819';
    //     approval.syncFlag__c = 'N';
    //     approval.Opportunity__c = oppty.Id;
    //     approval.OpportunityActivity__c = opptyAct_requestResource.Id;
    //     insert approval;
    //     
    //     /**
    //      * Knox Approver
    //      */
    //     Employee__c emp1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'EPID1');
    //     KnoxApprover__c knoxApprover1 = new KnoxApprover__c(
    //         KnoxApproval__c = approval.Id,
    //         Index__c = 0,
    //         Name = 'test1',
    //         ApproverType__c = '0',
    //         EvSdeptNM__c = '개발',
    //         EvMailAddr__c = emp1.EvMailAddr__c,
    //         Employee__c = emp1.Id,
    //         EvUniqID__c = emp1.EvUniqID__c,
    //         IsChangeLine__c = true,
    //         IsEditText__c = true,
    //         IsArbitraryDecision__c = true
    //     );
    //     insert knoxApprover1;
    //     
    //     
    //     KnoxApproval__c approval2 = new KnoxApproval__c(
    //         Name = 'approval2',
    //     	Status__c = '1',
    //     	MISID__c = 'SDSSFDC2020121710344116081688820',
    //     	syncFlag__c = 'Y',
    //     	Opportunity__c = oppty.Id,
    //     	OpportunityActivity__c = opptyAct_requestResource.Id
    //     );
    //     insert approval2;
    // 
    //     KnoxApproval__c approval_copy = approval.clone(false, true, false);
    //     approval_copy.id = null;
    //     approval_copy.OriginKnoxApproval__c = approval.Id;
    //     insert approval_copy;
    // 
    //     KnoxApproval__c approval_copy2 = approval2.clone(false, true, false);
    //     approval_copy2.id = null;
    //     approval_copy2.syncFlag__c = 'Y';
    //     approval_copy2.OriginKnoxApproval__c = approval2.Id;
    //     insert approval_copy2;
    // 
    //     KnoxApproval__c approval3 = new KnoxApproval__c(
    //         Name = 'approval3',
    //     	Status__c = '1',
    //     	MISID__c = 'SDSSFDC2020121710344116081688821',
    //     	syncFlag__c = 'Y',
    //     	Opportunity__c = oppty.Id,
    //     	OpportunityActivity__c = opptyAct_requestResource.Id
    //     );
    //     insert approval3;
    // }

    private static testMethod void KnoxApprovalCancel_Test1() {
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());
        KnoxApproval__c obj = [SELECT Id
                                      , ApprovedId__c
                                      , OwnerId
                                      , MISID__c
                                      , Status__c
                                      , WFOBJECT__c
                                      , Opportunity__c
                                      , Opportunity__r.OpportunityCode__c
                                      , Opportunity__r.CompanyCode__c
                                      , OpportunityActivity__c
                                      , OpportunityActivity__r.WhatId__c
                                      , OpportunityActivity__r.TransactionName__c
                                      , syncFlag__c
                            FROM KnoxApproval__c
                            WHERE syncFlag__c = 'N' 
                            limit 1];  
        
        KnoxApprovalHelper.isTarget_if135(obj, 1);
    
        KnoxApprovalHelper.callOut_if135(obj, [SELECT Id, Opportunity__c, Opportunity__r.OpportunityCode__c, ProjectType__c, ProjectCode__c, Description__c, DeletionFlag__c 
                                                FROM Project__c]);

        Test.stopTest();
    }
    
    private static testMethod void KnoxApprovalCancel_Test2() {
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());
        
        KnoxApproval__c obj = [SELECT Id
                                    , ApprovedId__c
                                    , OwnerId
                                    , MISID__c
                                    , Status__c
                                    , WFOBJECT__c
                                    , Opportunity__c
                                    , Opportunity__r.OpportunityCode__c
                                    , Opportunity__r.CompanyCode__c
                                    , OpportunityActivity__c
                                    , OpportunityActivity__r.WhatId__c
                                    , OpportunityActivity__r.TransactionName__c
                                    , syncFlag__c
                                FROM KnoxApproval__c 
                                WHERE syncFlag__c = 'Y' limit 1];
        Map<String,Object> paramMap = new Map<String,Object>();
        paramMap.put('KnoxApproval', obj);
        paramMap.put('Comments','test');
        KnoxApprovalHelper.isTarget_if093(obj, KnoxApprovalHelper.KNOX_APPROVAL_STATUS_CANCEL);
        // KnoxApprovalHelper.process_if093(obj.Id, KnoxApprovalHelper.KNOX_APPROVAL_STATUS_CANCEL);

        List<KnoxApproval__c> approvalList = new List<KnoxApproval__c>{obj};
        KnoxApprovalHelper.updateCollaboApproval(JSON.serialize(approvalList));

        
        Test.stopTest();
    }

    
    private static testMethod void test_process_if093() {
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());
        
        KnoxApproval__c obj = [SELECT Id
                                    , ApprovedId__c
                                    , OwnerId
                                    , MISID__c
                                    , Status__c
                                    , WFOBJECT__c
                                    , Opportunity__c
                                    , Opportunity__r.OpportunityCode__c
                                    , Opportunity__r.CompanyCode__c
                                    , OpportunityActivity__c
                                    , OpportunityActivity__r.WhatId__c
                                    , OpportunityActivity__r.TransactionName__c
                                    , syncFlag__c
                                    FROM KnoxApproval__c 
                                    WHERE Name = 'approval3' limit 1];
        Map<String,Object> paramMap = new Map<String,Object>();
        paramMap.put('KnoxApproval', obj);
        paramMap.put('Comments','test');
        
        // KnoxApprovalHelper.process_if093(obj.Id, obj.Status__c );
        
        Test.stopTest();
    }

    private static testMethod void test_queue_process_if093() {
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());

        KnoxApproval__c obj = [SELECT Id
                                    , ApprovedId__c
                                    , OwnerId
                                    , MISID__c
                                    , Status__c
                                    , WFOBJECT__c
                                    , Opportunity__c
                                    , Opportunity__r.OpportunityCode__c
                                    , Opportunity__r.CompanyCode__c
                                    , OpportunityActivity__c
                                    , OpportunityActivity__r.WhatId__c
                                    , OpportunityActivity__r.TransactionName__c
                                    , syncFlag__c
                            FROM KnoxApproval__c 
                            WHERE Name = 'approval3' 
                            limit 1];
        System.enqueueJob(new KnoxApprovalHelper.Queue_Process_if093(obj.Id, KnoxApprovalHelper.KNOX_APPROVAL_STATUS_CANCEL));
        Test.stopTest();
    }

}