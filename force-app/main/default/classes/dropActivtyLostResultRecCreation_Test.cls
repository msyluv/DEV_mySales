/**
* @description       : Test class for dropActivtyLostResultRecCreation.
* @author            : divyam.gupta@samsung.com
* @group             : 
* @last modified on  : 2023-09-20
* @last modified by  : divyam.gupta@samsung.com
* Modifications Log 
* Ver   Date         Author                      Modification
* 1.0   2023-09-20   divyam.gupta@samsung.com   Initial Version
**/
@isTest
public class dropActivtyLostResultRecCreation_Test {
    
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
            Check_Close_Date__c = false
        );
        insert_OpptyList.add(oppty_HQ_1_HQ);
        insert insert_OpptyList;
        
        opptyAct_HQ_1 =new Opportunity_Activity__c(Transactionname__c = 'ZPZ2',
                                                  WhatId__c = oppty_HQ_1_HQ.Id ,
                                                  Status__c = 'Completed',
                                                     LostType__c = 'Z06');
            insert opptyAct_HQ_1;
        opptyAct_HQ_2 =new Opportunity_Activity__c(Transactionname__c = 'ZPZ2',
                                                  WhatId__c = oppty_HQ_1_HQ.Id ,
                                                  Status__c = 'Completed'
                                                     );
            insert opptyAct_HQ_2;
        MasterlostType = new Master_LostType__c(Code__c ='LOST_TYPE_15',
                                           Type_Eng__c  ='Cancellation/postponement of customer business',
                                           Order_Number__c= 7,
                                            Type_Kor__c ='고객 사업 취소/연기',
                                                Use__c=true,
                                                Lost_Drop_Type__c = 'Drop'
                                           );
           insert MasterlostType;
         lostresult1 = new LostResult__c(Opportunity__c =oppty_HQ_1_HQ.Id,LostActivity__c =opptyAct_HQ_2.Id,IsCheck__c = true,
                                      LostTypeCode__c = 'LOST_TYPE_7',
                                      Master_LostType__c    = MasterlostType.Id,
                                      MasterLosttype_Eng__c = MasterlostType.Type_Eng__c,
                                      MasterLosttype_Kor__c =MasterlostType.Type_Kor__c,
                                      Rate__c = 100,
                                      ApproveStatus__c ='Completed' );
        insert lostresult1;
    
}
      @isTest
        public  static void test1() { 
        System.runAs(user_sysAdmin){
            Test.startTest();
            List<Opportunity_Activity__c> oppactList = new List<Opportunity_Activity__c>();
            oppactList.add(opptyAct_HQ_2);
            Map<Id,Opportunity_Activity__c> mapoppact = new  Map<Id,Opportunity_Activity__c>();
            mapoppact.put(opptyAct_HQ_1.Id,opptyAct_HQ_1);
            dropActivtyLostResultRecCreation.addLostResultforDrop(oppactList,mapoppact);
            Test.stopTest();
        }
        }

    
    
}