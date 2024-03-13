/**
 * @description       : 
 * @author            : leehyo
 * @last modified on  : 2021-04-28
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   2021-01-06   leehyo   Initial Version
**/
@isTest
public class OpportunityActivityHelper_Test {
       
    static RecordType RT_OPPTY_LOGISTICS;
    static RecordType RT_OPPTY_HQ;
    static User salesRepHqUser1;
    static User salesRepLogiUser1;
    static Employee__c emp1;
    static Employee__c emp2;
    static Opportunity opptyHQ1;
    static Opportunity opptyLogi1;
    static Opportunity opptyLogi2;
    static Opportunity opptyLogi3;
    static Opportunity opptyLogi4;
    static Opportunity_Activity__c opptyAct; //Anish

    static Integer INDEX_BIDDING_LBS = 2;
    static Integer INDEX_FINAL_LBS = 3;
    static Integer INDEX_RATE_CHANGE_LBS = 4;
    
    static {
        // [Trigger Switch Setting ] Default Org Switch Setup
        TriggerSwitch__c trSwitch_default = new TriggerSwitch__c(
            All__c = true,
            Opportunity__c = true,
            OpportunityLogisticsValidation__c = false,  // Stage Validation 해제
            OpportunityActivity__c = true
        );
        insert trSwitch_default;
        
        RT_OPPTY_LOGISTICS  = OpportunityActivityHelper.RT_OPPTY_LOGISTICS;
        RT_OPPTY_HQ         = OpportunityActivityHelper.RT_OPPTY_HQ;
        

        // 임직원 및 User Setting
        emp1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'EPID1');
        salesRepHqUser1 = Utils_TestDataFactory.createUserFull(
                Utils_TestDataFactory.getProfile('Sales Rep.(HQ)')
                , emp1.EvMailAddr__c
                , emp1.EvUniqID__c);

        // 임직원 및 User Setting
        emp2 = Utils_TestDataFactory.createEmployee('TestEmp2', 'EPID2');
        salesRepLogiUser1 = Utils_TestDataFactory.createUserFull(
                Utils_TestDataFactory.getProfile('Sales Rep.(Logi)')
                , emp2.EvMailAddr__c
                , emp2.EvUniqID__c);

        
        Account acc = new Account(Name = 'accTest', MDGCheck__c = true);
        insert acc;

        // Masert Activity Setting
        MasterActivity__c mastrtAct1_HQ_ZPZ3 = new MasterActivity__c(TransactionName__c=OpportunityActivityHelper.ACT_CODE_AGENCY_CONTRACT_EXCEPTION
                                 , Stage__c='Z01',Order__c=1
                                 , IsRequiredKnoxApproval__c=false
                                 , Position__c='1',IsImportant__c=true,IsRequired__c=true
                                 , ObjectApiName__c='Opportunity',IsActive__c=true,Type__c='HQ');
        insert mastrtAct1_HQ_ZPZ3;

        MasterActivity__c mastrtAct1_Logi = new MasterActivity__c(TransactionName__c=Utils.getPicklistOptionType('MasterActivity__c','TransactionName__c')[0].get('value')
                                 , Stage__c='Z01',Order__c=1
                                 , IsRequiredKnoxApproval__c=false
                                 , Position__c='1',IsImportant__c=true,IsRequired__c=true
                                 , ObjectApiName__c='Opportunity',IsActive__c=true,Type__c='Logistics');

        MasterActivity__c mastrtAct2_Logi_Bidding_LBS = mastrtAct1_Logi.clone();
        mastrtAct2_Logi_Bidding_LBS.Order__c = INDEX_BIDDING_LBS;
        mastrtAct2_Logi_Bidding_LBS.TransactionName__c = OpportunityActivityHelper.ACT_CODE_BIDDING_LBS;
        
        MasterActivity__c mastrtAct3_Logi_Final_LBS = mastrtAct1_Logi.clone();
        mastrtAct3_Logi_Final_LBS.Order__c = INDEX_FINAL_LBS;
        mastrtAct3_Logi_Final_LBS.TransactionName__c=OpportunityActivityHelper.ACT_CODE_FINAL_LBS;
                        

        MasterActivity__c mastrtAct4_Logi_RateChange_LBS = mastrtAct1_Logi.clone();
        mastrtAct4_Logi_RateChange_LBS.Order__c = INDEX_RATE_CHANGE_LBS;
        mastrtAct4_Logi_RateChange_LBS.TransactionName__c=OpportunityActivityHelper.ACT_CODE_RATE_CHANGE_LBS;
                        
               
        insert mastrtAct1_Logi;
        insert mastrtAct2_Logi_Bidding_LBS;
        insert mastrtAct3_Logi_Final_LBS;
        insert mastrtAct4_Logi_RateChange_LBS;


        // Opportunity
        opptyLogi1 = new Opportunity(Name ='Test1' , RecordTypeId = RT_OPPTY_LOGISTICS.Id ,AccountId = acc.Id
                                , CloseDate =System.today() ,StageName = 'Z01');

        opptyLogi2 = new Opportunity(Name ='Test2' , RecordTypeId = RT_OPPTY_LOGISTICS.Id ,AccountId = acc.Id
                                , CloseDate =System.today() ,StageName = 'Z01');
                                
        opptyLogi3 = new Opportunity(Name ='Test3' , RecordTypeId = RT_OPPTY_LOGISTICS.Id ,AccountId = acc.Id
                                , CloseDate =System.today() ,StageName = 'Z01');

        opptyLogi4 = new Opportunity(Name ='Test4' , RecordTypeId = RT_OPPTY_LOGISTICS.Id ,AccountId = acc.Id
                                , CloseDate =System.today() ,StageName = 'Z01');

        opptyHQ1 = new Opportunity(Name ='opptyHQ1' , RecordTypeId = RT_OPPTY_HQ.Id ,AccountId = acc.Id
                                    , CloseDate =System.today() ,StageName = 'Z01');
        
        MasterActivityLogisticsAttribute__c rowMALA = new MasterActivityLogisticsAttribute__c();
        rowMALA.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'MasterActivityLogisticsAttribute__c' AND DeveloperName = 'Definition' LIMIT 1].Id;
        rowMALA.Attribute__c = 'Accessible';
        rowMALA.DefaultValue__c = 'FALSE';
        rowMALA.MasterActivity__c = mastrtAct2_Logi_Bidding_LBS.Id;
        rowMALA.FilterCriteria__c = '{"OriginObject":"Opportunity","Criterias":[{"No":"0","OriginField":"StageName","Operator":"=","AttributeField":"StageName__c"}],"Logic":"{0}","Output":"isAccessible__c"}';
        insert rowMALA;
    
    }

    @isTest
    private static void test_HQ_oppty1() {
        Test.startTest();
        System.runAs(salesRepHQUser1){
            
            insert opptyHQ1;

            Map<String,List<List<OpportunityActivityPanelController.ActivityItem>>> panelList = (Map<String,List<List<OpportunityActivityPanelController.ActivityItem>>>)OpportunityActivityPanelController.initComponent(opptyHQ1.Id, true).get('PanelList');
            

        }
        Test.StopTest();
    }

    @isTest
    private static void test_logistics_oppty1() {
        Test.startTest();
        System.runAs(salesRepLogiUser1){

            // VALIATED C1
            //opptyLogi1.StageName = OpportunityActivityHelper.OPP_STAGE_VALIDATED;
            opptyLogi1.StageName = 'Z01'; //Anish
            // C1
            opptyLogi1.LogisticsCustomerType__c = OpportunityActivityHelper.OPP_CUSTOMER_TYPE_EXTERNAL;
            opptyLogi1.Type = OpportunityActivityHelper.OPP_TYPE_NEW_OPPORTUNITY;
            opptyLogi1.LBSExceptionType__c = OpportunityActivityHelper.OPP_LBS_TYPE_NA;

            insert opptyLogi1;
            
            Map<String, Object> panelList = OpportunityActivityPanelController.initComponent(opptyLogi1.Id, true);
             //List<OpportunityActivityPanelController.ActivityItem> actList = panelList.get('1').get(0); // 첫번째 열
             //OpportunityActivityPanelController.ActivityItem ACTITEM_BIDDING_LBS     = actList[INDEX_BIDDING_LBS-1];   // order
            // OpportunityActivityPanelController.ActivityItem ACTITEM_FINAL_LBS       = actList[INDEX_FINAL_LBS-1];   // order
            // OpportunityActivityPanelController.ActivityItem ACTITEM_RATE_CHANGE_LBS = actList[INDEX_RATE_CHANGE_LBS-1];   // order
            
            // OpportunityActivityHelper.checkAccessLogisticsActivity(opptyLogi, ACTITEM_FINAL_LBS);
            // OpportunityActivityHelper.checkAccessLogisticsActivity(opptyLogi, ACTITEM_RATE_CHANGE_LBS);


            // // C3
            // opptyLogi.LogisticsCustomerType__c = OpportunityActivityHelper.OPP_CUSTOMER_TYPE_EXTERNAL;
            // opptyLogi.Type = OpportunityActivityHelper.OPP_TYPE_NEW_OPPORTUNITY;
            // opptyLogi.LBSExceptionType__c = OpportunityActivityHelper.OPP_LBS_TYPE_MEDIUM;

            // OpportunityActivityHelper.checkAccessLogisticsActivity(opptyLogi, ACTITEM_FINAL_LBS);

        }
        Test.stopTest();
    }

    @isTest
    private static void test_logistics_oppty2() {
        Test.startTest();
        System.runAs(salesRepLogiUser1){

            // VALIATED C1
            //opptyLogi2.StageName = OpportunityActivityHelper.OPP_STAGE_QUALIFIED;
            opptyLogi2.StageName = 'Z01'; //Anish
            // C1
            opptyLogi2.LogisticsCustomerType__c = OpportunityActivityHelper.OPP_CUSTOMER_TYPE_SEC_SET;
            opptyLogi2.Type = OpportunityActivityHelper.OPP_TYPE_NEW_OPPORTUNITY;
            opptyLogi2.LBSExceptionType__c = OpportunityActivityHelper.OPP_LBS_TYPE_SMALL;
            insert opptyLogi2;
            
            Map<String, Object> panelList = OpportunityActivityPanelController.initComponent(opptyLogi2.Id, true);
        }
        Test.stopTest();
    }

    @isTest
    private static void test_logistics_oppty3() {
        Test.startTest();
        System.runAs(salesRepLogiUser1){

            // VALIATED C1
            //opptyLogi3.StageName = OpportunityActivityHelper.OPP_STAGE_DROP;
            opptyLogi3.StageName = 'Z01'; //Anish
            // C1
            opptyLogi3.LogisticsCustomerType__c = OpportunityActivityHelper.OPP_CUSTOMER_TYPE_EXTERNAL;
            opptyLogi3.Type = OpportunityActivityHelper.OPP_TYPE_RETENTION;
            opptyLogi3.LBSExceptionType__c = OpportunityActivityHelper.OPP_LBS_TYPE_NA;
            insert opptyLogi3;
            
            Map<String, Object> panelList = OpportunityActivityPanelController.initComponent(opptyLogi3.Id, true);
        }
        Test.stopTest();
    }

    @isTest
    private static void test_logistics_oppty4() {
        Test.startTest();
        System.runAs(salesRepLogiUser1){

            // VALIATED C1
            //opptyLogi4.StageName = OpportunityActivityHelper.OPP_STAGE_VALIDATED;
            opptyLogi4.StageName = 'Z01'; //Anish
            // C1
            opptyLogi4.LogisticsCustomerType__c = OpportunityActivityHelper.OPP_CUSTOMER_TYPE_SEC_SET;
            opptyLogi4.Type = OpportunityActivityHelper.OPP_TYPE_RETENTION;
            opptyLogi4.LBSExceptionType__c = OpportunityActivityHelper.OPP_LBS_TYPE_SMALL;
            insert opptyLogi4;
            
            opptyAct = new Opportunity_Activity__c(WhatId__c = opptyLogi4.Id ); //Added by Anish
            insert opptyAct;
            
            Map<String, Object> panelList = OpportunityActivityPanelController.initComponent(opptyLogi4.Id, true);
            String str = OpportunityActivityHelper.generateOpportunityActivityExtKey(opptyAct); //Anish
        }
        Test.stopTest();
    }
    

}