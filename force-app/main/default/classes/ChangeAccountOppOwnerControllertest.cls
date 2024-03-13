/**
* @description       : ChangeAccountOppOwnerController Test
* @author            : Divyam.gupta@samsung.com
* @group             : 
* @last modified on  : 2022-09-06
* @last modified by  : Divyam.gupta@samsung.com
* Modifications Log 
* Ver   Date         Author                 Modification
* 1.0   2022-09-06   Divyam.gupta@samsung.com   Initial Version
**/
@isTest
public class ChangeAccountOppOwnerControllertest {
       static User u;
    
       static RecordType rcdType_Acc_MDG;
       static RecordType rcdType_Oppty_HQ;
       static User user_sysAdmin;
        static User user_sysAdmin1;
       static Account acc_1;
      static Company__c comp_SDS;
      static Company__c comp_SDSAP;
    static CostCenter__c cc_1;
    static CostCenter__c cc_2;
    static Opportunity oppty_HQ_1_HQ;
    static Opportunity oppty_HQ_1_1_HQ;
    static Opportunity oppty_HQ_2_Corp;
     static Opportunity oppty_HQ_2_HQ;
    static Opportunity_Activity__c opptyAct_Corp_1;
    static Opportunity_Activity__c opptyAct_HQ_2;
    static Opportunity_Activity__c opptyAct_HQ_3;
    static Employee__c emp_0;
     static Employee__c emp_1;


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
            Opportunity__c = true,
            OpportunityActivity__c = true
        );
        insert ts;

        rcdType_Acc_MDG = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'MDG' Limit 1];
        rcdType_Oppty_HQ = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
          emp_0 = Utils_TestDataFactory.createEmployee('TestEmp0', 'EPID0');
          emp_1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'EPID1');

     
          user_sysAdmin = Utils_TestDataFactory.createUserFull(
                            Utils_TestDataFactory.getProfile('System Administrator')
                            , emp_0.EvMailAddr__c
                            , emp_0.EvUniqID__c
                        );
           user_sysAdmin1 = Utils_TestDataFactory.createUserFull(
                            Utils_TestDataFactory.getProfile('System Administrator')
                            , emp_1.EvMailAddr__c
                            , emp_1.EvUniqID__c
                        );
            acc_1 = new Account(
            Name = 'Test Account 1',
            RecordTypeId = rcdType_Acc_MDG.Id,
            MDGCheck__c = true,
            AccountNumber = 'A2100002'
        );
        insert acc_1;
                    
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
             OpportunityCode__c = 'SDS-21999999'

            
        );
          insert_OpptyList.add(oppty_HQ_1_HQ);
           
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
         insert insert_OpptyList;
       }
           @isTest
           public static void getopportunitytest(){
               System.runAs(user_sysAdmin){
                   Test.startTest();
                   ChangeAccountOppOwnerController.getOppInfo(oppty_HQ_1_HQ.OpportunityCode__c);
                   ChangeAccountOppOwnerController.getOppInfo(oppty_HQ_2_HQ.OpportunityCode__c);
                   ChangeAccountOppOwnerController.getOppInfo('');
                   Test.stopTest();
                   
               }
           }

    
             @isTest
           public static void getAccounttest(){
               System.runAs(user_sysAdmin){
                   Test.startTest();
                   ChangeAccountOppOwnerController.getAccInfo(acc_1.AccountNumber);
                   ChangeAccountOppOwnerController.getAccInfo('');
                   ChangeAccountOppOwnerController.getAccInfo('A1224455');                                           
                   Test.stopTest();
                                                              }
               }
                                                              

    
            @isTest
           public static void updagteAccounttest(){
               System.runAs(user_sysAdmin){
                   Test.startTest();
                   ChangeAccountOppOwnerController.updateAcc('A2100002',user_sysAdmin1.Id);

                   Test.stopTest();
                   
               }
           }
    
            @isTest
           public static void updagteOpptest(){
               System.runAs(user_sysAdmin){
                   Test.startTest();
                   ChangeAccountOppOwnerController.updateOpp(oppty_HQ_1_HQ.OpportunityCode__c,user_sysAdmin1.Id,oppty_HQ_1_HQ.CompanyCode__c);
                   Test.stopTest();
                   
               }
           }
               
           }