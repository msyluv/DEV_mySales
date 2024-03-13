/**
 * @description       : 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2023-03-29 
 * @last modified by  : divyam.gupta@samsung.com
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2020-12-02   hj.lee@dkbmc.com   Initial Version
 * 1.1   2022-05-24   akash.g@samsung.com  Add test function of User manual Button functionality(testOpenFileEng,testOpenFileKo,testOpenFileCatchScenerio)
 * 1.2   2022-06-14   akash.g@samsung.com  Add simulation button functionality 
 * 1.3   2023-03-29   divyam.gupta@samsung.com  Coverage for Lost Enhancement condition [My Sales-177]
**/
@isTest
public class OpportunityActivityNewController_Test {
    static RecordType rcdType_Acc_MDG;
    static RecordType rcdType_Oppty_HQ;
    static RecordType rcdType_Oppty_Logi;

    static Employee__c emp_0;
    static Employee__c emp_1;
    static Employee__c emp_2;

    static User user_sysAdmin;
    static User user_salesRepHQ;
    static User user_salesRepLogi;

    static Account acc_1;

    static MasterActivity__c ma_1;

    static Company__c comp_SDS;
    static Company__c comp_SDSAP;

    static CostCenter__c cc_1;
    static CostCenter__c cc_2;

    static Opportunity oppty_HQ_1_HQ;
    static Opportunity oppty_HQ_1_1_HQ;
    static Opportunity oppty_HQ_2_Corp;
    static Opportunity oppty_HQ_2_HQ;
    static Opportunity oppty_HQ_3_HQ;
    static Opportunity oppty_HQ_4_HQ;    //Anish

    static Opportunity_Activity__c opptyAct_Corp_1;
    static Opportunity_Activity__c opptyAct_HQ_2;
    static Opportunity_Activity__c opptyAct_HQ_3;
    static Opportunity_Activity__c opptyAct_HQ_4;  //Anish
    public static Opportunity LogiOpportunity;  //kajal
    public static Opportunity_Activity__c OpAct ; //kajal
    public static Opportunity_Activity__c OpAct1 ; //kajal

    static {
        TriggerSwitch__c ts = new TriggerSwitch__c(
            // Event__c = true,
            // OpportunityCodeSetting__c = true,
            // OpportunityBizLvSetting__c = true,
            // OpportunityDeleteSetting__c = true,
            // OpportunityLogisticsValidation__c = true,
            // OpportunitySendToSAP__c = true,
            // RevenueScheduleOpportunity__c = false,
            // Migration__c = false,
            // WeeklyReportSend__c = true,
            All__c = true,
            Opportunity__c = false,  //Anish
            OpportunityActivity__c = true
        );
        insert ts;

        rcdType_Acc_MDG = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'MDG' Limit 1];
        rcdType_Oppty_HQ = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
        rcdType_Oppty_Logi = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Logistics' Limit 1];

        emp_0 = Utils_TestDataFactory.createEmployee('TestEmp0', 'EPID0');
        emp_1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'EPID1');
        emp_2 = Utils_TestDataFactory.createEmployee('TestEmp2', 'EPID2');

        user_sysAdmin = Utils_TestDataFactory.createUserFull(
                            Utils_TestDataFactory.getProfile('System Administrator')
                            , emp_0.EvMailAddr__c
                            , emp_0.EvUniqID__c
                        );
        user_salesRepHQ = Utils_TestDataFactory.createUserFull(
                            Utils_TestDataFactory.getProfile('Sales Rep.(HQ)')
                            , emp_1.EvMailAddr__c
                            , emp_1.EvUniqID__c
                        );
        user_salesRepLogi = Utils_TestDataFactory.createUserFull(
                                Utils_TestDataFactory.getProfile('Sales Rep.(Logi)')
                                , emp_2.EvMailAddr__c
                                , emp_2.EvUniqID__c
                            );


        acc_1 = new Account(
            Name = 'Test Account 1',
            RecordTypeId = rcdType_Acc_MDG.Id,
            MDGCheck__c = true
        );
        insert acc_1;

        ma_1 = new MasterActivity__c(
            ObjectApiName__c = 'Opportunity',
            Stage__c = 'Z03',  //Anish
            Order__c = 1,
            Type__c = 'Logistics',
            TransactionName__c = 'ZP21',
            RequiredTransaction__c = 'XP11'
        );
        insert ma_1;

        List<Company__c> compList = new List<Company__c>();
        comp_SDS = new Company__c(
            Name = 'Samsung SDS',
            CompanyCode__c = 'T100',
            Country__c = 'KR',
            EPCompanyCode__c = 'C60'
        );
        compList.add(comp_SDS);

        comp_SDSAP = new Company__c(
            Name = 'SDSAP',
            CompanyCode__c = 'T501',
            Country__c = 'SG',
            EPCompanyCode__c = 'C6S'
        );
        compList.add(comp_SDSAP);

        insert compList;

        List<CostCenter__c> ccList = new List<CostCenter__c>();
        cc_1 = new CostCenter__c(
            Name = 'Test Cost Center 1', 
            Company__c = comp_SDS.Id, 
            CompanyCode__c = 'T100', 
            CostCenter__c = 'T100-12345'
        );
        ccList.add(cc_1);

        cc_2 = new CostCenter__c(
            Name = 'Test Cost Center 1', 
            Company__c = comp_SDSAP.Id, 
            CompanyCode__c = 'T501', 
            CostCenter__c = 'T501-12345'
        );
        ccList.add(cc_2);

        insert ccList;

        List<Opportunity> insert_OpptyList = new List<Opportunity>();
        oppty_HQ_1_HQ = new Opportunity(
            Name = 'Test Opportunity 1 HQ',
            RecordTypeId = rcdType_Oppty_HQ.Id,
            CurrencyIsoCode = 'USD', 
            Amount = 5000000, 
            CloseDate = Date.today(), 
            StageName = 'Z01',
            BusinessType__c = 'TI',
            AccountId = acc_1.Id, 
            cOriginAcc__c = acc_1.Id, 
            SalesDepartment__c = cc_1.Id,
            XP63_VRB_APPROVAL_TYPE__c = '10',
            XP73_VRB_APPROVAL_TYPE__c = '10'
            
        );
        insert_OpptyList.add(oppty_HQ_1_HQ);
		oppty_HQ_1_1_HQ = new Opportunity(
            Name = 'Test Opportunity 1-1 HQ',
            RecordTypeId = rcdType_Oppty_HQ.Id,
            CurrencyIsoCode = 'USD', 
            Amount = 5000000, 
            CloseDate = Date.today(), 
            StageName = 'Z01',
            BusinessType__c = 'TI',
            AccountId = acc_1.Id, 
            cOriginAcc__c = acc_1.Id, 
            SalesDepartment__c = cc_1.Id,
            XP63_VRB_APPROVAL_TYPE__c = '10',
            XP73_VRB_APPROVAL_TYPE__c = '10',
            Opportunity_Review_VRB_Type_Confirm__c = '30',
            OpportunityCode__c = 'SDS-21999991'
            
        );
        insert_OpptyList.add(oppty_HQ_1_1_HQ);
        
        oppty_HQ_2_Corp = new Opportunity(
            Name = 'Test Opportunity 2 Collabo',
            RecordTypeId = rcdType_Oppty_HQ.Id,
            CurrencyIsoCode = 'USD', 
            Amount = 5000000, 
            CloseDate = Date.today(), 
            StageName = 'Z01', 
            BusinessType__c = 'TI',
            AccountId = acc_1.Id, 
            cOriginAcc__c = acc_1.Id, 
            SalesDepartment__c = cc_2.Id,
            OpportunityCode__c = 'SDS-21999990'
        );
        insert_OpptyList.add(oppty_HQ_2_Corp);

        oppty_HQ_2_HQ = new Opportunity(
            Name = 'Test Opportunity 2 Collabo',
            RecordTypeId = rcdType_Oppty_HQ.Id,
            CurrencyIsoCode = 'USD', 
            Amount = 5000000, 
            CloseDate = Date.today(), 
            StageName = 'Z01', 
            AccountId = acc_1.Id, 
            cOriginAcc__c = acc_1.Id, 
            SalesDepartment__c = cc_1.Id,
            OpportunityCode__c = 'SDS-21999990'
        );
        insert_OpptyList.add(oppty_HQ_2_HQ);

        oppty_HQ_3_HQ = new Opportunity(
            Name = 'Test Opportunity 3 Collabo',
            RecordTypeId = rcdType_Oppty_HQ.Id,
            CurrencyIsoCode = 'USD', 
            Amount = 5000000, 
            CloseDate = Date.today(), 
            StageName = 'Z01', 
            AccountId = acc_1.Id, 
            cOriginAcc__c = acc_1.Id, 
            SalesDepartment__c = cc_1.Id
        );
        insert_OpptyList.add(oppty_HQ_3_HQ);
        
        //Anish
        oppty_HQ_4_HQ = new Opportunity(
            Name = 'Test Opportunity 4 status Activity',
            RecordTypeId = rcdType_Oppty_Logi.Id,
            CurrencyIsoCode = 'USD', 
            Amount = 5000000, 
            CloseDate = Date.today(), 
            StageName = 'Z01', 
            AccountId = acc_1.Id, 
            cOriginAcc__c = acc_1.Id, 
            SalesDepartment__c = cc_1.Id,
            LogisticsCustomerType__c = 'EXTAC'
        );
        insert_OpptyList.add(oppty_HQ_4_HQ);

        insert insert_OpptyList;

        List<Opportunity> update_OpptyList = new List<Opportunity>();
        oppty_HQ_2_Corp.CollaborationBOId__c = oppty_HQ_2_HQ.Id;
        oppty_HQ_2_HQ.CollaborationBOId__c = oppty_HQ_2_Corp.Id;
        
        update_OpptyList.add(oppty_HQ_2_Corp);
        update_OpptyList.add(oppty_HQ_2_HQ);

        Update update_OpptyList;
        
        //Anish
        opptyAct_HQ_4 =new Opportunity_Activity__c(Transactionname__c = 'XP71',
                                                  WhatId__c = oppty_HQ_4_HQ.Id ,
                                                  Status__c = 'Completed');
            
            insert opptyAct_HQ_4;
        
    }

    @isTest
    private static void initComponent_IT_ZP82_Single_1() { // Contract Approval        
        System.runAs(user_sysAdmin){
            Test.startTest();
            OpportunityActivityNewController.initComponent(oppty_HQ_1_HQ.Id, 'ZP82');
            Test.stopTest();
        }        
    }
    @isTest
    private static void initComponent_IT_ZP82_Single_2() { // Contract Approval        
        System.runAs(user_sysAdmin){
            Test.startTest();
            OpportunityActivityNewController.initComponent(oppty_HQ_1_1_HQ.Id, 'ZP82');
            Test.stopTest();
        }        
    }
    
    @isTest
    private static void initComponent_IT_ZP82_Collabo_1() { // Contract Approval        
        System.runAs(user_sysAdmin){
            Test.startTest();
            OpportunityActivityNewController.initComponent(oppty_HQ_2_Corp.Id, 'ZP82');
            Test.stopTest();
        }        
    }
    
    @isTest
    private static void initComponent_IT_ZP82_Collabo_2() { // Contract Approval        
        System.runAs(user_sysAdmin){
            Test.startTest();
            OpportunityActivityNewController.initComponent(oppty_HQ_2_HQ.Id, 'ZP82');
            Test.stopTest();
        }        
    }
    
    @isTest
    private static void initComponent_IT_ZP32_Collabo_1() { // Request Pre-Sales Resources        
        System.runAs(user_sysAdmin){
            Test.startTest();
            OpportunityActivityNewController.initComponent(oppty_HQ_2_Corp.Id, 'ZP32');
            Test.stopTest();
        }        
    }
    
    //Anish
    @isTest
    private static void initComponent_IT_ZP32_Collabo_123() { // Request Pre-Sales Resources        
        System.runAs(user_sysAdmin){
            Test.startTest();
            OpportunityActivityNewController.initComponent(oppty_HQ_4_HQ.Id, 'XP71');
            OpportunityActivityNewController.createOpportunityActivity(opptyAct_HQ_4);
            Test.stopTest();
        }        
    }
    
    @isTest
    private static void initComponent_IT_ZP32_Collabo_2() { // Request Pre-Sales Resources        
        System.runAs(user_sysAdmin){
            Test.startTest();
            OpportunityActivityNewController.initComponent(oppty_HQ_2_HQ.Id, 'ZP32');
            Test.stopTest();
        }        
    }
    
    @isTest
    private static void initComponent_IT_ZPZ2_Single_1() { // Drop/Lost        
        System.runAs(user_sysAdmin){
            Test.startTest();
            OpportunityActivityNewController.initComponent(oppty_HQ_1_HQ.Id, 'ZPZ2');
            Test.stopTest();
        }        
    }
    
    @isTest
    private static void initComponent_IT_ZPZ2_Single_1_1() { // Drop/Lost        
        System.runAs(user_sysAdmin){
            Test.startTest();
            OpportunityActivityNewController.initComponent(oppty_HQ_1_1_HQ.Id, 'ZPZ2');
            Test.stopTest();
        }        
    }

    @isTest
    private static void getOpportunityActivity_1() {        
        System.runAs(user_sysAdmin){
            Test.startTest();
            OpportunityActivityNewController.getOpportunityActivity(oppty_HQ_3_HQ.Id);
            Test.stopTest();
        }        
    }
    @isTest
    private static void getOpportunityActivity_2() {        
        System.runAs(user_sysAdmin){
            Test.startTest();
            OpportunityActivityNewController.getOpportunityActivity(oppty_HQ_1_1_HQ.Id);
            Test.stopTest();
        }        
    }

    @isTest
    private static void checkStatusActivity_1() {        
        System.runAs(user_sysAdmin){
            Test.startTest();
            Date today = Date.today(); 
            
            Opportunity_Activity__c opptyAct_Corp_1 = new Opportunity_Activity__c(
                WhatId__c = oppty_HQ_2_Corp.Id,
                ExtID__c = oppty_HQ_2_Corp.Id + '_' + 'XP11',
                TransactionName__c = 'XP11'
            );
            upsert opptyAct_Corp_1 ExtID__c;            

            OpportunityActivityPanelController.ActivityItem oa = new OpportunityActivityPanelController.ActivityItem(ma_1, opptyAct_Corp_1, today.addDays(1));
            oa.opptyId = oppty_HQ_2_HQ.Id;
            oa.Index = 1;
            oa.isAccessible = true;
            
            OpportunityActivityNewController.checkStatusActivity(JSON.serialize(oa));
            Test.stopTest();
        }        
    }
    //Anish
    @isTest
    private static void checkStatusActivity_11() {        
        System.runAs(user_sysAdmin){
            Test.startTest();
            Date today = Date.today(); 
            
            Opportunity_Activity__c opptyAct_Corp_1 = new Opportunity_Activity__c(
                WhatId__c = oppty_HQ_2_Corp.Id,
                ExtID__c = oppty_HQ_2_Corp.Id + '_' + 'XP11',
                TransactionName__c = 'XP11'
            );
            upsert opptyAct_Corp_1 ExtID__c;            

            OpportunityActivityPanelController.ActivityItem oa = new OpportunityActivityPanelController.ActivityItem(ma_1, opptyAct_Corp_1, today.addDays(1));
            oa.opptyId = oppty_HQ_4_HQ.Id;
            oa.Index = 1;
            oa.isAccessible = true;
            
            OpportunityActivityNewController.checkStatusActivity(JSON.serialize(oa));
            Test.stopTest();
        }        
    }

    @isTest
    private static void checkStatusActivity_2() {        
        System.runAs(user_sysAdmin){
            Test.startTest();
            Date today = Date.today(); 
            
            Opportunity_Activity__c opptyAct_HQ_3 = new Opportunity_Activity__c(
                WhatId__c = oppty_HQ_3_HQ.Id,
                EndDate__c = System.today(),
                ExtID__c = oppty_HQ_3_HQ.Id + '_' + 'ZPZ2',
                TransactionName__c = 'ZPZ2'
            );
            
            upsert opptyAct_HQ_3 ExtID__c;

            OpportunityActivityPanelController.ActivityItem oa = new OpportunityActivityPanelController.ActivityItem(ma_1, opptyAct_HQ_3, today.addDays(1));
            oa.opptyId = oppty_HQ_3_HQ.Id;
            oa.Index = 1;
            oa.isAccessible = true;
            
            OpportunityActivityNewController.checkStatusActivity(JSON.serialize(oa));
            
            
         
            
            
            Test.stopTest();
        }        
    }
    
    @isTest
    private static void upsertOpportunityActivity_1() {        
        System.runAs(user_sysAdmin){
            Test.startTest();
            Opportunity_Activity__c opptyAct_HQ_2 = new Opportunity_Activity__c(
                WhatId__c = oppty_HQ_1_HQ.Id,
                Status__c = 'Completed',
                ExtID__c = oppty_HQ_1_HQ.Id + '_' + 'ZP21',
                TransactionName__c = 'ZP21'
            );
            upsert opptyAct_HQ_2 ExtID__c;
            
            OpportunityActivityNewController.upsertOpportunityActivity(JSON.serialize(opptyAct_HQ_2));
            Test.stopTest();
        }        
    }
    /*
    @isTest
    private static void upsertOpportunityActivity_1_1() {        
        System.runAs(user_sysAdmin){
            Test.startTest();
            Opportunity_Activity__c opptyAct_HQ_2 = new Opportunity_Activity__c(
                WhatId__c = oppty_HQ_1_1_HQ.Id,
                Status__c = 'Completed',
                ExtID__c = oppty_HQ_1_1_HQ.Id + '_' + 'ZP21',
                TransactionName__c = 'ZP21'
            );
            upsert opptyAct_HQ_2 ExtID__c;
            
            OpportunityActivityNewController.upsertOpportunityActivity(JSON.serialize(opptyAct_HQ_2));
            Test.stopTest();
        }        
    }
	*/
    @isTest
    private static void upsertActivityDescription_1() {        
        System.runAs(user_sysAdmin){
            Test.startTest();
            Opportunity_Activity__c opptyAct_HQ_2 = new Opportunity_Activity__c(
                WhatId__c = oppty_HQ_1_HQ.Id,            
                ExtID__c = oppty_HQ_1_HQ.Id + '_' + 'ZP21',
                TransactionName__c = 'ZP21'
            );
            upsert opptyAct_HQ_2 ExtID__c;
            OpportunityActivityNewController.upsertActivityDescription(JSON.serialize(opptyAct_HQ_2));
            Test.stopTest();
        }
    }
    /*
    @isTest
    private static void upsertActivityDescription_1_1() {        
        System.runAs(user_sysAdmin){
            Test.startTest();
            Opportunity_Activity__c opptyAct_HQ_2 = new Opportunity_Activity__c(
                WhatId__c = oppty_HQ_1_1_HQ.Id,            
                ExtID__c = oppty_HQ_1_1_HQ.Id + '_' + 'ZP21',
                TransactionName__c = 'ZP21'
            );
            upsert opptyAct_HQ_2 ExtID__c;
            OpportunityActivityNewController.upsertActivityDescription(JSON.serialize(opptyAct_HQ_2));
            Test.stopTest();
        }
    }
    */
    @isTest
    private static void deleteTempOpportunityActivity_1() {        
        System.runAs(user_sysAdmin){
            Test.startTest();
            Opportunity_Activity__c opptyAct_HQ_3 = new Opportunity_Activity__c(
                WhatId__c = oppty_HQ_3_HQ.Id,
                EndDate__c = System.today(),
                ExtID__c = oppty_HQ_3_HQ.Id + '_' + 'ZPZ2',
                TransactionName__c = 'ZPZ2'
            );
            upsert opptyAct_HQ_3 ExtID__c;
            OpportunityActivityNewController.deleteTempOpportunityActivity(opptyAct_HQ_3.Id);
            Test.stopTest();
        }        
    }
    /*
    @isTest
    private static void deleteTempOpportunityActivity_1_1() {        
        System.runAs(user_sysAdmin){
            Test.startTest();
            Opportunity_Activity__c opptyAct_HQ_3 = new Opportunity_Activity__c(
                WhatId__c = oppty_HQ_1_1_HQ.Id,
                EndDate__c = System.today(),
                ExtID__c = oppty_HQ_1_1_HQ.Id + '_' + 'ZPZ2',
                TransactionName__c = 'ZPZ2'
            );
            upsert opptyAct_HQ_3 ExtID__c;
            OpportunityActivityNewController.deleteTempOpportunityActivity(opptyAct_HQ_3.Id);
            Test.stopTest();
        }        
    }
    */
    @isTest
    private static void setIF155CallByOpptyActId_1() {        
        System.runAs(user_sysAdmin){
            Test.startTest();
            Opportunity_Activity__c opptyAct_HQ_3 = new Opportunity_Activity__c(
                WhatId__c = oppty_HQ_3_HQ.Id,
                EndDate__c = System.today(),
                ExtID__c = oppty_HQ_3_HQ.Id + '_' + 'ZPZ2',
                TransactionName__c = 'ZPZ2'
            );
            upsert opptyAct_HQ_3 ExtID__c;
            OpportunityActivityNewController.setIF155CallByOpptyActId(opptyAct_HQ_3.Id);
            Test.stopTest();
        }        
    }
    /*
    @isTest
    private static void setIF155CallByOpptyActId_1_1() {        
        System.runAs(user_sysAdmin){
            Test.startTest();
            Opportunity_Activity__c opptyAct_HQ_3 = new Opportunity_Activity__c(
                WhatId__c = oppty_HQ_1_1_HQ.Id,
                EndDate__c = System.today(),
                ExtID__c = oppty_HQ_1_1_HQ.Id + '_' + 'ZPZ2',
                TransactionName__c = 'ZPZ2'
            );
            upsert opptyAct_HQ_3 ExtID__c;
            OpportunityActivityNewController.setIF155CallByOpptyActId(opptyAct_HQ_3.Id);
            Test.stopTest();
        }        
    }
	*/    
    // static RecordType RT_OPPTY_HQ;
    // static RecordType RT_OPPTY_LOGISTICS;
    // static User systemAdminUser;
    // static User salesRepHqUser1;
    // static User salesRepLogiUser1;
    // static Employee__c emp0;
    // static Employee__c emp1;
    // static Employee__c emp2;
    // static Opportunity opptyHQ;
    // static Opportunity opptyLogi;
    // 
    // static {
    //     // [Trigger Switch Setting ] Default Org Switch Setup
    //     TriggerSwitch__c trSwitch_default = new TriggerSwitch__c(
    //         All__c = true,
    //         Opportunity__c = true,
    //         OpportunityActivity__c = true
    //     );
    //     insert trSwitch_default;
    //     
    //     RT_OPPTY_HQ        = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
    //     RT_OPPTY_LOGISTICS = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Logistics' Limit 1];
    //     
    //     // 임직원 및 User Setting
    //     emp0 = Utils_TestDataFactory.createEmployee('TestEmp0', 'EPID0');
    //     systemAdminUser = Utils_TestDataFactory.createUserFull(
    //             Utils_TestDataFactory.getProfile('System Administrator')
    //             , emp0.EvMailAddr__c
    //             , emp0.EvUniqID__c);
    // 
    //     // 임직원 및 User Setting
    //     emp1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'EPID1');
    //     salesRepHqUser1 = Utils_TestDataFactory.createUserFull(
    //             Utils_TestDataFactory.getProfile('Sales Rep.(HQ)')
    //             , emp1.EvMailAddr__c
    //             , emp1.EvUniqID__c);
    // 
    //     // 임직원 및 User Setting
    //     emp2 = Utils_TestDataFactory.createEmployee('TestEmp2', 'EPID2');
    //     salesRepLogiUser1 = Utils_TestDataFactory.createUserFull(
    //             Utils_TestDataFactory.getProfile('Sales Rep.(Logi)')
    //             , emp2.EvMailAddr__c
    //             , emp2.EvUniqID__c);
    // 
    //     
    //     Account acc = new Account(Name = 'accTest',  MDGCheck__c=true);
    //     insert acc;
    // 
    //     MasterActivity__c mastrtAct1_HQ = new MasterActivity__c(
    //         TransactionName__c=Utils.getPicklistOptionType('MasterActivity__c','TransactionName__c')[0].get('value')
    //         , Stage__c='Z01',Order__c=1
    //         , IsRequiredKnoxApproval__c=false
    //         , Position__c='1',IsImportant__c=true,IsRequired__c=true
    //         , ObjectApiName__c='Opportunity',IsActive__c=true,Type__c='HQ'
    //     );
    //     insert mastrtAct1_HQ;
    // 
    //     MasterActivity__c mastrtAct2_droplost_HQ = new MasterActivity__c(
    //         TransactionName__c = opportunityActivityHelper.ACT_CODE_DROP_OPPORTUNITY
    //         , Stage__c='Z01',Order__c=2
    //         , IsRequiredKnoxApproval__c=false
    //         , Position__c='1',IsImportant__c=true,IsRequired__c=true
    //         , ObjectApiName__c='Opportunity',IsActive__c=true,Type__c='HQ'
    //     );                                 
    //     insert mastrtAct2_droplost_HQ;
    // 
    //     MasterActivity__c mastrtAct1_Logi = new MasterActivity__c(
    //         TransactionName__c=Utils.getPicklistOptionType('MasterActivity__c','TransactionName__c')[0].get('value')
    //         , Stage__c='Z01',Order__c=1
    //         , IsRequiredKnoxApproval__c=false
    //         , Position__c='1',IsImportant__c=true,IsRequired__c=true
    //         , ObjectApiName__c='Opportunity',IsActive__c=true,Type__c='Logistics'
    //     );
    //     insert mastrtAct1_Logi;
    // 
    //     MasterActivity__c mastrtAct2_Logi = new MasterActivity__c(TransactionName__c=Utils.getPicklistOptionType('MasterActivity__c','TransactionName__c')[1].get('value')
    //                              , Stage__c='Z01',Order__c=2
    //                              , IsRequiredKnoxApproval__c=false
    //                              , Position__c='1',IsImportant__c=true,IsRequired__c=true
    //                              , ObjectApiName__c='Opportunity',IsActive__c=true,Type__c='Logistics');
    //     insert mastrtAct2_Logi;
    // 
    //     opptyHQ = new Opportunity(Name ='Test' , RecordTypeId = RT_OPPTY_HQ.Id ,AccountId = acc.Id
    //                             , CloseDate =System.today() ,StageName = 'Z01');
    // 
    //     opptyLogi = new Opportunity(Name ='Test' , RecordTypeId = RT_OPPTY_LOGISTICS.Id ,AccountId = acc.Id
    //                             , CloseDate =System.today() ,StageName = 'Z01');
    // }
    // 
    // @isTest
    // private static void test_HQ_oppty() {
    //     Test.startTest();
    //     System.runAs(systemAdminUser){
    //         insert opptyHQ;
    //         
    //         Map<String,List<List<OpportunityActivityPanelController.ActivityItem>>> panelList = (Map<String,List<List<OpportunityActivityPanelController.ActivityItem>>>)OpportunityActivityPanelController.initComponent(opptyHQ.Id, true).get('panelList');
    //         List<OpportunityActivityPanelController.ActivityItem> actList = panelList.get('1').get(0);
    //         OpportunityActivityPanelController.ActivityItem actItem = actList[0];
    //         OpportunityActivityNewController.checkStatusActivity(JSON.serialize(actItem));
    // 
    //         Opportunity_Activity__c opptyAct = new Opportunity_Activity__c( 
    //             Status__c= OpportunityActivityNewController.OPPTYACT_STATUS_COMPLETED
    //             , DueDate__c=System.today()
    //             , TransactionName__c=Utils.getPicklistOptionType('Opportunity_Activity__c','TransactionName__c')[0].get('value')
    //             , WhatId__c=opptyHQ.Id);
    // 
    //         String jsonData = JSON.serialize(opptyAct);
    // 
    //         OpportunityActivityNewController.initComponent(opptyAct.WhatId__c, opptyAct.TransactionName__c);
    //         OpportunityActivityNewController.upsertOpportunityActivity(jsonData);
    //         OpportunityActivityNewController.upsertActivityDescription(jsonData);
    //     }
    //     Test.stopTest();
    // }
    // 
    // @isTest
    // private static void test_HQ_oppty_droplost() {
    //     Test.startTest();
    //     System.runAs(systemAdminUser){
    //         opptyHQ.StageName = OpportunityActivityHelper.OPP_STAGE_WON;
    //         insert opptyHQ;
    //         
    //         Map<String,List<List<OpportunityActivityPanelController.ActivityItem>>> panelList = (Map<String,List<List<OpportunityActivityPanelController.ActivityItem>>>)OpportunityActivityPanelController.initComponent(opptyHQ.Id, true).get('panelList');
    //         List<OpportunityActivityPanelController.ActivityItem> actList = panelList.get('1').get(0);
    //         OpportunityActivityPanelController.ActivityItem actItem = actList[1];
    //         OpportunityActivityNewController.checkStatusActivity(JSON.serialize(actItem));
    // 
    //         String opptyId = opptyHQ.Id;
    //         String transactionName = actItem.MasterAct.TransactionName__c;
    //         OpportunityActivityNewController.initComponent(opptyId, transactionName);
    //        // OpportunityActivityNewController.upsertOpportunityActivity(jsonData);
    //     }
    //     Test.stopTest();
    // }
    // 
    // @isTest
    // private static void test_logistics_oppty() {
    //     Test.startTest();
    //     System.runAs(systemAdminUser){
    //         insert opptyLogi;
    //         
    //         Map<String,List<List<OpportunityActivityPanelController.ActivityItem>>> panelList = (Map<String,List<List<OpportunityActivityPanelController.ActivityItem>>>)OpportunityActivityPanelController.initComponent(opptyLogi.Id, true).get('panelList');
    //         List<OpportunityActivityPanelController.ActivityItem> actList = panelList.get('1').get(0);
    //         OpportunityActivityPanelController.ActivityItem actItem = actList[0];
    //         OpportunityActivityNewController.checkStatusActivity(JSON.serialize(actItem));
    // 
    //         Opportunity_Activity__c opptyAct = new Opportunity_Activity__c( 
    //             Status__c= OpportunityActivityNewController.OPPTYACT_STATUS_COMPLETED
    //             , DueDate__c=System.today()
    //             , TransactionName__c=Utils.getPicklistOptionType('Opportunity_Activity__c','TransactionName__c')[1].get(' ')
    //             , WhatId__c=opptyLogi.Id);
    // 
    //         insert opptyAct;
    //             
    //         String jsonData = JSON.serialize(opptyAct);
    // 
    //         OpportunityActivityNewController.initComponent(opptyAct.WhatId__c, opptyAct.TransactionName__c);
    //         OpportunityActivityNewController.upsertOpportunityActivity(jsonData);
    // 
    //         OpportunityActivityNewController.getOpportunityActivity(opptyAct.Id);
    //         OpportunityActivityNewController.deleteTempOpportunityActivity(opptyAct.WhatId__c);
    //     }
    //     Test.stopTest();
    // }
    // 
    // @isTest
    // private static void test_HQ_checkStatusActivity() {
    //     Test.startTest();
    //     System.runAs(systemAdminUser){
    //         opptyHQ.CloseDate = Date.Today().addDays(-1);
    //         insert opptyHQ;
    // 
    //         Map<String,List<List<OpportunityActivityPanelController.ActivityItem>>> panelList = (Map<String,List<List<OpportunityActivityPanelController.ActivityItem>>>)OpportunityActivityPanelController.initComponent(opptyHQ.Id, true).get('panelList');
    //         List<OpportunityActivityPanelController.ActivityItem> actList = panelList.get('1').get(0);
    //         OpportunityActivityPanelController.ActivityItem actItem = actList[0];
    // 
    // 
    //         OpportunityActivityNewController.checkStatusActivity(JSON.serialize(actItem));
    // 
    //         Opportunity_Activity__c opptyAct = new Opportunity_Activity__c( 
    //             Status__c= OpportunityActivityNewController.OPPTYACT_STATUS_COMPLETED
    //             , DueDate__c=System.today()
    //             , TransactionName__c=Utils.getPicklistOptionType('Opportunity_Activity__c','TransactionName__c')[0].get('value')
    //             , WhatId__c=opptyHQ.Id);
    // 
    //         String jsonData = JSON.serialize(opptyAct);
    // 
    //         OpportunityActivityNewController.initComponent(opptyAct.WhatId__c, opptyAct.TransactionName__c);
    //         OpportunityActivityNewController.upsertOpportunityActivity(jsonData);
    //     }
    //     Test.stopTest();
    // }
    @isTest
    private static void testOpenFileEng() {        
        System.runAs(user_sysAdmin){
            Test.startTest();
            BulletinBoard__c bb = new BulletinBoard__c(
                Name = 'Review Opportunity process(Service/Solution registration) Manual'
            );
            insert bb; 
            Id ids = OpportunityActivityNewController.openfile();
            Test.stopTest();
        }        
    }
    @isTest
    private static void testOpenFileko() {
      User user = new User(
            Alias = 'testUser'
            , Email = 'SysAdminTestuser@dkbmc.com'
            , EmailEncodingKey = 'UTF-8'
            , LastName = 'Testing'
            , LanguageLocaleKey = 'ko'
            , LocaleSidKey = 'en_US'
            , EmployeeNumber = 'AC100000'
            , TimeZoneSidKey = 'Asia/Seoul'
            , ProfileId =  Utils_TestDataFactory.getProfile('System Administrator').id
            , UserName = 'testUser11@testing.com'
        );
                                
        insert user;
        
        System.runAs(user){
            Test.startTest();
            BulletinBoard__c bb = new BulletinBoard__c(
                Name = '사업참여 검토 프로세스(서비스솔루션 등록) 매뉴얼'
            );
            insert bb; 
            Id ids = OpportunityActivityNewController.openfile();
            Test.stopTest();
        }      
    }
    
    @isTest
    private static void testOpenFileCatchScenerio() {        
        System.runAs(user_sysAdmin){
            Test.startTest();
            Id ids = OpportunityActivityNewController.openfile();
            Test.stopTest();
        }        
    }
    
    //V.1.2. Add simulation button functionality
    @isTest
    private static void testcheckOppCSPMSPValue() {        
        System.runAs(user_sysAdmin){
            Test.startTest();
            String cspvalue = OpportunityActivityNewController.checkOppCSPMSPValue(oppty_HQ_1_HQ.Id);
            Test.stopTest();
        }        
    }
    
    //V.1.2. Add simulation button functionality
    @isTest
    private static void testfetchOppDataForSimulation() {        
        System.runAs(user_sysAdmin){
            Test.startTest();
            Opportunity opp = OpportunityActivityNewController.fetchOppDataForSimulation(oppty_HQ_1_HQ.ID);
            Test.stopTest();
        }        
    }
    
        @isTest
    private static void creditAssessmentActivity1() {   
             RecordType RT_OPPTY_LOGISTICS;

        System.runAs(user_sysAdmin){
            Test.startTest();
              RT_OPPTY_LOGISTICS = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Logistics' Limit 1];
            
            
        MasterActivity__c ma_2 = new MasterActivity__c(
            ObjectApiName__c = 'Opportunity',
            Stage__c = 'Z03',  
            Order__c = 1,
            Type__c = 'Logistics',
            TransactionName__c = '2.4.5.',
            RequiredTransaction__c = 'XP11'
        );
                    insert ma_2;

                 MasterActivity__c ma_3 = new MasterActivity__c(
            ObjectApiName__c = 'Opportunity',
            Stage__c = 'Z03', 
            Order__c = 1,
            Type__c = 'Logistics',
            TransactionName__c = '2.3.2.',
            RequiredTransaction__c = 'XP11'
        );
        insert ma_3;

            Date today = Date.today(); 
            LogiOpportunity = new Opportunity(
            Name = 'MySales12',
            CurrencyIsoCode='EUR',
            RecordTypeId = RT_OPPTY_LOGISTICS.Id,
            OpportunityCode__c='SDS-22131801',
            CloseDate = System.today() + 30,
            StageName= 'Z01',
            Amount = 78,
            AccountId = acc_1.id,
            cOriginAcc__c = acc_1.id,
            Type = '01',
            CspMspType__c = 'N/A',
            LBSExceptionType__c  = 	'11',
            LogisticsCustomerType__c = 'EXTAC',
            Opportunity_Logistics_CPReviewStatus_FIN__c = ''   
        );
        insert LogiOpportunity;
             OpAct = new Opportunity_Activity__c(
                WhatId__c = LogiOpportunity.Id,
                EndDate__c = System.today(),
                TransactionName__c = '2.4.5.'
            );
            insert OpAct;
            OpAct1 = new Opportunity_Activity__c(
                WhatId__c = LogiOpportunity.Id,
                EndDate__c = System.today(),
                TransactionName__c = '2.3.2.'
            );
            insert OpAct1;
            OpportunityActivityPanelController.ActivityItem oa = new OpportunityActivityPanelController.ActivityItem(ma_2,OpAct,today.addDays(1));
            
            oa.opptyId = LogiOpportunity.Id;
            oa.Index = 1;
            oa.isAccessible = true;
            OpportunityActivityPanelController.ActivityItem oa1 = new OpportunityActivityPanelController.ActivityItem(ma_3,OpAct1,today.addDays(1));

            oa1.opptyId = LogiOpportunity.Id;
            oa1.Index = 1;
            oa1.isAccessible = true;
            
            OpportunityActivityNewController.checkStatusActivity(JSON.serialize(oa));
                        OpportunityActivityNewController.checkStatusActivity(JSON.serialize(oa1));


           // Opportunity opp = OpportunityActivityNewController.checkStatusActivity(LogiOpportunity.ID);
            Test.stopTest();
        }        
    }
    
    //Added by Divyam Gupta - v 1.3
    @isTest
    private static void checkoppactlostResultrcd() {        
        System.runAs(user_sysAdmin){
            Test.startTest();
                  Opportunity_Activity__c  opptyAct_HQ_1 =new Opportunity_Activity__c(Transactionname__c = 'ZPZ1',
                                                  WhatId__c = oppty_HQ_1_HQ.Id ,
                                                  Status__c = 'In Progress');
            insert opptyAct_HQ_1;
             Master_LostType__c  MasterlostType1 = new Master_LostType__c(Code__c ='LOST_TYPE_5',
                                           Type_Eng__c  ='Prior Business (ISP/MP)',
                                           Order_Number__c= 5,
                                            Name = 'PRIOR_BIZ',
                                            Type_Kor__c ='선행사업 (ISP/MP)',
                                                Level1_Type_Kor__c ='영업',
                                                Level2_Type_Kor__c ='업종역량',
                                                 Level1_Type_Eng__c ='Sales',
                                                Level2_Type_Eng__c ='Industry Competency',
                                                    Lost_Drop_Type__c = 'Drop',
                                                Use__c=true
                                           );

        insert MasterlostType1;
        
      LostResult__c  lostresult1 = new LostResult__c(Opportunity__c =oppty_HQ_1_HQ.Id,LostActivity__c =opptyAct_HQ_1.Id,IsCheck__c = true,
                                      LostTypeCode__c = 'LOST_TYPE_7',
                                      Master_LostType__c    = MasterlostType1.Id,
                                      MasterLosttype_Eng__c = MasterlostType1.Type_Eng__c,
                                      MasterLosttype_Kor__c =MasterlostType1.Type_Kor__c,
                                      Rate__c = 100,
                                      ApproveStatus__c ='Completed'
                                     );
        insert lostresult1;
            
        Lost_Countermeasure__c lostcountrmsr = new Lost_Countermeasure__c(LostActivity__c=opptyAct_HQ_1.Id,
                                                   Master_Lost_Type_Code__c='LOST_TYPE_7',Opportunity__c=oppty_HQ_1_HQ.Id,Master_LostType__c=MasterlostType1.Id);
        insert lostcountrmsr;
            
            OpportunityActivityNewController.checkoppactlostResultrcd(oppty_HQ_1_HQ.Id,opptyAct_HQ_1.Id);
             OpportunityActivityNewController.delLostDropRecord(oppty_HQ_1_HQ.Id,'Z06');

            Test.stopTest();
        }        
    }

  //END 
}