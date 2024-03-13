/**
@author            : divyam.gupta@samsung.com
  @description       : Warning if Close Date is later than Contract Start Date. 
  @last modified on  : 09-18-2023
  @last modified by  : divyam.gupta@samsung.com
  Modifications Log 
  Ver   Date         Author                     Modification
  1.0   2023-09-18   Divyam.gupta@samsung.com       Initial Version
 **/
@isTest
public class opportunityCheckCloseDateContTest {
      static RecordType rcdType_Oppty_HQ;
        static RecordType rcdType_Acc_MDG;

    static Employee__c emp_0;
    static User user_sysAdmin;
    static Account acc_1;
    static MasterActivity__c ma_1;
    static Company__c comp_SDS;
    static Company__c comp_SDSAP;
    static CostCenter__c cc_1;
    static CostCenter__c cc_2;
    static Opportunity oppty_HQ_1_HQ;
    static Opportunity_Activity__c opptyAct_HQ_1; 
    static Opportunity_Activity__c opptyAct_HQ_2; 
    static Master_LostType__c MasterlostType;
     static Master_LostType__c MasterlostType1;
     static String costcentreid;
    static LostResult__c lostresult1;
    static Lost_Countermeasure__c lostcountrmsr;
        
    static {
    emp_0 = Utils_TestDataFactory.createEmployee('TestEmp0', 'EPID0');
               user_sysAdmin = Utils_TestDataFactory.createUserFull(
                            Utils_TestDataFactory.getProfile('System Administrator')
                            , emp_0.EvMailAddr__c
                            , emp_0.EvUniqID__c
                        );
         rcdType_Oppty_HQ = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
         rcdType_Acc_MDG = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'MDG' Limit 1];



    List<Company__c> compList = new List<Company__c>();
    comp_SDS = new Company__c(
            Name = 'Samsung SDS',
            CompanyCode__c = 'T100',
            Country__c = 'KR',
            EPCompanyCode__c = 'C60'
        );
        compList.add(comp_SDS);
        insert compList;
        
          acc_1 = new Account(
            Name = 'Test Account 1',
            RecordTypeId = rcdType_Acc_MDG.Id,
            MDGCheck__c = true
        );
        insert acc_1;
                List<CostCenter__c> ccList = new List<CostCenter__c>();
        cc_1 = new CostCenter__c(
            Name = 'Test Cost Center 1', 
            Company__c = comp_SDS.Id, 
            CompanyCode__c = 'T100', 
            CostCenter__c = 'T100-12345'
        );
        ccList.add(cc_1);
        insert ccList;
       costcentreid = cc_1.Id;
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
            Check_Close_Date__c = false,
           cRevenueStartDate__c = Date.today()-4
            
        );
        insert_OpptyList.add(oppty_HQ_1_HQ);
        insert insert_OpptyList;
    
}
      @isTest
        public  static void test1() { 
        System.runAs(user_sysAdmin){
            Test.startTest();
            opportunityCheckCloseDateCont.getCloseDatevaluecheck(oppty_HQ_1_HQ.Id);
            Test.stopTest();
        }
        }
}