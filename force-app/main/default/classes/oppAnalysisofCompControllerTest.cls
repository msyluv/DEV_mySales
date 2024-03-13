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
public class oppAnalysisofCompControllerTest {
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
        insert compList;
        compList.add(comp_SDS);
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
            XP63_VRB_APPROVAL_TYPE__c = '10',
            XP73_VRB_APPROVAL_TYPE__c = '10'
            
        );
        insert_OpptyList.add(oppty_HQ_1_HQ);
        insert insert_OpptyList;
           opptyAct_HQ_1 =new Opportunity_Activity__c(Transactionname__c = 'ZPZ1',
                                                  WhatId__c = oppty_HQ_1_HQ.Id ,
                                                  Status__c = 'In Progress',
                                                     LostType__c = 'Z06');
            insert opptyAct_HQ_1;
        opptyAct_HQ_2 =new Opportunity_Activity__c(Transactionname__c = 'ZPZ1',
                                                  WhatId__c = oppty_HQ_1_HQ.Id ,
                                                  Status__c = 'Completed'
                                                     );
            insert opptyAct_HQ_2;
        List<Master_LostType__c> mstlosttypelist = new  List<Master_LostType__c>();
        MasterlostType = new Master_LostType__c(Code__c ='LOST_TYPE_7',
                                           Type_Eng__c	='Bid Price',
                                           Order_Number__c= 7,
                                            Name = 'BID_PRICE',
                                            Type_Kor__c ='입찰가',
                                                Level1_Type_Kor__c ='영업',
                                                Level2_Type_Kor__c ='가격',
                                                 Level1_Type_Eng__c ='Sales',
                                                Level2_Type_Eng__c ='Price',
                                                Use__c=true,
                                                Lost_Drop_Type__c = 'Lost'
                                           );
           mstlosttypelist.add(MasterlostType);
                MasterlostType1 = new Master_LostType__c(Code__c ='LOST_TYPE_5',
                                           Type_Eng__c	='Prior Business (ISP/MP)',
                                           Order_Number__c= 5,
                                            Name = 'PRIOR_BIZ',
                                            Type_Kor__c ='선행사업 (ISP/MP)',
                                                Level1_Type_Kor__c ='영업',
                                                Level2_Type_Kor__c ='업종역량',
                                                 Level1_Type_Eng__c ='Sales',
                                                Level2_Type_Eng__c ='Industry Competency',
                                                Use__c=true,
                                                Lost_Drop_Type__c = 'Lost'
                                           );
                   mstlosttypelist.add(MasterlostType1);

        insert mstlosttypelist;
        
        lostresult1 = new LostResult__c(Opportunity__c =oppty_HQ_1_HQ.Id,LostActivity__c =opptyAct_HQ_1.Id,IsCheck__c = true,
                                      LostTypeCode__c = 'LOST_TYPE_7',
                                      Master_LostType__c	= MasterlostType.Id,
                                      MasterLosttype_Eng__c = MasterlostType.Type_Eng__c,
                                      MasterLosttype_Kor__c	=MasterlostType.Type_Kor__c,
                                      Rate__c = 100,
                                      ApproveStatus__c ='Completed' );
        insert lostresult1;
        
        lostcountrmsr = new Lost_Countermeasure__c(LostActivity__c=opptyAct_HQ_1.Id,
                                                   Master_Lost_Type_Code__c='LOST_TYPE_7',Opportunity__c=oppty_HQ_1_HQ.Id,Master_LostType__c=MasterlostType.Id);
        insert lostcountrmsr;

         
    }
        @isTest
        public  static void test1() { 
        System.runAs(user_sysAdmin){
            Test.startTest();
            oppAnalysisCompController.getOppActivitystatus(opptyAct_HQ_1.Id);
             oppAnalysisCompController.getLosttype1(oppty_HQ_1_HQ.Id,false,opptyAct_HQ_1.Id);
               oppAnalysisCompController.getLosttype(oppty_HQ_1_HQ.Id,false,opptyAct_HQ_1.Id);
               oppAnalysisCompController.getLosttype2(oppty_HQ_1_HQ.Id,MasterlostType.Level1_Type_Eng__c,false,MasterlostType.Lost_Drop_Type__c);
               oppAnalysisCompController.getLosttype3(oppty_HQ_1_HQ.Id,MasterlostType.Level2_Type_Eng__c,false,MasterlostType.Lost_Drop_Type__c);
               oppAnalysisCompController.getLostResultRec(oppty_HQ_1_HQ.Id,false,MasterlostType.Lost_Drop_Type__c,opptyAct_HQ_1.Id);
              oppAnalysisCompController.getLostResultRec(oppty_HQ_1_HQ.Id,true,MasterlostType.Lost_Drop_Type__c,opptyAct_HQ_1.Id);
               oppAnalysisCompController.getcounterMeasure(oppty_HQ_1_HQ.Id,false,opptyAct_HQ_1.Id);
               oppAnalysisCompController.getcounterMeasure(oppty_HQ_1_HQ.Id,true,opptyAct_HQ_1.Id);
            //Kajal changes
            oppAnalysisCompController.getLosttype1(oppty_HQ_1_HQ.Id,true,opptyAct_HQ_1.Id);
               oppAnalysisCompController.getLosttype(oppty_HQ_1_HQ.Id,true,opptyAct_HQ_1.Id);
               oppAnalysisCompController.getLosttype2(oppty_HQ_1_HQ.Id,MasterlostType.Level1_Type_Eng__c,true,MasterlostType.Lost_Drop_Type__c);
             oppAnalysisCompController.getLosttype3(oppty_HQ_1_HQ.Id,MasterlostType.Level2_Type_Eng__c,true,MasterlostType.Lost_Drop_Type__c);
               oppAnalysisCompController.getLostResultRec(oppty_HQ_1_HQ.Id,true,MasterlostType.Lost_Drop_Type__c,opptyAct_HQ_1.Id);
              oppAnalysisCompController.getLostResultRec(oppty_HQ_1_HQ.Id,false,MasterlostType.Lost_Drop_Type__c,opptyAct_HQ_1.Id);
               oppAnalysisCompController.getcounterMeasure(oppty_HQ_1_HQ.Id,true,opptyAct_HQ_1.Id);
               oppAnalysisCompController.getcounterMeasure(oppty_HQ_1_HQ.Id,false,opptyAct_HQ_1.Id);
           // string Apporvestatus;
            //List<Object> sobj= new List<Object>{Apporvestatus ='Completed'};
               String allInput= '[{"Apporvestatus":"Completed","Checked":true,"indexval":1,"lvl1Record":"Sales","lvl2Record":"Price","lvl3Record":"Bid Price","precompval":"test2","ratepercent":100,"rsltaftrbidval":"trrd","isChecked":true,"isdeleted":false}]';
               String allInputTest= '[{"Apporvestatus":"Completed","Checked":true,"indexval":1,"lvl1Record":"Sales","lvl2Record":"Price","lvl3Record":"Bid Price","precompval":"test2","ratepercent":100,"rsltaftrbidval":"trrd","isChecked":true,"isdeleted":false}]';

              oppAnalysisCompController.insertLostresult(allInput,oppty_HQ_1_HQ.Id,opptyAct_HQ_1.Id,false,'Lost');
              String allInput11= '[{"Apporvestatus":"Completed","Checked":true,"indexval":1,"lvl1Record":"Sales","lvl2Record":"Industry Competency","lvl3Record":"Prior Business (ISP/MP)","precompval":"test2","ratepercent":100,"rsltaftrbidval":"trrd","isChecked":true,"isdeleted":false}]';	
              oppAnalysisCompController.insertLostresult(allInput11,oppty_HQ_1_HQ.Id,opptyAct_HQ_1.Id,false,'Lost');
                          String allInput12= '[{"Apporvestatus":"Completed","Checked":true,"indexval":1,"lvl1Record":"영업","lvl2Record":"업종역량","lvl3Record":"선행사업 (ISP/MP)","precompval":"test2","ratepercent":100,"rsltaftrbidval":"trrd","isChecked":true,"isdeleted":false}]';	

                          oppAnalysisCompController.insertLostresult(allInput12,oppty_HQ_1_HQ.Id,opptyAct_HQ_1.Id,true,'Lost');

             String allInput1 ='[{"Checked":true,"detailResn":"ddd","imprvResn":"gg","lostactnList":[{"Countermeasure__c":"","ActionItem_InChargeDept__c":"","ActionItem_RelavantDept__c":"","ActionItem__c":"test","Name":"ActionItem0","actionItemdisable":false,"deptdisable":false,"relevdeptdisable":false,"variant":"error"}],"lvl1Record":"Sales","lvl2Record":"Price","lvl3Record":"Bid Price","isChecked":true}]';
              oppAnalysisCompController.insertCounterMeasure(allInput1,oppty_HQ_1_HQ.Id,opptyAct_HQ_1.Id,false,'Lost');
              String allInput2 ='[{"Checked":true,"detailResn":"ddd","imprvResn":"gg","cId":"","lostactnList":[{"Countermeasure__c":"","ActionItem_InChargeDept__c":"","ActionItem_RelavantDept__c":"","ActionItem__c":"test","Name":"ActionItem0","actionItemdisable":false,"deptdisable":false,"relevdeptdisable":false,"variant":"error"}],"lvl1Record":"Sales","lvl2Record":"Industry Competency","lvl3Record":"Prior Business (ISP/MP)","isChecked":true}]';
              oppAnalysisCompController.insertCounterMeasure(allInput2,oppty_HQ_1_HQ.Id,opptyAct_HQ_1.Id,false,'Lost');   
              String allInput3 ='[{"Checked":true,"detailResn":"ddd","imprvResn":"gg","lostactnList":[{"Countermeasure__c":"","ActionItem_InChargeDept__c":"","ActionItem_RelavantDept__c":"","ActionItem__c":"test","Name":"ActionItem0","actionItemdisable":false,"deptdisable":false,"relevdeptdisable":false,"variant":"error"}],"lvl1Record":"영업","lvl2Record":"업종역량","lvl3Record":"선행사업 (ISP/MP)","isChecked":true}]';
              oppAnalysisCompController.insertCounterMeasure(allInput3,oppty_HQ_1_HQ.Id,opptyAct_HQ_1.Id,true,'Lost');           

              // oppAnalysisCompController.insertLostresult(opptyAct_HQ_1.Id,false);
            //   oppAnalysisCompController.getLostResultRec(opptyAct_HQ_1.Id,false);

            //kajal Changes
          //oppAnalysisCompController.insertLostresult(allInputTest,oppty_HQ_1_HQ.Id,opptyAct_HQ_2.Id,true,'Lost');
          //oppAnalysisCompController.insertLostresult(allInput12,oppty_HQ_1_HQ.Id,opptyAct_HQ_2.Id,false,'Drop');
          //oppAnalysisCompController.insertCounterMeasure(allInput1,oppty_HQ_1_HQ.Id,opptyAct_HQ_2.Id,true,'Drop');
          //oppAnalysisCompController.insertCounterMeasure(allInput2,oppty_HQ_1_HQ.Id,opptyAct_HQ_2.Id,true,'Drop');   
          //oppAnalysisCompController.insertCounterMeasure(allInput3,oppty_HQ_1_HQ.Id,opptyAct_HQ_2.Id,false,'Drop');           

            Test.stopTest();
        }        
    }
        
     
}