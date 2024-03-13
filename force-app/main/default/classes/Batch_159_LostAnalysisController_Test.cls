/**
* @description       : Batch run to send IF-159
* @author            : anish.jain@partner.samsung.com
* @group             : 
* @last modified on  : 2023-12-10
* @last modified by  : anish.jain@partner.samsung.com 
* Modifications Log 
* Ver   Date         Author                      Modification
* 1.0   2023-12-10   anish.jain@partner.samsung.com   Initial Version (MS-373) Part of Epic MS-216
**/

@isTest
public class Batch_159_LostAnalysisController_Test {
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
    static Set<Id> sSet = new Set<Id>();
    static Opportunity oppty_HQ_1_HQ;
    static Opportunity_Activity__c opptyAct_HQ_1; 
    static KnoxApproval__c kAppr;
    static Master_LostType__c MasterlostType;
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
            XP73_VRB_APPROVAL_TYPE__c = '10',
            OpportunityCode__c = 'SDS-23000101',
            cPrimarySalesDepartment__c = cc_1.id

        );
        insert_OpptyList.add(oppty_HQ_1_HQ);
        insert insert_OpptyList;
        for(Opportunity opp : insert_OpptyList){
        sSet.add(opp.Id);
        }
           opptyAct_HQ_1 =new Opportunity_Activity__c(Transactionname__c = 'ZPZ1',
                                                  WhatId__c = oppty_HQ_1_HQ.Id ,
                                                      
                                                      EndDate__c =System.today() + 30
                                                  );
            insert opptyAct_HQ_1;
        
        kAppr = new KnoxApproval__c(OpportunityActivity__c = opptyAct_HQ_1.Id,
                                    Opportunity__c = oppty_HQ_1_HQ.Id,
                                    Status__c = '2'
         );
        insert kAppr;
        
        MasterlostType = new Master_LostType__c(Code__c ='LOST_TYPE_7',
                                           Type_Eng__c	='Bid Price',
                                           Order_Number__c= 7,
                                            Name = 'BID_PRICE',
                                            Type_Kor__c ='입찰가',
                                                Level1_Type_Kor__c ='영업',
                                                Level2_Type_Kor__c ='가격',
                                                 Level1_Type_Eng__c ='Sales',
                                                Level2_Type_Eng__c ='Price',
                                                Use__c=true
                                           );
        insert MasterlostType;
        
        lostresult1 = new LostResult__c(Opportunity__c =oppty_HQ_1_HQ.Id,LostActivity__c =opptyAct_HQ_1.Id,IsCheck__c = true,
                                      LostTypeCode__c = 'LOST_TYPE_7',
                                      Master_LostType__c	= MasterlostType.Id,
                                      MasterLosttype_Eng__c = MasterlostType.Type_Eng__c,
                                      MasterLosttype_Kor__c	=MasterlostType.Type_Kor__c,
                                      Rate__c = 100,
                                      ApproveStatus__c ='Completed'
                                      );
        insert lostresult1;
        
        lostcountrmsr = new Lost_Countermeasure__c(LostActivity__c=opptyAct_HQ_1.Id,
                                                   Master_Lost_Type_Code__c='LOST_TYPE_7',Opportunity__c=oppty_HQ_1_HQ.Id);
        insert lostcountrmsr;

        
    }
    
    @isTest
    static void restServiceCatchTest() {
       Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());

        Database.executeBatch(new Batch_159_LostAnalysisController(), 5);

        Test.stopTest();
    }

}