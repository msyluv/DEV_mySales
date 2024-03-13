/**
 * @description       : Test class of Batch_WeeklySalesReport 
 * @author            : d.ashish@samsung.com
 * @group             : 
 * @last modified on  : 2023-07-26
 * @last modified by  : d.ashish@samsung.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2023-07-26   d.ashish@samsung.com   Initial Version
**/
@isTest (SeeAllData = false)
public class Batch_WeeklySalesReport_Ashish_Test {
    private static Boolean isSandbox = Utils.getIsSandbox();
    
    /*@isTest
    public static void testWeeklySales(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Rep.(HQ)' ];
        
        User u = new User(Alias = '박 재만', Email='Test@Test.com', 
                        EmailEncodingKey='UTF-8', LastName='박 재만', FirstName='박 재만', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                        UserName='user0001@samsung.com' ,IsActive = true);
	insert u;
	Batch_WeeklySalesReport_Ashish obj = new Batch_WeeklySalesReport_Ashish();
 obj.execute(null);
 }*/
     @isTest
    public static void testWeeklySalesBatch(){
          Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Rep.(HQ)' ];
        List<user> ulist = new List<user>();
        if(isSandbox) ulist = [ Select Id , name, Profile.Name,Email from User where  Profile.Name = 'Sales Rep.(HQ)'  AND IsActive = true ];
        else ulist = [ Select Id , name, Profile.Name,Email from User where Name = '박 재만' AND IsActive = true ];
        system.debug('ash ulist'+ulist);
        
        User u = new User(Alias = '박 재만', Email='Test@Test.com', 
                        EmailEncodingKey='UTF-8', LastName='박 재만', FirstName='박 재만', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                        UserName='user0001@samsung.com' ,IsActive = true);
	insert u;
       ulist[0].companycode__c = 'T100';
        update ulist;
       Id HQRecId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HQ').getRecordTypeId(); //Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('HQ').getRecordTypeId();
        
         Account acc = new Account( 
            Name = 'Test Account',
            MDGCheck__c = true,
             mDomesticForeign__c = '20'
        );
        insert acc;
  //      Id HQRecId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HQ').getRecordTypeId(); //Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('HQ').getRecordTypeId();
   DateTime dt = DateTime.now().addDays(-7);
        
        Organization__c org = new Organization__c(name='SDSAE');
        insert org;
        Opportunity opptyHQ1 = new Opportunity(
            Name = 'Test Opportunity',
    //        RecordTypeId = HQRecId,
           SalesOrganization__c = org.id,
           amount=1356,
            //ProposalPM_User__c = migUser.Id, //Anish v-1.2
            MigData__c = True,  //Anish v-1.2
            //StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today(),
            AccountId = acc.Id,
            cLeadID__c = NULL,
           ownerid = ulist[0].id,
           BO1stRegistrationDate__c = dt,
           StageName = 'Z05'
        );
        system.runAs(ulist[0]){
                   Company__c cmp = new Company__c(
            Name = 'comp',
            CompanyCode__c = 'T100'
        );
        insert cmp;
        Employee__c emp = new Employee__c(
            Name = 'testUser',
            EvMailAddr__c = 'SysAdminTestuser@samsung.com',
            EvUniqID__c = 'k123456789',
            Knox_Id__c = 'knoxId5',
            EvKostl__c = 'T604-11331'
        );
        insert emp;
       
       CostCenter__c costCenter1 = new CostCenter__c(
            Name                = '기술전략팀(T604-11331)'
            , DeptManager__c    = emp.Id
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T100'
            , CostCenterName__c = '기술전략팀'
            , Company__c = cmp.Id
            , CostCenter__c     = 'T604-11331'
            , Node1__c          = 'T604'
            , Node2__c          = 'T604SB'
            , Node3__c          = 'T604SB1'
            , Node4__c          = 'T604SB13'
            , Node5__c          = 'T604SB131'
            , ZZCheck__c = true
        );
        insert costCenter1; 
        opptyHQ1.RecordTypeId = HQRecId;
           opptyHQ1.SalesOrganization__c = org.id;
           opptyHQ1.amount=1356;
            opptyHQ1.SalesDepartment__c = costCenter1.Id;
            insert opptyHQ1;
        }
         List<Opportunity> lstOpp = new List<Opportunity>();
           lstOpp = [select Id, Amount,Name,OpportunityCode__c,ZP61_PROPOSAL_SUBMIT_DATE__c,ProposalPM__c,ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name,cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, StageName,BO1stRegistrationDate__c,CloseDate,XP7_CONDUCT_DATE__c,XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId,Account.Owner.Name,Account.Name,OriginAcc_BizTypeL1__c,BusinessLevel__c, RecordType.Name from opportunity where  OwnerId = : u.Id];
        system.debug('ashish lstOpp'+lstOpp);
        
       
	Batch_WeeklySalesReport_Ashish obj = new Batch_WeeklySalesReport_Ashish();
        database.executeBatch(obj);
 }
    
     @isTest
    public static void testWeeklySalesBatch1(){
          Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Rep.(HQ)' ];
        List<user> ulist = new List<user>();
        if(isSandbox) ulist = [ Select Id , name, Profile.Name,Email from User where  Profile.Name = 'Sales Rep.(HQ)'  AND IsActive = true ];
        else ulist = [ Select Id , name, Profile.Name,Email from User where Name = '박 재만' AND IsActive = true ];
        system.debug('ash ulist'+ulist);
        
        User u = new User(Alias = '박 재만', Email='Test@Test.com', 
                        EmailEncodingKey='UTF-8', LastName='박 재만', FirstName='박 재만', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                        UserName='user0001@samsung.com' ,IsActive = true);
	insert u;
       ulist[0].companycode__c = 'T100';
        update ulist;
       Id HQRecId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HQ').getRecordTypeId(); //Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('HQ').getRecordTypeId();
        
         Account acc = new Account( 
            Name = 'Test Account',
            MDGCheck__c = true,
             mDomesticForeign__c = '20'
        );
        insert acc;
  //      Id HQRecId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HQ').getRecordTypeId(); //Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('HQ').getRecordTypeId();
   DateTime dt = DateTime.now().addDays(-7);
        
        Organization__c org = new Organization__c(name='SDSAE');
        insert org;
       Opportunity opptyHQ = new Opportunity(
            Name = 'Test Opportunity',
    //        RecordTypeId = HQRecId,
           SalesOrganization__c = org.id,
           amount=1356,
            //ProposalPM_User__c = migUser.Id, //Anish v-1.2
            MigData__c = True,  //Anish v-1.2
            StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today(),
            AccountId = acc.Id,
            cLeadID__c = NULL,
           ownerid = ulist[0].id,
           BO1stRegistrationDate__c = dt
//           StageName = 'Z05'
        );
                 Opportunity opptyHQ2 = new Opportunity(
            Name = 'Test Opportunity',
    //        RecordTypeId = HQRecId,
           SalesOrganization__c = org.id,
           amount=1356,
            //ProposalPM_User__c = migUser.Id, //Anish v-1.2
            MigData__c = True,  //Anish v-1.2
            //StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today().adddays(-2),
            AccountId = acc.Id,
            cLeadID__c = NULL,
           ownerid = ulist[0].id,
           BO1stRegistrationDate__c = dt,
           StageName = 'Z03'
        );
        system.runAs(ulist[0]){
                       Company__c cmp = new Company__c(
            Name = 'comp',
            CompanyCode__c = 'T100'
        );
        insert cmp;
        Employee__c emp = new Employee__c(
            Name = 'testUser',
            EvMailAddr__c = 'SysAdminTestuser@samsung.com',
            EvUniqID__c = 'k123456789',
            Knox_Id__c = 'knoxId5',
            EvKostl__c = 'T604-11331'
        );
        insert emp;
       
       CostCenter__c costCenter1 = new CostCenter__c(
            Name                = '기술전략팀(T604-11331)'
            , DeptManager__c    = emp.Id
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T100'
            , CostCenterName__c = '기술전략팀'
            , Company__c = cmp.Id
            , CostCenter__c     = 'T604-11331'
            , Node1__c          = 'T604'
            , Node2__c          = 'T604SB'
            , Node3__c          = 'T604SB1'
            , Node4__c          = 'T604SB13'
            , Node5__c          = 'T604SB131'
            , ZZCheck__c = true
        );
        insert costCenter1; 
        opptyHQ.RecordTypeId = HQRecId;
           opptyHQ.SalesOrganization__c = org.id;
           opptyHQ.amount=1356;
            opptyHQ.SalesDepartment__c = costCenter1.Id;
        insert opptyHQ;
            insert opptyHQ2;
        }
         List<Opportunity> lstOpp = new List<Opportunity>();
           lstOpp = [select Id, Amount,Name,OpportunityCode__c,ZP61_PROPOSAL_SUBMIT_DATE__c,ProposalPM__c,ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name,cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, StageName,BO1stRegistrationDate__c,CloseDate,XP7_CONDUCT_DATE__c,XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId,Account.Owner.Name,Account.Name,OriginAcc_BizTypeL1__c,BusinessLevel__c, RecordType.Name from opportunity where  OwnerId = : u.Id];
        system.debug('ashish lstOpp'+lstOpp);
        
       
	Batch_WeeklySalesReport_Ashish obj = new Batch_WeeklySalesReport_Ashish();
        database.executeBatch(obj);
 }
    
     @isTest
    public static void testWeeklySalesBatch2(){
          Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Rep.(HQ)' ];
        List<user> ulist = new List<user>();
        if(isSandbox) ulist = [ Select Id , name, Profile.Name,Email from User where  Profile.Name = 'Sales Rep.(HQ)'  AND IsActive = true ];
        else ulist = [ Select Id , name, Profile.Name,Email from User where Name = '박 재만' AND IsActive = true ];
        system.debug('ash ulist'+ulist);
        
        User u = new User(Alias = '박 재만', Email='Test@Test.com', 
                        EmailEncodingKey='UTF-8', LastName='박 재만', FirstName='박 재만', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                        UserName='user0001@samsung.com' ,IsActive = true);
	insert u;
       ulist[0].companycode__c = 'T100';
        update ulist;
       Id HQRecId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HQ').getRecordTypeId(); //Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('HQ').getRecordTypeId();
        
         Account acc = new Account( 
            Name = 'Test Account',
            MDGCheck__c = true,
             mDomesticForeign__c = '20'
        );
        insert acc;
  //      Id HQRecId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HQ').getRecordTypeId(); //Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('HQ').getRecordTypeId();
   DateTime dt = DateTime.now().addDays(-7);
        
        Organization__c org = new Organization__c(name='SDSAE');
        insert org;
                Opportunity opptyHQ2 = new Opportunity(
            Name = 'Test Opportunity',
    //        RecordTypeId = HQRecId,
           SalesOrganization__c = org.id,
           amount=1356,
            //ProposalPM_User__c = migUser.Id, //Anish v-1.2
            MigData__c = True,  //Anish v-1.2
            //StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today().adddays(-2),
            AccountId = acc.Id,
            cLeadID__c = NULL,
           ownerid = ulist[0].id,
           StageName = 'Z03'
        );
        system.runAs(ulist[0]){
                   Company__c cmp = new Company__c(
            Name = 'comp',
            CompanyCode__c = 'T100'
        );
        insert cmp;
        Employee__c emp = new Employee__c(
            Name = 'testUser',
            EvMailAddr__c = 'SysAdminTestuser@samsung.com',
            EvUniqID__c = 'k123456789',
            Knox_Id__c = 'knoxId5',
            EvKostl__c = 'T604-11331'
        );
        insert emp;
       
       CostCenter__c costCenter1 = new CostCenter__c(
            Name                = '기술전략팀(T604-11331)'
            , DeptManager__c    = emp.Id
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T100'
            , CostCenterName__c = '기술전략팀'
            , Company__c = cmp.Id
            , CostCenter__c     = 'T604-11331'
            , Node1__c          = 'T604'
            , Node2__c          = 'T604SB'
            , Node3__c          = 'T604SB1'
            , Node4__c          = 'T604SB13'
            , Node5__c          = 'T604SB131'
            , ZZCheck__c = true
        );
        insert costCenter1; 
        opptyHQ2.RecordTypeId = HQRecId;
           opptyHQ2.SalesOrganization__c = org.id;
           opptyHQ2.amount=1356;
            opptyHQ2.SalesDepartment__c = costCenter1.Id;
            insert opptyHQ2;
        }
         List<Opportunity> lstOpp = new List<Opportunity>();
           lstOpp = [select Id, Amount,Name,OpportunityCode__c,ZP61_PROPOSAL_SUBMIT_DATE__c,ProposalPM__c,ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name,cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, StageName,BO1stRegistrationDate__c,CloseDate,XP7_CONDUCT_DATE__c,XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId,Account.Owner.Name,Account.Name,OriginAcc_BizTypeL1__c,BusinessLevel__c, RecordType.Name from opportunity where  OwnerId = : u.Id];
        system.debug('ashish lstOpp'+lstOpp);
        
       
	Batch_WeeklySalesReport_Ashish obj = new Batch_WeeklySalesReport_Ashish();
        database.executeBatch(obj);
 }
    
     @isTest
    public static void testWeeklySalesBatch3(){
          Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Rep.(HQ)' ];
        List<user> ulist = new List<user>();
        if(isSandbox) ulist = [ Select Id , name, Profile.Name,Email from User where  Profile.Name = 'Sales Rep.(HQ)'  AND IsActive = true ];
        else ulist = [ Select Id , name, Profile.Name,Email from User where Name = '박 재만' AND IsActive = true ];
        system.debug('ash ulist'+ulist);
        
        User u = new User(Alias = '박 재만', Email='Test@Test.com', 
                        EmailEncodingKey='UTF-8', LastName='박 재만', FirstName='박 재만', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                        UserName='user0001@samsung.com' ,IsActive = true);
	insert u;
       ulist[0].companycode__c = 'T100';
        update ulist;
       Id HQRecId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HQ').getRecordTypeId(); //Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('HQ').getRecordTypeId();
        
         Account acc = new Account( 
            Name = 'Test Account',
            MDGCheck__c = true,
             mDomesticForeign__c = '20'
        );
        insert acc;
   DateTime dt = DateTime.now().addDays(-7);
        
        Organization__c org = new Organization__c(name='SDSAE');
        insert org;
                Opportunity opptyHQ3 = new Opportunity(
            Name = 'Test Opportunity',
            RecordTypeId = HQRecId,
           SalesOrganization__c = org.id,
           amount=1356,
            //ProposalPM_User__c = migUser.Id, //Anish v-1.2
            MigData__c = True,  //Anish v-1.2
            //StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today().adddays(5),
            AccountId = acc.Id,
            cLeadID__c = NULL,
           ownerid = ulist[0].id,
           BO1stRegistrationDate__c = dt,
           StageName = 'Z03',
                    XP7_CONDUCT_DATE__c =Date.today().adddays(2),
                    XP6_CONDUCT_DATE__c=Date.today().adddays(2),
                    CMBizType__c = 'CSP_SCP',
                    CspMspType__c='CSP'
        );
        system.runAs(ulist[0]){
                   Company__c cmp = new Company__c(
            Name = 'comp',
            CompanyCode__c = 'T100'
        );
        insert cmp;
        Employee__c emp = new Employee__c(
            Name = 'testUser',
            EvMailAddr__c = 'SysAdminTestuser@samsung.com',
            EvUniqID__c = 'k123456789',
            Knox_Id__c = 'knoxId5',
            EvKostl__c = 'T604-11331'
        );
        insert emp;
       
       CostCenter__c costCenter1 = new CostCenter__c(
            Name                = '기술전략팀(T604-11331)'
            , DeptManager__c    = emp.Id
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T100'
            , CostCenterName__c = '기술전략팀'
            , Company__c = cmp.Id
            , CostCenter__c     = 'T604-11331'
            , Node1__c          = 'T604'
            , Node2__c          = 'T604SB'
            , Node3__c          = 'T604SB1'
            , Node4__c          = 'T604SB13'
            , Node5__c          = 'T604SB131'
            , ZZCheck__c = true
        );
        insert costCenter1; 
        opptyHQ3.RecordTypeId = HQRecId;
           opptyHQ3.SalesOrganization__c = org.id;
           opptyHQ3.amount=1356;
            opptyHQ3.SalesDepartment__c = costCenter1.Id;
            insert opptyHQ3;
        }
         List<Opportunity> lstOpp = new List<Opportunity>();
           lstOpp = [select Id, Amount,Name,OpportunityCode__c,ZP61_PROPOSAL_SUBMIT_DATE__c,ProposalPM__c,ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name,cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, StageName,BO1stRegistrationDate__c,CloseDate,XP7_CONDUCT_DATE__c,XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId,Account.Owner.Name,Account.Name,OriginAcc_BizTypeL1__c,BusinessLevel__c, RecordType.Name from opportunity where  OwnerId = : u.Id];
        system.debug('ashish lstOpp'+lstOpp);
        
       
	Batch_WeeklySalesReport_Ashish obj = new Batch_WeeklySalesReport_Ashish();
        database.executeBatch(obj);
 }
    @isTest
    public static void testWeeklySalesBatch4(){
          Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Rep.(HQ)' ];
        List<user> ulist = new List<user>();
        if(isSandbox) ulist = [ Select Id , name, Profile.Name,Email from User where  Profile.Name = 'Sales Rep.(HQ)'  AND IsActive = true ];
        else ulist = [ Select Id , name, Profile.Name,Email from User where Name = '박 재만' AND IsActive = true ];
        system.debug('ash ulist'+ulist);
        
        User u = new User(Alias = '박 재만', Email='Test@Test.com', 
                        EmailEncodingKey='UTF-8', LastName='박 재만', FirstName='박 재만', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                        UserName='user0001@samsung.com' ,IsActive = true);
	insert u;
       ulist[0].companycode__c = 'T100';
        update ulist;
       Id HQRecId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HQ').getRecordTypeId(); //Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('HQ').getRecordTypeId();
        
         Account acc = new Account( 
            Name = 'Test Account',
            MDGCheck__c = true,
             mDomesticForeign__c = '20'
        );
        insert acc;
   DateTime dt = DateTime.now().addDays(-7);
        
        Organization__c org = new Organization__c(name='SDSAE');
        insert org;
                Opportunity opptyHQ3 = new Opportunity(
            Name = 'Test Opportunity',
            RecordTypeId = HQRecId,
           SalesOrganization__c = org.id,
           amount=1356,
            //ProposalPM_User__c = migUser.Id, //Anish v-1.2
            MigData__c = True,  //Anish v-1.2
            //StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today().adddays(-5),
            AccountId = acc.Id,
            cLeadID__c = NULL,
           ownerid = ulist[0].id,
           BO1stRegistrationDate__c = dt,
           StageName = 'Z03',
                    XP7_CONDUCT_DATE__c =Date.today().adddays(2),
                    XP6_CONDUCT_DATE__c=Date.today().adddays(2)
             //       CMBizType__c = 'CSP_SCP'
        );
        system.runAs(ulist[0]){
                   Company__c cmp = new Company__c(
            Name = 'comp',
            CompanyCode__c = 'T100'
        );
        insert cmp;
        Employee__c emp = new Employee__c(
            Name = 'testUser',
            EvMailAddr__c = 'SysAdminTestuser@samsung.com',
            EvUniqID__c = 'k123456789',
            Knox_Id__c = 'knoxId5',
            EvKostl__c = 'T604-11331'
        );
        insert emp;
       
       CostCenter__c costCenter1 = new CostCenter__c(
            Name                = '기술전략팀(T604-11331)'
            , DeptManager__c    = emp.Id
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T100'
            , CostCenterName__c = '기술전략팀'
            , Company__c = cmp.Id
            , CostCenter__c     = 'T604-11331'
            , Node1__c          = 'T604'
            , Node2__c          = 'T604SB'
            , Node3__c          = 'T604SB1'
            , Node4__c          = 'T604SB13'
            , Node5__c          = 'T604SB131'
            , ZZCheck__c = true
        );
        insert costCenter1; 
        opptyHQ3.RecordTypeId = HQRecId;
           opptyHQ3.SalesOrganization__c = org.id;
           opptyHQ3.amount=1356;
            opptyHQ3.SalesDepartment__c = costCenter1.Id;
            insert opptyHQ3;
        }
         List<Opportunity> lstOpp = new List<Opportunity>();
           lstOpp = [select Id, Amount,Name,OpportunityCode__c,ZP61_PROPOSAL_SUBMIT_DATE__c,ProposalPM__c,ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name,cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, StageName,BO1stRegistrationDate__c,CloseDate,XP7_CONDUCT_DATE__c,XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId,Account.Owner.Name,Account.Name,OriginAcc_BizTypeL1__c,BusinessLevel__c, RecordType.Name from opportunity where  OwnerId = : u.Id];
        system.debug('ashish lstOpp'+lstOpp);
        
       
	Batch_WeeklySalesReport_Ashish obj = new Batch_WeeklySalesReport_Ashish();
        database.executeBatch(obj);
 }
@isTest
    public static void testWeeklySalesBatch5(){
          Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Rep.(HQ)' ];
       List<user> ulist = new List<user>();
        if(isSandbox) ulist = [ Select Id , name, Profile.Name,Email from User where  Profile.Name = 'Sales Rep.(HQ)'  AND IsActive = true ];
        else ulist = [ Select Id , name, Profile.Name,Email from User where Name = '박 재만' AND IsActive = true ];
         system.debug('ash ulist'+ulist);
        
        User u = new User(Alias = '박 재만', Email='Test@Test.com', 
                        EmailEncodingKey='UTF-8', LastName='박 재만', FirstName='박 재만', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                        UserName='user0001@samsung.com' ,IsActive = true);
	insert u;
       ulist[0].companycode__c = 'T100';
        update ulist;
       Id HQRecId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HQ').getRecordTypeId(); //Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('HQ').getRecordTypeId();
        
         Account acc = new Account( 
            Name = 'Test Account',
            MDGCheck__c = true,
             mDomesticForeign__c = '20'
        );
        insert acc;
  //      Id HQRecId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HQ').getRecordTypeId(); //Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('HQ').getRecordTypeId();
   DateTime dt = DateTime.now().addDays(-7);
        
        Organization__c org = new Organization__c(name='SDSAE');
        insert org;
                Opportunity opptyHQ2 = new Opportunity(
            Name = 'Test Opportunity',
    //        RecordTypeId = HQRecId,
           SalesOrganization__c = org.id,
           amount=1356,
            //ProposalPM_User__c = migUser.Id, //Anish v-1.2
            MigData__c = True,  //Anish v-1.2
            //StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today().adddays(2),
            AccountId = acc.Id,
            cLeadID__c = NULL,
           ownerid = ulist[0].id,
           StageName = 'Z05',
                               XP7_CONDUCT_DATE__c =Date.today().adddays(2),
                    XP6_CONDUCT_DATE__c=Date.today().adddays(2),
     		XP7_REQ_DATE__c = null,
                    XP6_REQ_DATE__c = null,
                    Opportunity_Review_VRB_Type_Confirm__c= '21',
                    Opportunity_Review_Confirm__c =true,
                    OpportunityStatus__c = 'E0002',
                    XP63_EndDate__c = Date.today().adddays(2)
        );
        system.runAs(ulist[0]){
                    Company__c cmp = new Company__c(
            Name = 'comp',
            CompanyCode__c = 'T100'
        );
        insert cmp;
        Employee__c emp = new Employee__c(
            Name = 'testUser',
            EvMailAddr__c = 'SysAdminTestuser@samsung.com',
            EvUniqID__c = 'k123456789',
            Knox_Id__c = 'knoxId5',
            EvKostl__c = 'T604-11331'
        );
        insert emp;
       
       CostCenter__c costCenter1 = new CostCenter__c(
            Name                = '기술전략팀(T604-11331)'
            , DeptManager__c    = emp.Id
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T100'
            , CostCenterName__c = '기술전략팀'
            , Company__c = cmp.Id
            , CostCenter__c     = 'T604-11331'
            , Node1__c          = 'T604'
            , Node2__c          = 'T604SB'
            , Node3__c          = 'T604SB1'
            , Node4__c          = 'T604SB13'
            , Node5__c          = 'T604SB131'
            , ZZCheck__c = true
        );
        insert costCenter1; 
        opptyHQ2.RecordTypeId = HQRecId;
           opptyHQ2.SalesOrganization__c = org.id;
           opptyHQ2.amount=1356;
            opptyHQ2.SalesDepartment__c = costCenter1.Id;
           insert opptyHQ2;
        }
         List<Opportunity> lstOpp = new List<Opportunity>();
           lstOpp = [select Id, Amount,Name,OpportunityCode__c,ZP61_PROPOSAL_SUBMIT_DATE__c,ProposalPM__c,ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name,cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, StageName,BO1stRegistrationDate__c,CloseDate,XP7_CONDUCT_DATE__c,XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId,Account.Owner.Name,Account.Name,OriginAcc_BizTypeL1__c,BusinessLevel__c, RecordType.Name from opportunity where  OwnerId = : u.Id];
        system.debug('ashish lstOpp'+lstOpp);
        
       
	Batch_WeeklySalesReport_Ashish obj = new Batch_WeeklySalesReport_Ashish();
        database.executeBatch(obj);
 }
@isTest
    public static void testWeeklySalesBatch6(){
          Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Rep.(HQ)' ];
        List<user> ulist = new List<user>();
        if(isSandbox) ulist = [ Select Id , name, Profile.Name,Email from User where  Profile.Name = 'Sales Rep.(HQ)'  AND IsActive = true ];
        else ulist = [ Select Id , name, Profile.Name,Email from User where Name = '박 재만' AND IsActive = true ];
        system.debug('ash ulist'+ulist);
        
        User u = new User(Alias = '박 재만', Email='Test@Test.com', 
                        EmailEncodingKey='UTF-8', LastName='박 재만', FirstName='박 재만', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                        UserName='user0001@samsung.com' ,IsActive = true);
	insert u;
       ulist[0].companycode__c = 'T100';
        update ulist;
       Id HQRecId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HQ').getRecordTypeId(); //Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('HQ').getRecordTypeId();
        
         Account acc = new Account( 
            Name = 'Test Account',
            MDGCheck__c = true,
             mDomesticForeign__c = '20'
        );
        insert acc;
  //      Id HQRecId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HQ').getRecordTypeId(); //Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('HQ').getRecordTypeId();
   DateTime dt = DateTime.now().addDays(-7);
        
        Organization__c org = new Organization__c(name='SDSAE');
        insert org;
                Opportunity opptyHQ2 = new Opportunity(
            Name = 'Test Opportunity',
    //        RecordTypeId = HQRecId,
           SalesOrganization__c = org.id,
           amount=1356,
            //ProposalPM_User__c = migUser.Id, //Anish v-1.2
            MigData__c = True,  //Anish v-1.2
            //StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today().adddays(-2),
            AccountId = acc.Id,
            cLeadID__c = NULL,
           ownerid = ulist[0].id,
           StageName = 'Z03',
                               XP7_CONDUCT_DATE__c =Date.today().adddays(2),
                    XP6_CONDUCT_DATE__c=Date.today().adddays(2)
         
        );
        system.runAs(ulist[0]){
           Company__c cmp = new Company__c(
            Name = 'comp',
            CompanyCode__c = 'T100'
        );
        insert cmp;
        Employee__c emp = new Employee__c(
            Name = 'testUser',
            EvMailAddr__c = 'SysAdminTestuser@samsung.com',
            EvUniqID__c = 'k123456789',
            Knox_Id__c = 'knoxId5',
            EvKostl__c = 'T604-11331'
        );
        insert emp;
       
       CostCenter__c costCenter1 = new CostCenter__c(
            Name                = '기술전략팀(T604-11331)'
            , DeptManager__c    = emp.Id
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T100'
            , CostCenterName__c = '기술전략팀'
            , Company__c = cmp.Id
            , CostCenter__c     = 'T604-11331'
            , Node1__c          = 'T604'
            , Node2__c          = 'T604SB'
            , Node3__c          = 'T604SB1'
            , Node4__c          = 'T604SB13'
            , Node5__c          = 'T604SB131'
            , ZZCheck__c = true
        );
        insert costCenter1; 
        opptyHQ2.RecordTypeId = HQRecId;
           opptyHQ2.SalesOrganization__c = org.id;
           opptyHQ2.amount=1356;
            opptyHQ2.SalesDepartment__c = costCenter1.Id;
            insert opptyHQ2;
        }
         List<Opportunity> lstOpp = new List<Opportunity>();
           lstOpp = [select Id, Amount,Name,OpportunityCode__c,ZP61_PROPOSAL_SUBMIT_DATE__c,ProposalPM__c,ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name,cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, StageName,BO1stRegistrationDate__c,CloseDate,XP7_CONDUCT_DATE__c,XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId,Account.Owner.Name,Account.Name,OriginAcc_BizTypeL1__c,BusinessLevel__c, RecordType.Name from opportunity where  OwnerId = : u.Id];
        system.debug('ashish lstOpp'+lstOpp);
        
       
	Batch_WeeklySalesReport_Ashish obj = new Batch_WeeklySalesReport_Ashish();
        database.executeBatch(obj);
 }

    @isTest
    public static void testWeeklySalesBatchtable4(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Rep.(HQ)' ];
       List<user> ulist = new List<user>();
        if(isSandbox) ulist = [ Select Id , name, Profile.Name,Email from User where  Profile.Name = 'Sales Rep.(HQ)'  AND IsActive = true ];
        else ulist = [ Select Id , name, Profile.Name,Email from User where Name = '박 재만' AND IsActive = true ];
         system.debug('ash ulist'+ulist);
        /*User u = new User(Alias = '박 재만', Email='Test@Test.com', 
                        EmailEncodingKey='UTF-8', LastName='박 재만', FirstName='박 재만', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                        UserName='user0001@samsung.com' ,IsActive = true);
	insert u;*/
        
        ulist[0].companycode__c = 'T100';
        update ulist;
         Account acc = new Account( 
            Name = 'Test Account',
            MDGCheck__c = true,
             mDomesticForeign__c = '20',
             mBizTypeL1Code__c = 'L200',
             mBizTypeL2Code__c = 'L202'
             
        );
        insert acc;
       Id HQRecId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HQ').getRecordTypeId(); //Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('HQ').getRecordTypeId();
   DateTime dt = DateTime.now().addDays(-6);
        
        Organization__c org = new Organization__c(name='SDSAE');
        insert org;
                Opportunity opptyHQ3 = new Opportunity(
            Name = 'Test Opportunity',
            RecordTypeId = HQRecId,
           SalesOrganization__c = org.id,
           amount=1356,
            //ProposalPM_User__c = migUser.Id, //Anish v-1.2
            MigData__c = True,  //Anish v-1.2
            //StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today().adddays(-5),
            AccountId = acc.Id,
            cLeadID__c = NULL,
           ownerid = ulist[0].id,
           BO1stRegistrationDate__c = dt,
           StageName = 'Z03',
                    XP7_CONDUCT_DATE__c =Date.today().adddays(2),
                    XP6_CONDUCT_DATE__c=Date.today().adddays(2),
                    BusinessLevel__c = 'S'
             //       CMBizType__c = 'CSP_SCP'
        );
        Opportunity oppcloned;
        system.runAs(ulist[0]){
           Company__c cmp = new Company__c(
            Name = 'comp',
            CompanyCode__c = 'T100'
        );
        insert cmp;
        Employee__c emp = new Employee__c(
            Name = 'testUser',
            EvMailAddr__c = 'SysAdminTestuser@samsung.com',
            EvUniqID__c = 'k123456789',
            Knox_Id__c = 'knoxId5',
            EvKostl__c = 'T604-11331'
        );
        insert emp;
       
       CostCenter__c costCenter1 = new CostCenter__c(
            Name                = '기술전략팀(T604-11331)'
            , DeptManager__c    = emp.Id
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T100'
            , CostCenterName__c = '기술전략팀'
            , Company__c = cmp.Id
            , CostCenter__c     = 'T604-11331'
            , Node1__c          = 'T604'
            , Node2__c          = 'T604SB'
            , Node3__c          = 'T604SB1'
            , Node4__c          = 'T604SB13'
            , Node5__c          = 'T604SB131'
            , ZZCheck__c = true
        );
        insert costCenter1; 
        opptyHQ3.RecordTypeId = HQRecId;
           opptyHQ3.SalesOrganization__c = org.id;
           opptyHQ3.amount=1356;
            opptyHQ3.SalesDepartment__c = costCenter1.Id;
        
            insert opptyHQ3;
          
             oppcloned= new Opportunity(
            Name = 'Test Opportunity',
            RecordTypeId = HQRecId,
           SalesOrganization__c = org.id,
           amount=1356,
            SalesDepartment__c = costCenter1.Id,
            //ProposalPM_User__c = migUser.Id, //Anish v-1.2
            MigData__c = True,  //Anish v-1.2
            //StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today().addyears(-2),
            AccountId = acc.Id,
            cLeadID__c = NULL,
           ownerid = ulist[0].id,
           BO1stRegistrationDate__c = dt,
           StageName = 'Z03',
                    XP7_CONDUCT_DATE__c =Date.today().adddays(2),
                    XP6_CONDUCT_DATE__c=Date.today().adddays(2),
                    BusinessLevel__c = 'S'
         //         CompanyCode__c = 'T100'
             //       CMBizType__c = 'CSP_SCP'
        );
        
            insert oppcloned;
            CostCenter__c invalidCC = new CostCenter__c(
            Name = 'Test Cost Center', CurrencyIsoCode = 'KRW', CompanyCode__c = 'T100', 
            CostCenterName__c = 'Test Cost Center', CostCenter__c = 'T100-11332', Node1__c = 'T100', 
            Node2__c = 'T100SB', Node3__c = 'T100SB1', Node4__c = 'T100SB13', Node5__c = 'T100SB131', 
            ClosingDate__c = System.today().addDays(2), ZZCheck__c = false, OwnerId = ulist[0].Id
        );
        insert invalidCC;
        
            Master_Service__c master_service = new Master_Service__c(
            Name = 'Test Master Service',
            Code__c = '20000024'
        );
        insert master_service;
        
       Master_Solution__c master_solution = new Master_Solution__c(
            Name = 'Test Master Solution',
            Code__c = '30000135'
        );
        insert master_solution;
            
       BizAttribute__c master_attribute = new BizAttribute__c(
            Name = 'Test Master Attribute',
            Code__c = 'S109'
        );
        insert master_attribute;
       CostCenter__c costCenter = new CostCenter__c(
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
SvcSolBizAttr__c svcSolBizAttr =  new SvcSolBizAttr__c(
            BizAttribute__c = master_attribute.Id,
            BusinessType__c = 'TI',
            Solution__c = master_solution.Id,
            WBSClass__c = 'SM',
            PSType__c = 'SM1',
            Use__c = true
        );
        insert svcSolBizAttr;
        

       Service__c service = new Service__c(
            Opportunity__c = opptyHQ3.Id,
            sService__c = master_service.Id,
            sDeliveryDepartment__c = costCenter.Id,
            sSalesDepartment__c  = costCenter.Id,
            ItemNumber__c = 10,
            Changed__c = true,
            sDeletionFlag__c = false
        );
        insert service;
Solution__c solution = new Solution__c(
            Opportunity__c = opptyHQ3.Id,
            Service__c = service.Id,
            sBizAttribute__c = master_attribute.Id,
            sSolution__c = master_solution.Id,
            sPSType__c = svcSolBizAttr.PsType__c,
            sWBSClass__c = svcSolBizAttr.WBSClass__c,
            sBusinessType__c = svcSolBizAttr.BusinessType__c,
            Changed__c = true,
            sDeletionFlag__c = false
        );
        insert solution;
		
       Service__c service1 = new Service__c(
            Opportunity__c = oppcloned.Id,
            sService__c = master_service.Id,
            sDeliveryDepartment__c = costCenter.Id,
            sSalesDepartment__c  = costCenter.Id,
            ItemNumber__c = 10,
            Changed__c = true,
            sDeletionFlag__c = false
        );
        insert service1;
Solution__c solution1 = new Solution__c(
            Opportunity__c = oppcloned.Id,
            Service__c = service1.Id,
            sBizAttribute__c = master_attribute.Id,
            sSolution__c = master_solution.Id,
            sPSType__c = svcSolBizAttr.PsType__c,
            sWBSClass__c = svcSolBizAttr.WBSClass__c,
            sBusinessType__c = svcSolBizAttr.BusinessType__c,
            Changed__c = true,
            sDeletionFlag__c = false
        );
        insert solution1;
        }
            
        
       //                     oppcloned.SalesDepartment__c = costCenter1.Id;
       // update oppcloned;    
       Opportunity oppt1=[select id, companycode__c,RecordType.Name,OriginAcc_BizTypeL1__c,OriginAcc_BizTypeL2__c,BusinessLevel__c,closedate from opportunity where id =: opptyHQ3.Id];
        system.debug('Ashish Test class oppt1::::'+oppt1);
       
        Opportunity oppt=[select id, companycode__c,RecordType.Name,OriginAcc_BizTypeL1__c,OriginAcc_BizTypeL2__c,BusinessLevel__c,closedate from opportunity where id =: oppcloned.Id];
        system.debug('Ashish Test class oppt::::'+oppt);
        //OriginAcc_BizTypeL1__c ='L200'  AND OriginAcc_BizTypeL2__c ='L202'  AND
        Map<Id,Opportunity> matchedoppLst = new Map<Id,Opportunity>([Select Id, companycode__c,OpportunityCode__c,Opportunity_Review_VRB_Type_Confirm__c,Opportunity_Review_Confirm__c, (select TransactionName__c,Status__c from BO_Activity__r where transactionname__c='ZP61' and status__c='Completed') , ProposalPM__c,RepresentativePM__c,ProposalPM__r.name,RepresentativePM__r.name,OriginAcc_BizTypeL1__c,OriginAcc_BizTypeL2__c,BusinessLevel__c,name,closedate,convertcurrency(amount),StageName,toLabel(StageName) toLabel_StageName From Opportunity where   BusinessLevel__c ='S'  and RecordType.Name = 'HQ'   and CompanyCode__c = 'T100' and  id in (SELECT opportunity__c from service__c where sService__r.Name in ('Test Master Service')  AND sDeletionFlag__c = false) and id in (SELECT opportunity__c from solution__c where sSolution__r.Name in ('Test Master Solution')  AND sDeletionFlag__c = false) LIMIT 50000]); //and closedate = LAST_N_YEARS:5  RecordType.Name = 'HQ' and CompanyCode__c = 'T100' and and id in (SELECT opportunity__c from service__c where sService__r.Name in ('Test Master Service')  AND sDeletionFlag__c = false) and id in (SELECT opportunity__c from solution__c where sSolution__r.Name in ('Test Master Solution')  AND sDeletionFlag__c = false)
        system.debug('Ashish Test class::::'+matchedoppLst);
        // List<Opportunity> lstOpp = new List<Opportunity>();
       //    lstOpp = [select Id, Amount,Name,OpportunityCode__c,ZP61_PROPOSAL_SUBMIT_DATE__c,ProposalPM__c,ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name,cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, StageName,BO1stRegistrationDate__c,CloseDate,XP7_CONDUCT_DATE__c,XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId,Account.Owner.Name,Account.Name,OriginAcc_BizTypeL1__c,BusinessLevel__c, RecordType.Name from opportunity where  OwnerId = : u.Id];
       // system.debug('ashish lstOpp'+lstOpp);
        
       
	Batch_WeeklySalesReport_Ashish obj = new Batch_WeeklySalesReport_Ashish();
        database.executeBatch(obj);
 }
    
@isTest
    public static void noOppty(){
       Batch_WeeklySalesReport_Ashish obj = new Batch_WeeklySalesReport_Ashish();
        database.executeBatch(obj);
    }
}