/**
 * @description       : 
 * @author            : jiiiiii.park@partner.samsung.com.sds.dev
 * @group             : 
 * @last modified on  : 2021-12-29
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   2020-11-27   jiiiiii.park@partner.samsung.com.sds.dev   Initial Version
**/
@isTest
public class KnoxApprovalTrigger_Test {
    static User user;
    static User salesRepHqUser1;
    static Opportunity oppty;
    static Opportunity_Activity__c opptyAct_changeApproval;
    static Opportunity_Activity__c opptyAct_drop;
    static Opportunity_Activity__c opptyAct_contractApproval;    

    static Master_Service__c master_service;
    static Master_Solution__c master_solution;
    static BizAttribute__c master_attribute;
    static Service__c service;
    static Solution__c solution;    
    static CostCenter__c costCenter;

    static KnoxApproval__c knoxAppCompleted;

    static{
        // [Trigger Switch Setting ] Default Org Switch Setup
        TriggerSwitch__c trSwitch_default = new TriggerSwitch__c(
            All__c = true,
             Opportunity__c = false,
            OpportunityActivity__c = false,
            CollaboApproval__c = true,
            FakeTest__c = true,
            Migration__c = false
        );
        insert trSwitch_default;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
        list<User> lu = new list<User>();
        user = new User(Alias = 'standt1', Email='user0001@samsung.com', 
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                    UserName='user0001@samsung.com');
        insert user;

         // 임직원 및 User Setting
        Employee__c emp1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'EPID1');
        salesRepHqUser1 = Utils_TestDataFactory.createUserFull(
                 Utils_TestDataFactory.getProfile('Sales Rep.(HQ)')
                 , emp1.EvMailAddr__c
                 , emp1.EvUniqID__c);

        oppty = new Opportunity(
			Name = 'Test Opportunity', 
			OwnerId = salesRepHqUser1.Id,
            StageName = 'Z01',
            Type = 'New Business',
            LeadSource = 'Other',
			CloseDate = System.today()
		);
        insert oppty;

        // **************************************************************
        // Opportunity 
        // **************************************************************

        List<MasterActivity__c> masterActList = new List<MasterActivity__c>();
        MasterActivity__c masterAct1 = new MasterActivity__c(Stage__c='Z02',Order__c=1
                                 , Position__c='1',IsImportant__c=true
                                 , ObjectApiName__c='Opportunity',IsActive__c=true,Type__c='HQ',TransactionName__c='ZP21');

        MasterActivity__c masterAct2 = new MasterActivity__c(Stage__c='Z04',Order__c=1
                                 , Position__c='1',IsImportant__c=true
                                 , ObjectApiName__c='Opportunity',IsActive__c=true,Type__c='HQ',TransactionName__c='XP44');
        masterActList.add(masterAct1);
        masterActList.add(masterAct2);
        insert masterActList;

        List<Opportunity_Activity__c> opptyActList = new List<Opportunity_Activity__c>();

        // Change Approval Activity
        opptyAct_changeApproval = new Opportunity_Activity__c(
            Status__c = 'Not Started',
            WhatId__c = oppty.id,
            TransactionName__c = OpportunityActivityHelper.ACT_CODE_CHANGE_APPROVAL_REQUEST
        );
        opptyActList.add(opptyAct_changeApproval);
        // insert opptyAct_changeApproval;

        // Drop Activity
        opptyAct_drop = new Opportunity_Activity__c(
            Status__c = 'Not Started',
            WhatId__c = oppty.id,
            TransactionName__c = OpportunityActivityHelper.ACT_CODE_DROP_OPPORTUNITY,
            LostType__c = OpportunityActivityHelper.OPP_STAGE_DROP
        );
        opptyActList.add(opptyAct_drop);
        // insert opptyAct_drop;

        // 수주 품의 Activity
        opptyAct_contractApproval = new Opportunity_Activity__c(
            Status__c = 'Not Started',
            WhatId__c = oppty.id,
            TransactionName__c = OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL
        );
        opptyActList.add(opptyAct_contractApproval);
        // insert opptyAct_contractApproval;

        insert opptyActList;

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
        );
        insert costCenter;

        //마스터 서비스
        master_service = new Master_Service__c(
            Name = 'Test Master Service',
            Code__c = '20000026'
        );
        insert master_service;

        //마스터 솔루션
        master_solution = new Master_Solution__c(
            Name = 'Test Master Solution',
            Code__c = '30000135'
        );
        insert master_solution;

        master_attribute = new BizAttribute__c(
            Name = 'Test Master Attribute',
            Code__c = 'S125'
        );
        insert master_attribute;

        SvcSolBizAttr__c svcSolBizAttr =  new SvcSolBizAttr__c(
            BizAttribute__c = master_attribute.Id,
            BusinessType__c = 'TI',
            Solution__c = master_solution.Id,
            Use__c = true
        );
        insert svcSolBizAttr;

        service = new Service__c(
            Opportunity__c = oppty.Id,
            Service__c = master_service.Id,
            DeliveryDepartment__c = costCenter.Id,
            SalesDepartment__c  = costCenter.Id,
            ItemNumber__c = 10,
            Changed__c = true,
            DeletionFlag__c = false,
            SendSAP__c = true
        );
        insert service;

        solution = new Solution__c(
            Opportunity__c = oppty.Id,
            Service__c = service.Id,
            BizAttribute__c = master_attribute.Id,
            Solution__c = master_solution.Id,
            PSType__c = svcSolBizAttr.PsType__c,
            WBSClass__c = svcSolBizAttr.WBSClass__c,
            BusinessType__c = svcSolBizAttr.BusinessType__c,
            Changed__c = true,
            DeletionFlag__c = false,
            SendSAP__c = true
            );
        insert solution;

        oppty.StageName = OpportunityActivityHelper.OPP_STAGE_WON;
        update oppty;

        knoxAppCompleted = new KnoxApproval__c(
            Opportunity__c = oppty.Id
          , OpportunityActivity__c = opptyAct_contractApproval.Id
          , Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED
          , syncFlag__c = 'Y'
        );
        insert knoxAppCompleted;

    }

    /**
     * Knox 상태에 따라 Oppty, Oppty Activity Field Update 확인
     */
    @isTest static void test_method_fieldUpdateByKnoxStatus() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        // 사업등급 변경 Activity 상신 (진행중)
        KnoxApproval__c knoxApp = new KnoxApproval__c(Opportunity__c = oppty.Id
                                                    , OpportunityActivity__c = opptyAct_changeApproval.Id
                                                    , Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS
                                                    , RequestBusinessLevel__c = 'S'
                                                    );
        insert knoxApp;
        
        Opportunity_Activity__c opptyAct_changeApproval = [SELECT Status__c FROM Opportunity_Activity__c WHERE Id = :opptyAct_changeApproval.Id];
        system.assertEquals('In Progress', opptyAct_changeApproval.Status__c, 'Activity Status Field must be "In Progress"');

        Opportunity oppty = [SELECT ChangeApprovalBusinessLevel__c, ChangeApprovalStatus__c FROM Opportunity WHERE Id = :oppty.Id];
        system.assertEquals('1', oppty.ChangeApprovalStatus__c, 'Opportunity ChangeApprovalStatus__c Field must be "In Progress"');


        // 사업등급 변경 Activity 승인완료
        knoxApp.Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED;
        update knoxApp;
        // Check Oppty Act Field
        opptyAct_changeApproval = [SELECT Status__c FROM Opportunity_Activity__c WHERE Id = :opptyAct_changeApproval.Id];
        system.assertEquals('Completed', opptyAct_changeApproval.Status__c, 'Activity Status Field must be "Completed"');

        // Check Oppty Field
        oppty = [SELECT ChangeApprovalBusinessLevel__c, ChangeApprovalStatus__c FROM Opportunity WHERE Id = :oppty.Id];
        //system.assertEquals(KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED, oppty.ChangeApprovalStatus__c, 'Opportunity ChangeApprovalStatus__c Field must be "In Progress"');
        //system.assertEquals(oppty.ChangeApprovalBusinessLevel__c, oppty.ChangeApprovalBusinessLevel__c, 'Opportunity ChangeApprovalBusinessLevel__c Field is not Updated');

        Test.stopTest();
    }

    @isTest static void test_method_opptyNotLock() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        KnoxApproval__c knoxApp = new KnoxApproval__c(Opportunity__c = oppty.Id
                                                    , OpportunityActivity__c = opptyAct_drop.Id
                                                    , Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS);
        insert knoxApp;
        system.assertEquals(true, System.Approval.isLocked(oppty.Id));

        knoxApp.Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED;
        update knoxApp;
        system.assertEquals(true, System.Approval.isLocked(oppty.Id));

		Test.stopTest();
    }
    
    /*
    @isTest static void batchTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        
        KnoxApproval__c knoxApp1 = new KnoxApproval__c(Opportunity__c = oppty.Id
                                                    , OpportunityActivity__c = opptyAct_drop.Id
                                                    , Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS);

        KnoxApproval__c knoxApp2 = new KnoxApproval__c(Opportunity__c = oppty.Id
                                                    , OpportunityActivity__c = opptyAct_drop.Id
                                                    , Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS);

        KnoxApproval__c knoxApp3 = new KnoxApproval__c(Opportunity__c = oppty.Id
                                                    , OpportunityActivity__c = opptyAct_drop.Id
                                                    , Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS);
                                                    
        insert knoxApp1;
        insert knoxApp2;
        insert knoxApp3;

        system.assertEquals(false, System.Approval.isLocked(oppty.Id));

        list<KnoxApproval__c> updatelist = new list<KnoxApproval__c>();

        knoxApp1.Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED;
        knoxApp2.Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED;
        knoxApp3.Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED;

        updatelist.add(knoxApp1);
        updatelist.add(knoxApp2);
        updatelist.add(knoxApp3);        

        update updatelist;

        system.assertEquals(false, System.Approval.isLocked(oppty.Id));

		Test.stopTest();
	}
    
    @isTest static void test_method_opptyLock() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        
        KnoxApproval__c knoxApp = new KnoxApproval__c(Opportunity__c = oppty.Id
                                                    , OpportunityActivity__c = opptyAct_contractApproval.Id
                                                    , Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS);
        insert knoxApp;

        system.assertEquals(true, System.Approval.isLocked(oppty.Id), '수주품의 activity must oppty record Lock');

        knoxApp.Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED;
        update knoxApp;
        system.assertEquals(false, System.Approval.isLocked(oppty.Id));

        knoxApp.Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS;
        update knoxApp;
        system.assertEquals(true, System.Approval.isLocked(oppty.Id), '수주품의 activity must oppty record Lock');

        knoxApp.Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_REJECT;
        update knoxApp;
        system.assertEquals(false, System.Approval.isLocked(oppty.Id));

		Test.stopTest();
    }
	*/    

    @isTest static void test_method_insert_syncFlag() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        KnoxApproval__c knoxApp = new KnoxApproval__c(Opportunity__c = oppty.Id
                                                    , OpportunityActivity__c = opptyAct_contractApproval.Id
                                                    , Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS
                                                    , syncFlag__c = 'Y');
        insert knoxApp;

        Test.stopTest();
    }

    

    @isTest static void test_method_update_syncFlag() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        KnoxApproval__c knoxApp2 = new KnoxApproval__c(Opportunity__c = oppty.Id
                                                    , OpportunityActivity__c = opptyAct_contractApproval.Id
                                                    , Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS
                                                    , syncFlag__c = 'N');
        insert knoxApp2;

        knoxApp2.syncFlag__c = 'Y';
        update knoxApp2;
        
        Test.stopTest();
    }

    @isTest static void testOpptyActStatusUpdate() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        KnoxApproval__c prevKnox = new KnoxApproval__c(Name = 'Knox Approval 1'
                                                    , Opportunity__c = oppty.Id
                                                    , OpportunityActivity__c = opptyAct_contractApproval.Id
                                                    , Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_REJECT
                                                    , syncFlag__c = 'N');
        insert prevKnox;

        KnoxApproval__c newKnox = new KnoxApproval__c(Name = 'Knox Approval 2'
                                                    , Opportunity__c = oppty.Id
                                                    , OpportunityActivity__c = opptyAct_contractApproval.Id
                                                    , Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS
                                                    , syncFlag__c = 'N');
        insert newKnox;
        // 최신 결재 상태가 완료로 변경
        newKnox.Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED;
        update newKnox;

        String opptyActStatus = [SELECT Id, Status__c FROM Opportunity_Activity__c WHERE Id = :opptyAct_contractApproval.Id].Status__c;
        System.debug(' #### 1. opptyActStatus : ' + opptyActStatus);


        // 오래된 결재 상태를 반려 상태로 Update
        // 이전에 생성된 knox approval 이 업데이트 되는 경우 oppty Act update가 되지 않아야함
        prevKnox.Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_REJECT;
        update prevKnox;

        opptyActStatus = [SELECT Id, Status__c FROM Opportunity_Activity__c WHERE Id = :opptyAct_contractApproval.Id].Status__c;
        System.debug(' #### 2. opptyActStatus : ' + opptyActStatus);

        System.assertEquals('Completed', opptyActStatus);
        
        Test.stopTest();
    }

    /**
     * TEST [후처리 if-093 이후 로직] 수주품의 결재 후 처리시 결재금액 0원 -> Lost 처리
     */
    @isTest static void test_updateOpptyLostStageAfterSync() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new KnoxApprovalTrigger_TestMock(200));
        System.runAs(salesRepHqUser1) {
            // [if-093 호출]
            System.debug(' # knoxAppCompleted.Id  ' + knoxAppCompleted.Id);
            Map<String, Object> eccPaymentProgChangeMap = KnoxApprovalHelper.callOut_if093(knoxAppCompleted.Id, KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED);
            System.debug(' # eccPaymentProgChangeMap json ' + JSON.serializePretty(eccPaymentProgChangeMap) );
            Boolean eccPaymentProgChange_HttpSuccess = false;
            List<Opportunity> updateOpptyList = new List<Opportunity>();
            List<Solution__c> updateSolutionList = new list<Solution__c>();
            List<KnoxApproval__c> updateKnoxApprovalList = new list<KnoxApproval__c>();

            eccPaymentProgChange_HttpSuccess = String.ValueOf(eccPaymentProgChangeMap.get('StatusCode')) == 'S' ? true : false;
            // if(eccPaymentProgChangeMap.get('INTERFACE_LOG') != null)  ifLogList.add((IF_Log.InterfaceLog)eccPaymentProgChangeMap.get('INTERFACE_LOG'));
            if(eccPaymentProgChange_HttpSuccess){
                if(eccPaymentProgChangeMap.get('Opportunity') != null) {
                    Opportunity updateOppty = (Opportunity)eccPaymentProgChangeMap.get('Opportunity');
                    updateOppty.isUpdatedAuto__c = true;
                    updateOpptyList.add(updateOppty);
                }
                // if(eccPaymentProgChangeMap.get('Solution') != null)       updateSolutionList.addAll((List<Solution__c>) eccPaymentProgChangeMap.get('Solution'));
                if(eccPaymentProgChangeMap.get('Approval') != null)       updateKnoxApprovalList.add((KnoxApproval__c) eccPaymentProgChangeMap.get('Approval'));
            }
            update updateOpptyList;
            // update updateSolutionList;
            update updateKnoxApprovalList;
        }
        Test.stopTest();
    }

    public class KnoxApprovalTrigger_TestMock implements HttpCalloutMock {
        Integer returnStatusCode = 200;
        String returnStatus = 'OK';
        private KnoxApprovalTrigger_TestMock() {    
            returnStatusCode = 200;
            setReturnStatus(returnStatusCode);
        }

        private KnoxApprovalTrigger_TestMock(Integer statusCode) {
            returnStatusCode = statusCode;
            setReturnStatus(returnStatusCode);
        }
        private KnoxApprovalTrigger_TestMock(Integer statusCode, String status) {
            returnStatusCode = statusCode;
            returnStatus = status;
        }
        private void setReturnStatus(Integer statusCode) {
            if (statusCode == 200) {
                returnStatus = 'OK';
            } else if (statusCode == 201) {
                returnStatus = 'Created';
            } else if (statusCode == 202) {
                returnStatus = 'Accepted';
            } else if (statusCode == 300) {
                returnStatus = 'Multiple Choice';
            } else if (statusCode == 301) {
                returnStatus = 'Moved Permanently';
            } else if (statusCode == 302) {
                returnStatus = 'Found';
            } else if (statusCode == 400) {
                returnStatus = 'Bad Request';
            } else if (statusCode == 401) {
                returnStatus = 'Unauthorized';
            } else if (statusCode == 402) {
                returnStatus = 'Payment Required';
            }
        } 
        
        public HTTPResponse respond(HTTPRequest request) {
            String url      = request.getEndPoint();
            System.debug('url::::' + url);
            String jsonData = getResponseData( url + '');
            HttpResponse response = new HttpResponse();

            System.debug( 'jsonData::::' + jsonData);

            response.setHeader('Content-Type', 'application/json');
            response.setBody( jsonData);
    //        response.setBody('{"animals": ["majestic badger_mock", "fluffy bunny", "scary bear", "chicken", "mighty moose"]}');
            response.setStatus(returnStatus);
            response.setStatusCode(returnStatusCode);

            return response;
        }

        public String getResponseData( String val){
            String jsonData = '';
            
            if (val.indexOf('/if093/') > -1) {
                jsonData =  '{ ' +
                        '    "EV_RESULT": "S", ' +
                        '    "START_DATE": "2021.04.01", ' +
                        '    "FINISH_DATE": "2021.06.30", ' +
                        '    "TOTAMT": "0", ' +     // 후처리에 대한 return amount 값을 0으로 설정
                        '    "TOTAMTK": "0", ' +
                        '    "WAERS": "KRW", ' +
                        '    "KWAERS": "KRW", ' +
                        '    "ZZORDER_RATE": "1", ' +
                        '    "ZZORDER_RATE_LO": "1", ' +
                        '    "SGDAT": "2021-01-01", ' +
                        // '    "CT_SOL": [ ' +
                        // '    { ' +
                        // '        "GUID": "0", ' +
                        // '        "ZZORDER_ID": "SDS-20021960", ' +
                        // '        "DESCRIPTION": "[신세계건설(주)] 하남빌리브 344세대 도어록(DP740) 납품설치", ' +
                        // '        "NUMBER_INT": "10", ' +
                        // '        "ZZSERVICE_CLASS": "20000012", ' +
                        // '        "ZZSOLUTION": "30000028", ' +
                        // '        "KSCHL_SOL": "", ' +
                        // '        "ZZBUKRS_H": "T100", ' +
                        // '        "COMPANY": "", ' +
                        // '        "AERDAT": "2020.10.20", ' +
                        // '        "SOLUTION_OWNER": "T100-11975", ' +
                        // '        "SOLUTION_AMT": "0", ' +
                        // '        "CURR": "", ' +
                        // '        "SOLUTION_AMT_LOCAL": "0", ' +
                        // '        "CURR_LOCAL": "", ' +
                        // '        "ZZSALES_CELL_NAM": "T100-11975", ' +
                        // '        "ZZDEVELOP_CELL_N": "T100-11975", ' +
                        // '        "ZZSALES_CELL_L": "", ' +
                        // '        "ZZDEVELOP_CELL_L": "", ' +
                        // '        "SOLUTION_OWNER_L": "" ' +
                        // '    }, ' +
                        // '    { ' +
                        // '        "GUID": "0", ' +
                        // '        "ZZORDER_ID": "SDS-20021960", ' +
                        // '        "DESCRIPTION": "[신세계건설(주)] 하남빌리브 344세대 도어록(DP740) 납품설치", ' +
                        // '        "NUMBER_INT": "10", ' +
                        // '        "ZZSERVICE_CLASS": "20000012", ' +
                        // '        "ZZSOLUTION": "30000032", ' +
                        // '        "KSCHL_SOL": "", ' +
                        // '        "ZZBUKRS_H": "T100", ' +
                        // '        "COMPANY": "", ' +
                        // '        "AERDAT": "2020.10.20", ' +
                        // '        "SOLUTION_OWNER": "T100-11975", ' +
                        // '        "SOLUTION_AMT": "0", ' +
                        // '        "CURR": "", ' +
                        // '        "SOLUTION_AMT_LOCAL": "0", ' +
                        // '        "CURR_LOCAL": "", ' +
                        // '        "ZZSALES_CELL_NAM": "T100-11975", ' +
                        // '        "ZZDEVELOP_CELL_N": "T100-11975", ' +
                        // '        "ZZSALES_CELL_L": "", ' +
                        // '        "ZZDEVELOP_CELL_L": "", ' +
                        // '        "SOLUTION_OWNER_L": "" ' +
                        // '    } ' +
                        // '    ], ' +
                        '    "T_RESULT": [ ' +
                        '    { ' +
                        '       "SEQ": 0, ' +
                        '       "MSGTY": "", ' +
                        '       "MESSAGE": "" ' +
                        '    } ' +
                        '    ], ' +
                        '    "T_DATA": [ ' +
                        '    { ' +
                        '       "SEQ": 0, ' +
                        '       "MSGTY": "", ' +
                        '       "MESSAGE": "" ' +
                        '    } ' +
                        '    ] ' +                        
                        '}';
            }else if (val.indexOf('/if005/') > -1) {
            
            }
        return jsonData;
        }
    }

}