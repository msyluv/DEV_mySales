/**
 * @description       : 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2023-06-06
 * @last modified by  : anish.jain@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2021-01-19   hj.lee@dkbmc.com       Initial Version
 * 1.1   2023-03-28   gitesh.s@samsung.com   Changed EvEmpNO__c to EvSapEmpNO__c
 * 1.2   2023-06-06   anish.jain@partner.samsung.com Add department validation logic for contract approval activity -> My Sales - 215
**/
@isTest
public class ApprovalLineController_Test {

    static Account acc;
    static Opportunity zp32_oppty_1;
    static Opportunity_Activity__c zp32_opptyAct_1;
    static Employee__c emp1;
    static User user1;

    
    static Opportunity oppty;
    static Opportunity coOpp;
    static Profile p;
    static User user;
    static Opportunity_Activity__c opptyAct = new Opportunity_Activity__c();
    static Opportunity_Activity__c opptyAct1 = new Opportunity_Activity__c(); //Added by Anish - v 1.2
    static Opportunity_Activity__c opptyAct2 = new Opportunity_Activity__c(); //Added by Anish - v 1.2
    static ApprovalType__c appType = new ApprovalType__c();
    static ApprovalFactor__c factor = new ApprovalFactor__c();
   
    static {
        // [Trigger Switch Setting ] Default Org Switch Setup
        // TriggerSwitch__c trSwitch_default = new TriggerSwitch__c(
        //     All__c = true,
        //     Opportunity__c = true,
        //     OpportunityActivity__c = true
        // );
        // insert trSwitch_default;

        emp1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'EPID1');
        // v1.1 - Gitesh Saini
        emp1.EvSapEmpNO__c     = '16241';
        // v1.1
        emp1.EvSapBukrs__c  = 'T100';
        emp1.EvAcubeID__c  = 'C6016241';
        update emp1;


        user1 = Utils_TestDataFactory.createUserFull(Utils_TestDataFactory.getProfile('System Administrator'), emp1.EvMailAddr__c, emp1.EvUniqID__c);
        RecordType recordId = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
        

        Map<String,String> pickMap = new Map<String,String>();
        acc = Utils_TestDataFactory.createAccount('TestAcc');
        acc.AccountNumber = 'A2222233';
        acc.MDGCheck__c = true;
        update acc;

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

        CostCenter__c costCenterT100 = new CostCenter__c(
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
        );
        insert costCenterT100;
        
        /**
         * Opportunity
         */
        pickMap = Utils.getPicklistOptionType('Opportunity','BusinessLevel__c')[0];
        oppty = Utils_TestDataFactory.createOpportunity('TestOppty', acc.id);
        oppty.OwnerId = user1.Id;
        oppty.cOriginAcc__c = acc.id;
        oppty.Amount = 1234124;
        oppty.BusinessLevel__c = pickMap.get('value');
        oppty.cPrimarySalesDepartment__c = costCenter.Id;
        oppty.SalesDepartment__c = costCenter.Id;

        // Collaboration Oppty
        coOpp = Utils_TestDataFactory.createOpportunity('TestCoOppty', acc.id);
        coOpp.cOriginAcc__c = acc.id;
        coOpp.Amount = 1234124;
        coOpp.BusinessLevel__c = pickMap.get('value');
        coOpp.cPrimarySalesDepartment__c = costCenterT100.Id;
        coOpp.SalesDepartment__c = costCenterT100.Id;
        
        oppty.CollaborationBOId__c = coOpp.id;
        
        List<Opportunity> updateOpptyList = new Opportunity[]{oppty, coOpp};
        update updateOpptyList;

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


        opptyAct.WhatId__c = oppty.id;
        opptyAct.TransactionName__c = OpportunityActivityHelper.ACT_CODE_REQUEST_RESOURCES;
        opptyAct.ExtId__c = oppty.id + '_'+opptyAct.TransactionName__c;
        opptyAct.StartDate__c = Date.today();
        opptyAct.EndDate__c = Date.today();
        opptyAct.DueDate__c = Date.today();
        insert opptyAct;
        
        //Added by Anish - v 1.2
        opptyAct1.WhatId__c = oppty.id;
        opptyAct1.TransactionName__c = OpportunityActivityHelper.ACT_CODE_DROP_OPPORTUNITY;
        opptyAct1.ExtId__c = oppty.id + '_'+opptyAct1.TransactionName__c;
        opptyAct1.StartDate__c = Date.today();
        opptyAct1.EndDate__c = Date.today();
        opptyAct1.DueDate__c = Date.today();
        insert opptyAct1;
        
        opptyAct2.WhatId__c = oppty.id;
        opptyAct2.TransactionName__c = 'ZP82';
        opptyAct2.ExtId__c = oppty.id + '_'+opptyAct2.TransactionName__c;
        opptyAct2.StartDate__c = Date.today();
        opptyAct2.EndDate__c = Date.today();
        opptyAct2.DueDate__c = Date.today();
        insert opptyAct2;
        
        
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


        // employee setting
        // v1.1 - Gitesh Saini
        Employee__c[] pahtlistEmpList = new List<Employee__c>();
        Employee__c pathlist_emp1 = new Employee__c(
            Name = '김원만',
            EvUniqID__c = 'C6012354',
            EvSapEmpNO__c = '12354',
            EvAcubeID__c = 'C6012354',
            EvSapBukrs__c = 'T100',
            EvStatus__c = '1'
        );
        pahtlistEmpList.add(pathlist_emp1);

        Employee__c pathlist_emp2 = new Employee__c(
            Name = '이승준',
            EvUniqID__c = 'C6031379',
            EvSapEmpNO__c = '31379',
            EvAcubeID__c = 'C6031379',
            EvSapBukrs__c = 'T100',
            EvStatus__c = '1'
        );
        pahtlistEmpList.add(pathlist_emp2);

        Employee__c pathlist_emp3 = new Employee__c(
            Name = '허용석',
            EvUniqID__c = 'C6017093',
            EvSapEmpNO__c = '17093',
            EvAcubeID__c = 'C6017093',
            EvSapBukrs__c = 'T100',
            EvStatus__c = '6'
        );
        pahtlistEmpList.add(pathlist_emp3);
        // v1.1
        insert pahtlistEmpList;
       
    }
     
    
    @isTest static void approvalLine_pathlistTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());

        System.debug('# user1 ' + user1);
        system.runAs(user1) {    
            System.debug('oppty.Id ' + oppty.Id);
            System.debug('opptyAct.Id ' + opptyAct.Id);
            //ApprovalLineController.initComponent(oppty.Id, opptyAct1.Id, '', true, true, 'html', ''); //Added by Anish - v 1.2
            ApprovalLineController.initComponent(oppty.Id, opptyAct.Id, null, true, true, 'pathlist','');
        }

        Test.stopTest();
    }

    @isTest static void approvalLine_htmlTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());

        System.debug('# user1 ' + user1);
        system.runAs(user1) {    
            System.debug('oppty.Id ' + oppty.Id);
            System.debug('opptyAct.Id ' + opptyAct.Id);
            ApprovalLineController.initComponent(oppty.Id, opptyAct.Id, null, true, true, 'html', '');
            ApprovalLineController.initComponent(oppty.Id, opptyAct1.Id, '', true, true, 'html', ''); //Added by Anish - v 1.2
            ApprovalLineController.initComponent(oppty.Id, opptyAct2.Id, '', true, true, 'html', ''); //Added by Anish - v 1.2
            
        }

        Test.stopTest();
    }
    
    //Added by Anish- New
    @isTest static void approvalLine_htmlTest_1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());

        System.debug('# user1 ' + user1);
        system.runAs(user1) {    
            System.debug('oppty.Id ' + oppty.Id);
            System.debug('opptyAct.Id ' + opptyAct.Id);
            //ApprovalLineController.initComponent(oppty.Id, opptyAct.Id, null, true, true, 'html', '');
            ApprovalLineController.initComponent(oppty.Id, opptyAct1.Id, '', true, true, 'html', ''); //Added by Anish - v 1.2
            
        }

        Test.stopTest();
    }

    @isTest static void checkTeamMember_Test(){
        Opportunity oppty2 = (Opportunity)oppty.Clone();

        Employee__c emp2 = Utils_TestDataFactory.createEmployee('TestEmp2', 'EPID2');
        // v1.1 - Gitesh Saini
        emp2.EvSapEmpNO__c     = '16241';
        // v1.1
        emp2.EvSapBukrs__c  = 'T100';
        update emp2;
        User user2 = Utils_TestDataFactory.createUserFull(Utils_TestDataFactory.getProfile('Marketing Manager(HQ)'), emp2.EvMailAddr__c, emp2.EvUniqID__c);

        oppty2.OwnerId = user2.Id;
        insert oppty2;
        
        ApprovalLineController.checkPermission(oppty2.Id);

        user2.FederationIdentifier  = '';
        update user2;
        ApprovalLineController.checkPermission(oppty2.Id);

        emp2.EvUniqID__c = '';
        update emp2;
        ApprovalLineController.checkPermission(oppty2.Id);
    }

    @isTest static void exceptionCodeTest(){
        ApprovalLineController.createIfLogList('Test');
        ApprovalLineController.updateOpptyList('Test');
        ApprovalLineController.replaceNewlineToTag('Test'); //Added by Anish -v 1.2
    }

}