/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-11-17
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                          Modification
 * 1.0   2020-12-18   raeganja@partner.samsung.com   Initial Version
 * 1.1   2021-02-05   soohong0.kim@partner.samsung.com   makeData Method 추가
**/
@isTest
public class IF_EccPaymentProgChangeController_Test {

    // IF_EccPaymentProgChangeController_Test 테스트 클래스
    // INTERFACE_ID = 'IF-093';
    // APEX_CLASS   = 'IF_EccPaymentProgChangeController';
    // METHOD_NAME  = 'paymentProgChange';
    static Account acc;
    static Opportunity oppty;
    static Opportunity coOpp;
    static Profile p;
    static User user;
    static Opportunity_Activity__c opptyAct = new Opportunity_Activity__c();
    static approvaltype__c appType = new approvaltype__c();
    static ApprovalFactor__c factor = new ApprovalFactor__c();
    private static String transactionName;
    /*
    static final String REQUEST_DATA = 	
    '{' +
    '  "IV_WFOBJECT": "ZCRM000090", ' +
    '  "IV_OBJECTKEY": "SDSSFDC2020121710344116081688819", ' +
    '  "IV_STATUS": "AP", ' +
    '  "IV_ZZORDER_ID": "SDS-20032960", ' +
    '  "IV_PROCESS_TYPE": "ZP82", ' +
    '  "IV_ACT_GUID": "string", ' +
    '  "CT_SOL": [ ' +
    '    { ' +
    '        "GUID": "0", ' +
    '        "ZZORDER_ID": "SDS-20021960", ' +
    '        "DESCRIPTION": "[신세계건설(주)] 하남빌리브 344세대 도어록(DP740) 납품설치", ' +
    '        "NUMBER_INT": "10", ' +
    '        "ZZSERVICE_CLASS": "20000012", ' +
    '        "ZZSOLUTION": "30000028", ' +
    '        "KSCHL_SOL": "", ' +
    '        "ZZBUKRS_H": "T100", ' +
    '        "COMPANY": "", ' +
    '        "AERDAT": "2020.10.20", ' +
    '        "SOLUTION_OWNER": "T100-11975", ' +
    '        "SOLUTION_AMT": "0", ' +
    '        "CURR": "", ' +
    '        "SOLUTION_AMT_LOCAL": "0", ' +
    '        "CURR_LOCAL": "", ' +
    '        "ZZSALES_CELL_NAM": "T100-11975", ' +
    '        "ZZDEVELOP_CELL_N": "T100-11975", ' +
    '        "ZZSALES_CELL_L": "", ' +
    '        "ZZDEVELOP_CELL_L": "", ' +
    '        "SOLUTION_OWNER_L": "" ' +
    '    }, ' +
    '    { ' +
    '        "GUID": "0", ' +
    '        "ZZORDER_ID": "SDS-20021960", ' +
    '        "DESCRIPTION": "[신세계건설(주)] 하남빌리브 344세대 도어록(DP740) 납품설치", ' +
    '        "NUMBER_INT": "10", ' +
    '        "ZZSERVICE_CLASS": "20000012", ' +
    '        "ZZSOLUTION": "30000032", ' +
    '        "KSCHL_SOL": "", ' +
    '        "ZZBUKRS_H": "T100", ' +
    '        "COMPANY": "", ' +
    '        "AERDAT": "2020.10.20", ' +
    '        "SOLUTION_OWNER": "T100-11975", ' +
    '        "SOLUTION_AMT": "0", ' +
    '        "CURR": "", ' +
    '        "SOLUTION_AMT_LOCAL": "0", ' +
    '        "CURR_LOCAL": "", ' +
    '        "ZZSALES_CELL_NAM": "T100-11975", ' +
    '        "ZZDEVELOP_CELL_N": "T100-11975", ' +
    '        "ZZSALES_CELL_L": "", ' +
    '        "ZZDEVELOP_CELL_L": "", ' +
    '        "SOLUTION_OWNER_L": "" ' +
    '    } ' +
    '    ] ' +
    '}';
*/


    @TestSetup
    static void makeData(){
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
        oppty.AccountId = acc.id;
        
        coOpp = Utils_TestDataFactory.createOpportunity('TestCoOppty', acc.id);
        coOpp.cOriginAcc__c = acc.id;
        coOpp.Amount = 1234124;
        coOpp.BusinessLevel__c = pickMap.get('value');
        coOpp.AccountId = acc.id;
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

        Company__c company = new Company__c();
        company.Name = 'test';
        insert company;

        CostCenter__c cCenter = new CostCenter__c();
        cCenter.CostCenter__c = 'T100-11975';
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

        KnoxApproval__c approval1 = new KnoxApproval__c();
        approval1.Status__c = '2';
        approval1.MISID__c = 'SDSSFDC2020121710344116081688819';
        approval1.Opportunity__c = oppty.id;
        approval1.OpportunityActivity__c = opptyAct.id;
        insert approval1;
    }

    @isTest
    static void testCallout() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());

        List<KnoxApproval__c> approvalList = [SELECT id, MISID__c, Status__c, Opportunity__c, Opportunity__r.OpportunityCode__c, OpportunityActivity__r.TransactionName__c FROM KnoxApproval__c where MISID__c != null and ( Status__c = '2' or Status__c = '3' or Status__c = '4') limit 1];

        Map<String,String> factorMap = new Map<String,String>();
        List<ApprovalType__c> fTypeList = [SELECT id, Type__c, TransactionName__c FROM ApprovalType__c ];
        for(ApprovalType__c obj : fTypeList){
            factorMap.put(obj.TransactionName__c, obj.Type__c);
        }
        
        for(KnoxApproval__c obj : approvalList){
            IF_EccPaymentProgChangeController.OutputHeader output = new IF_EccPaymentProgChangeController.OutputHeader();
            output.IV_WFOBJECT       = 'ZP82';
            output.IV_OBJECTKEY      = obj.MISID__c;
            Switch on obj.Status__c {
                when '2'{ // AP : 완결
                    output.IV_STATUS = 'AP';
                }
                when '3'{ // RJ : 반려
                    output.IV_STATUS = 'RJ';
                }
                when '4'{ //  : 취소
                    output.IV_STATUS = 'CC';
                }
            }
            output.IV_ZZORDER_ID     = obj.Opportunity__r.OpportunityCode__c;
            output.IV_PROCESS_TYPE   = obj.OpportunityActivity__r.TransactionName__c;

            List<Solution__c> solutionList = [SELECT id FROM Solution__c WHERE Opportunity__c =: obj.Opportunity__c ];
            Set<Id> solutionIds = new Set<Id>();
            for(Solution__c solution : solutionList){
                solutionIds.add(solution.id);
            }
            //CT_SOL 매핑 메소드 호출
            if(obj.OpportunityActivity__r.TransactionName__c == 'ZP82') output.CT_SOL = IF_EccPaymentProgChangeController.getSolutionInfo(solutionIds);
            Map<String,Object> returnMap = IF_EccPaymentProgChangeController.paymentProgChange(JSON.serialize(output));
        }
        Test.stopTest();


        //Map<String,Object> result =  IF_EccPaymentProgChangeController.paymentProgChange(REQUEST_DATA);
        //System.assertEquals(result.get('StatusCode'), 200);

        //HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        //Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
        //System.assertEquals(String.valueOf(returnMap.get('EV_RESULT')), 'S');


    }

    @isTest
    static void testCallout2() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());

        List<KnoxApproval__c> approvalList = [SELECT id, MISID__c, Status__c, Opportunity__c, Opportunity__r.CompanyCode__c, Opportunity__r.OpportunityCode__c, OpportunityActivity__r.TransactionName__c, WFOBJECT__c FROM KnoxApproval__c where MISID__c != null and ( Status__c = '2' or Status__c = '3' or Status__c = '4') limit 1];
        IF_EccPaymentProgChangeController.IF093_Callout(approvalList[0].id, '2',true);
        IF_EccPaymentProgChangeController.IF093_Callout(approvalList[0], '2', true);  // 2021-11-08 / KnoxApproval 자체를 전달하도록 변경
    }

    @isTest
    static void testCallout3() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());

        List<KnoxApproval__c> approvalList = [SELECT id, MISID__c, Status__c, Opportunity__c, Opportunity__r.OpportunityCode__c, OpportunityActivity__r.TransactionName__c FROM KnoxApproval__c where MISID__c != null and ( Status__c = '2' or Status__c = '3' or Status__c = '4') limit 1];
        IF_EccPaymentProgChangeController.IF093_Callout(approvalList[0].id);
    }
    /*
    @isTest
    static void testCallout400() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        Map<String, Object> result = IF_EccPaymentProgChangeController.paymentProgChange(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 400);

        Test.stopTest();
    }

    @isTest
    static void testCalloutError() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));
        Map<String, Object> result =  IF_EccPaymentProgChangeController.paymentProgChange(REQUEST_DATA);

        Test.stopTest();
    }
*/
    @isTest
    static void getSolutionInfoTest() {
        IF_Callout_TestDataSetup.dataSetup();

        List<Solution__c> solutionList = [SELECT Id
                                               , CurrencyIsoCode
                                               , Amount__c
                                               , Service__r.Opportunity__r.CurrencyIsoCode
                                               , Service__r.Opportunity__c
                                               , Service__r.Opportunity__r.CompanyCode__c
                                               , Service__r.Opportunity__r.OpportunityCode__c
                                               , Service__r.Opportunity__r.CloseDate
                                               , Service__r.Opportunity__r.Name
                                               , Service__r.Opportunity__r.Amount
                                               , Service__r.ItemNumber__c
                                               , Service__r.SalesDepartment__r.CostCenter__c
                                               , Service__r.DeliveryDepartment__r.CostCenter__c
                                               , Service__r.Service__r.Code__c
                                               , Solution__r.Code__c
                                            FROM Solution__c];

        Set<Id> solutionIdSet = new Set<Id>();
        for (Solution__c solutionData : solutionList) {
            solutionIdSet.add(solutionData.Id);
        }

        IF_EccPaymentProgChangeController.getSolutionInfo(solutionIdSet);
        IF_EccPaymentProgChangeController.getSolutionInfo(solutionList);
    }
    
}