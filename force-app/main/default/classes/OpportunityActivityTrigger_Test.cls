/**
 * @description       : 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2023-05-12
 * @last modified by  : divyam.gupta@samsung.com
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2020-12-01   hj.lee@dkbmc.com   Initial Version
 * 1.1   2023-01-20   anish.jain@partner.samsung.com Coverage for Lost/Drop condition [My Sales-177]
 * 1.2   2023-05-12   divyam.gupta@samsung.com  Coverage for Lost Enhancement condition [My Saels-177]
**/
@isTest
public with sharing class OpportunityActivityTrigger_Test {

    static {
        // [Trigger Switch Setting ] Default Org Switch Setup
        TriggerSwitch__c trSwitch_default = new TriggerSwitch__c(
            All__c = true,
            Opportunity__c = false, //Added by Anish - v 1.1
            OpportunityActivity__c = true
        );
        insert trSwitch_default;


        RecordType HQ_RT = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];

        Account accAct = new Account(Name = 'accTest', MDGCheck__c = true);
        insert accAct;

        Opportunity hqOppty = new Opportunity(Name ='Test' , RecordTypeId = HQ_RT.Id ,AccountId =accAct.Id
                                             ,CloseDate =System.today() ,StageName = 'Z01');
        insert hqOppty;
        
        /**
         * Master Activity 
         */
        List<MasterActivity__c> insertMasterActivityList = new List<MasterActivity__c>();
        MasterActivity__c mastrtAct1 = new MasterActivity__c(
              Type__c='HQ'    
            , TransactionName__c='ZP21'
            , Stage__c='Z02'
            , Order__c=1
            , Position__c='1'
            , ObjectApiName__c='Opportunity'
            , IsActive__c=true
        );
        insertMasterActivityList.add(mastrtAct1);

        MasterActivity__c mastrtAct2 = new MasterActivity__c(
            Type__c='HQ'    
            , TransactionName__c='XP44'
            , Stage__c='Z04'
            , Order__c=1
            , Position__c='1'
            , ObjectApiName__c='Opportunity'
            , IsActive__c=true
        );
        insertMasterActivityList.add(mastrtAct2);

        MasterActivity__c mastrtAct3 = new MasterActivity__c(
            Type__c='HQ'    
            , TransactionName__c='XP57'
            , Stage__c='Z04'
            , Order__c=2
            , Position__c='1'
            , ObjectApiName__c='Opportunity'
            , IsActive__c=true
        );
        insertMasterActivityList.add(mastrtAct3);

        Opportunity_Activity__c opptyAct_ZP21 = new Opportunity_Activity__c(
            Status__c='Not Started'
            , DueDate__c=System.today()
            , WhatId__c=hqOppty.Id
            , TransactionName__c ='ZP21'
            , Index__c=2
            , Description__c = 'TEST, opptyAct_ZP21, DescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescription~~!!'
        );
        
        insert insertMasterActivityList;
        insert opptyAct_ZP21;
    }

    // @isTest static void testInsertOppty() {
    //     Test.startTest();
    //     List<Opportunity_Activity__c> updateOpptyActList = new List<Opportunity_Activity__c>();
    // 
    //     Opportunity oppty = [SELECT Id FROM Opportunity WHERE Name ='Test'];
    //     Opportunity_Activity__c opptyAct_ZP21 = [SELECT Id FROM Opportunity_Activity__c WHERE TransactionName__c ='ZP21'];
    // 
    //     /*== setAutoStage Test `==*/
    //     opptyAct_ZP21.Status__c = 'Completed';
    //     updateOpptyActList.add(opptyAct_ZP21);
    //     
    // 
    //     /*== deduplication Test ==*/
    //     Opportunity_Activity__c deduplication = new Opportunity_Activity__c( 
    //         Status__c='Not Started'
    //         , DueDate__c=System.today()
    //         , WhatId__c=oppty.Id
    //         , TransactionName__c ='XP44'
    //         , Index__c=2
    //         , Description__c = 'TEST, deduplication, DescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescription~~!!'
    //     );
    // 
    //     insert deduplication;
    //     
    //     Opportunity_Activity__c deduplicationAct = [SELECT Id FROM Opportunity_Activity__c WHERE TransactionName__c ='XP44'];
    // 
    //     Opportunity_Activity__c deduplicationTest = new  Opportunity_Activity__c(
    //         Id = deduplicationAct.Id,
    //         Status__c = 'Completed',
    //         Description__c = 'TEST, deduplicationTest, DescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescription~~!!'
    //     ); 
    // 
    //     updateOpptyActList.add(deduplicationTest);
    // 
    //     /*== setDropUpdate Test ==*/ 
    //     
    // 
    //     // Opportunity_Activity__c operDrop = [SELECT Id FROM Opportunity_Activity__c WHERE TransactionName__c ='ZPZ2'];
    // 
    //     // Opportunity_Activity__c operDropUpdate = new  Opportunity_Activity__c(
    //     //     Id = operDrop.Id,
    //     //     Status__c = 'Completed'); 
    // 
    //     // resultUpdate.add(operDropUpdate);
    // 
    //     update updateOpptyActList;
    // 
    //     
    //     List<Opportunity_Activity__c> insertActivityList = new List<Opportunity_Activity__c>();
    //     
    //     Opportunity_Activity__c opptyActDrop = new Opportunity_Activity__c( 
    //         Status__c='Not Started'
    //         , DueDate__c=System.today()
    //         , WhatId__c=oppty.Id
    //         , TransactionName__c ='ZPZ2'
    //         , LostType__c = OpportunityActivityHelper.OPP_STAGE_DROP
    //         , Index__c = 3
    //         , Description__c = 'TEST, opptyActDrop, DescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescription~~!!'
    //     );
    //     insertActivityList.add(opptyActDrop);
    //     
    // 
    //     Opportunity_Activity__c opptyActContractClosing = new Opportunity_Activity__c( 
    //         Status__c='Completed'
    //         , DueDate__c=System.today()
    //         , WhatId__c=oppty.Id
    //         , TransactionName__c ='XP57'
    //         , Description__c = 'TEST, opptyActContractClosing, DescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescription~~!!'
    //     );
    //     insertActivityList.add(opptyActContractClosing);
    // 
    //     insert insertActivityList;
    // 
    //     Opportunity checkOppty = [SELECT Id, StageName, ActivityStatus__c FROM Opportunity WHERE Name ='Test'];
    //     system.assertEquals('XP57', checkOppty.ActivityStatus__c);
    //     system.assertEquals('Z05', checkOppty.StageName);
    // 
    //  Test.stopTest();
    // }

    @isTest static void testChangeActivityLostType() {
        Test.startTest();

        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Name ='Test'];
        Opportunity_Activity__c opptyActDrop = new Opportunity_Activity__c( 
            Status__c='Not Started'
            , DueDate__c=System.today()
            , WhatId__c=oppty.Id
            , TransactionName__c ='ZPZ2'
            , LostType__c = OpportunityActivityHelper.OPP_STAGE_DROP
            , Index__c = 3
            , Description__c = 'TEST, deduplication, DescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescription~~!!'
        );
        
        insert opptyActDrop;

        KnoxApproval__c knoxApp = new KnoxApproval__c(
            Name = 'knox Approval',
            OpportunityActivity__c = opptyActDrop.Id,
            Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS
        );
        insert knoxApp;


        opptyActDrop.LostType__c = OpportunityActivityHelper.OPP_STAGE_LOST;
        try {
            update opptyActDrop;
        } catch(Exception e) {
            
        }


        Test.stopTest();
    }

    @isTest static void testInsertOppty_1() {
        Test.startTest();
        List<Opportunity_Activity__c> updateOpptyActList = new List<Opportunity_Activity__c>();

        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Name ='Test'];
        Opportunity_Activity__c opptyAct_ZP21 = [SELECT Id FROM Opportunity_Activity__c WHERE TransactionName__c ='ZP21'];

        /*== setAutoStage Test `==*/
       opptyAct_ZP21.Status__c = 'Completed';
        updateOpptyActList.add(opptyAct_ZP21);
        

        /*== deduplication Test ==*/
        Opportunity_Activity__c deduplication = new Opportunity_Activity__c( 
            Status__c='Not Started'
            , DueDate__c=System.today()
            , WhatId__c=oppty.Id
            , TransactionName__c ='XP44'
            , Index__c=2
            , Description__c = 'TEST, deduplication, DescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescription~~!!'
        );

        insert deduplication;

        Opportunity_Activity__c deduplicationAct = [SELECT Id FROM Opportunity_Activity__c WHERE TransactionName__c ='XP44'];

        Opportunity_Activity__c deduplicationTest = new  Opportunity_Activity__c(
            Id = deduplicationAct.Id,
            Status__c = 'Completed',
            Description__c = 'TEST, deduplicationTest, DescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescription~~!!'
        ); 

        updateOpptyActList.add(deduplicationTest);

        update updateOpptyActList;

        Test.stopTest();
    }

    @isTest static void testInsertOppty_2() {
        Test.startTest();
        
        List<Opportunity_Activity__c> insertActivityList = new List<Opportunity_Activity__c>();
        
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Name ='Test'];

        Opportunity_Activity__c opptyActDrop = new Opportunity_Activity__c( 
            Status__c='Not Started'
            , DueDate__c=System.today()
            , WhatId__c=oppty.Id
            , TransactionName__c ='ZPZ2'
            , LostType__c = OpportunityActivityHelper.OPP_STAGE_DROP
            , Index__c = 3
            , Description__c = 'TEST, opptyActDrop, DescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescription~~!!'
        );
        insertActivityList.add(opptyActDrop);        

        Opportunity_Activity__c opptyActContractClosing = new Opportunity_Activity__c( 
            Status__c='Completed'
            , DueDate__c=System.today()
            , WhatId__c=oppty.Id
            , TransactionName__c ='XP57'
            , Description__c = 'TEST, opptyActContractClosing, DescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescription~~!!'
        );
        insertActivityList.add(opptyActContractClosing);

        insert insertActivityList;

        Test.stopTest();
    }
    
    //Added by Anish - v 1.1
     @isTest static void testInsertOppty_3() {
        Test.startTest();
        
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Name ='Test'];

        Opportunity_Activity__c opptyActDrop = new Opportunity_Activity__c( 
            Status__c='Not Started'
            , DueDate__c=System.today()
            , WhatId__c=oppty.Id
            , TransactionName__c ='ZPZ1'
            , LostType__c = OpportunityActivityHelper.OPP_STAGE_LOST
            , Index__c = 3
            , Description__c = 'TEST, opptyActDrop, DescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescription~~!!'
        );
        
        insert opptyActDrop;
        Test.stopTest();
    }
    
        //Added by Divyam Gupta - v 1.2
     @isTest static void testInsertOppty_4() {
        Test.startTest();
          RecordType rcdType_Oppty_HQ = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
       Company__c comp_SDS = new Company__c(
            Name = 'Samsung SDS',
            CompanyCode__c = 'T100',
            Country__c = 'KR',
            EPCompanyCode__c = 'C60'
        );
        insert comp_SDS;
        
                List<CostCenter__c> ccList = new List<CostCenter__c>();
        CostCenter__c cc_1 = new CostCenter__c(
            Name = 'Test Cost Center 1', 
            Company__c = comp_SDS.Id, 
            CompanyCode__c = 'T100', 
            CostCenter__c = 'T100-12345'
        );
        ccList.add(cc_1);
        insert ccList;
             List<Opportunity> insert_OpptyList = new List<Opportunity>();
        Opportunity oppty_HQ_1_HQ = new Opportunity(
            Name = 'Test Opportunity 1 HQ',
            RecordTypeId = rcdType_Oppty_HQ.Id,
            CurrencyIsoCode = 'USD', 
            Amount = 5000000, 
            CloseDate = Date.today(), 
            StageName = 'Z01',
            BusinessType__c = 'TI',
           cPrimarySalesDepartment__c = cc_1.Id,
            SalesDepartment__c = cc_1.Id,
            XP63_VRB_APPROVAL_TYPE__c = '10',
            XP73_VRB_APPROVAL_TYPE__c = '10'
            
        );
        insert_OpptyList.add(oppty_HQ_1_HQ);
        insert insert_OpptyList;


        Opportunity_Activity__c opptyActLost = new Opportunity_Activity__c( 
            Status__c='Not Started'
            , DueDate__c=System.today()
            , WhatId__c=oppty_HQ_1_HQ.Id
            , TransactionName__c ='ZPZ1' );
           
        insert opptyActLost;
         
             Master_LostType__c  MasterlostType1 = new Master_LostType__c(Code__c ='LOST_TYPE_5',
                                           Type_Eng__c  ='Prior Business (ISP/MP)',
                                           Order_Number__c= 5,
                                            Name = 'PRIOR_BIZ',
                                            Type_Kor__c ='선행사업 (ISP/MP)',
                                                Level1_Type_Kor__c ='영업',
                                                Level2_Type_Kor__c ='업종역량',
                                                 Level1_Type_Eng__c ='Sales',
                                                Level2_Type_Eng__c ='Industry Competency',
                                                Use__c=true);

        insert MasterlostType1;
        
      LostResult__c  lostresult1 = new LostResult__c(Opportunity__c =oppty_HQ_1_HQ.Id,LostActivity__c =opptyActLost.Id,IsCheck__c = true,
                                      LostTypeCode__c = 'LOST_TYPE_7',
                                      Master_LostType__c    = MasterlostType1.Id,
                                      MasterLosttype_Eng__c = MasterlostType1.Type_Eng__c,
                                      MasterLosttype_Kor__c =MasterlostType1.Type_Kor__c,
                                      Rate__c = 100,
                                      ApproveStatus__c ='Completed'
                                      );
        insert lostresult1;
         opptyActLost.Status__c ='In Progress';
         update opptyActLost;
         opptyActLost.Status__c ='Completed';
         update opptyActLost;
            opptyActLost.Status__c ='Rejected';
         update opptyActLost;
         opptyActLost.Status__c ='Not Started';
         update opptyActLost;
        Test.stopTest();
    }
}