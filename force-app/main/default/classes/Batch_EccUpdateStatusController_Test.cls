/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 03-04-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   02-16-2021   soohong0.kim@partner.samsung.com   Initial Version
**/
@isTest
public class Batch_EccUpdateStatusController_Test {
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
        opptyAct.TransactionName__c = 'ZP32';
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

        KnoxApproval__c approval = new KnoxApproval__c();
        approval.Status__c = '1';
        approval.MISID__c = 'SDSSFDC2020111617314416055155045';
        approval.Opportunity__c = oppty.id;
        approval.WFOBJECT__c = 'test';
        approval.syncFlag__c = 'N';
        approval.OpportunityActivity__c = opptyAct.id;
        insert approval;

    }
    private static testMethod void test01() {
        Test.startTest();

        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());
        Database.executeBatch(new Batch_EccUpdateStatusController());
        Test.stopTest();
    }

    private static testMethod void test02() {
        Test.startTest();

        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());
        
        Set<Id> opptyIds = new Set<Id>();
        List<KnoxApproval__c> objList = [SELECT Id, WFOBJECT__c, MISID__c, Opportunity__c, Opportunity__r.OpportunityCode__c, OpportunityActivity__r.TransactionName__c, Opportunity__r.CompanyCode__c, Status__c, syncFlag__c FROM KnoxApproval__c WHERE syncFlag__c = 'N' limit 1];
        Batch_EccUpdateStatusController.IF135_Callout(objList[0].id, true);
        /*
        for(KnoxApproval__c obj : objList){
            opptyIds.add(obj.Opportunity__c);
        }
        List<Project__c> prjList = [SELECT Id, Opportunity__c, Opportunity__r.OpportunityCode__c, ProjectType__c, ProjectCode__c, Description__c, DeletionFlag__c FROM Project__c WHERE Opportunity__c in: opptyIds];
        for(KnoxApproval__c obj : objList){
            Batch_EccUpdateStatusController.InputClass input = new Batch_EccUpdateStatusController.InputClass();

            input.IV_WFOBJECT       = obj.WFOBJECT__c;                                   // 결재유형코드
            input.IV_OBJECTKEY      = obj.MISID__c;                                      // 트랙젠션 ID
            input.IV_ZZORDER_ID     = obj.Opportunity__r.OpportunityCode__c;             // BO 코드
            input.IV_PROCESS_TYPE   = obj.OpportunityActivity__r.TransactionName__c;     // 액티비티 ID
            input.IV_BUKS           = obj.Opportunity__r.CompanyCode__c;                 // 회사코드
            input.IV_STATUS         = 'A3';                                                           // 결재상태
            List<Batch_EccUpdateStatusController.IT_PROJECT> itPrjList = new List<Batch_EccUpdateStatusController.IT_PROJECT>();
            for(Project__c prj : prjList){
                if(obj.Opportunity__c == prj.Opportunity__c){
                    Batch_EccUpdateStatusController.IT_PROJECT itPrj = new Batch_EccUpdateStatusController.IT_PROJECT();
                    itPrj.OPPORTUNITY = prj.Opportunity__r.OpportunityCode__c;
                    itPrj.PROJECTTYPE = prj.ProjectType__c;
                    itPrj.PROJECTCODE = prj.ProjectCode__c;
                    itPrj.DESCRIPTION = prj.Description__c;
                    itPrj.DELETIONFLAG = prj.DeletionFlag__c == true ? 'X':'';
                    itPrjList.add(itPrj);
                }
            }
            input.IT_PROJECT = itPrjList;
            Batch_EccUpdateStatusController.syncApproval(JSON.serialize(input));          
        }
*/


        Test.stopTest();
    }
    private static testMethod void test03() {
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());

        Set<Id> opptyIds = new Set<Id>();
        List<KnoxApproval__c> objList = [SELECT Id, WFOBJECT__c, MISID__c, Opportunity__c, Opportunity__r.OpportunityCode__c, OpportunityActivity__r.TransactionName__c, Opportunity__r.CompanyCode__c, Status__c, syncFlag__c FROM KnoxApproval__c WHERE syncFlag__c = 'N' limit 1];
        Batch_EccUpdateStatusController.IF135_Callout(objList[0].id, false);
        Test.stopTest();
    }
}