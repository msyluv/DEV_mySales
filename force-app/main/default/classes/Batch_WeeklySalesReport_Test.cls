/**
* @description       : Test class of Batch_WeeklySalesReport 
* @author            : d.ashish@samsung.com
* @group             : 
* @last modified on  : 2023-07-26
* @last modified by  : d.ashish@samsung.com
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2023-07-26   d.ashish@samsung.com   Initial Version
* 1.1   2024-03-08   atul.k1@samsung.com   Initial Version
**/
@isTest (SeeAllData = false)
public class Batch_WeeklySalesReport_Test {
    private static Boolean isSandbox = Utils.getIsSandbox();
    
    /*@isTest
public static void testWeeklySales(){
Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Rep.(HQ)' ];

User u = new User(Alias = '박 재만', Email='Test@Test.com', 
EmailEncodingKey='UTF-8', LastName='박 재만', FirstName='박 재만', LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
UserName='user0001@samsung.com' ,IsActive = true);
insert u;
Batch_WeeklySalesReport obj = new Batch_WeeklySalesReport();
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
        //wrapper insert
        
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
        BulletinBoard__c bulletinRec = new BulletinBoard__c();
        bulletinRec.Name = 'Bulletin Rec';
        bulletinRec.Notice__c = true; // V 1.2
       // bulletinRec.RecordTypeId = '0121s0000008wCnAAI';
        insert bulletinRec;
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
        
        opportunityamt__c oppamt = new opportunityamt__c(name = 'Test', Opportunitycode__c= 'SDS-123456', Companycode__c= 'T100', Version__c= 'S001', CurrencyIsoCode= 'KRW', Opportunity__c= opptyHQ1.Id, DiffAmtLoc__c= 1000,DiffAmt__c=1000, Closedate__c = Date.today());
        insert oppamt;
        
        List<Opportunity> lstOpp = new List<Opportunity>();
        lstOpp = [select Id, Amount,Name,OpportunityCode__c,ZP61_PROPOSAL_SUBMIT_DATE__c,ProposalPM__c,ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name,cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, StageName,BO1stRegistrationDate__c,CloseDate,XP7_CONDUCT_DATE__c,XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId,Account.Owner.Name,Account.Name,OriginAcc_BizTypeL1__c,BusinessLevel__c, RecordType.Name from opportunity where  OwnerId = : u.Id];
        system.debug('ashish lstOpp'+lstOpp);
        
        
        Batch_WeeklySalesReport obj = new Batch_WeeklySalesReport();
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
        
        
        Batch_WeeklySalesReport obj = new Batch_WeeklySalesReport();
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
        
        
        Batch_WeeklySalesReport obj = new Batch_WeeklySalesReport();
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
        Opportunity opptyadiHQ3 = new Opportunity(
            Name = 'Test Opportunity Adi',
            RecordTypeId = HQRecId,
            SalesOrganization__c = org.id,
            amount=1356,
            //ProposalPM_User__c = migUser.Id, //Anish v-1.2
            MigData__c = True,  //Anish v-1.2
            //StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today().adddays(6),
            AccountId = acc.Id,
            cLeadID__c = NULL,
            ownerid = ulist[0].id,
            BO1stRegistrationDate__c = dt,
            cRevenueStartDate__c = Date.today().addMonths(5),
            StageName = 'Z04',
            XP7_CONDUCT_DATE__c =Date.today().adddays(2),
            XP6_CONDUCT_DATE__c=Date.today().adddays(2),
            CMBizType__c = 'CSP_SCP',
            CspMspType__c='CSP'
        );
        Opportunity opptyadiHQ1 = new Opportunity(
            Name = 'Test Opportunity Adi1',
            RecordTypeId = HQRecId,
            SalesOrganization__c = org.id,
            amount=1356,
            //ProposalPM_User__c = migUser.Id, //Anish v-1.2
            MigData__c = True,  //Anish v-1.2
            //StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today().adddays(3),
            AccountId = acc.Id,
            cLeadID__c = NULL,
            ownerid = ulist[0].id,
            BO1stRegistrationDate__c = dt,
            StageName = 'Z04',
            XP7_CONDUCT_DATE__c =Date.today().adddays(2),
            XP6_CONDUCT_DATE__c=Date.today().adddays(2),
            CMBizType__c = 'CSP_SCP',
            CspMspType__c='CSP'
        );
        Opportunity opptyadiHQ2 = new Opportunity(
            Name = 'Test Opportunity Adi2',
            RecordTypeId = HQRecId,
            SalesOrganization__c = org.id,
            amount=1356,
            //ProposalPM_User__c = migUser.Id, //Anish v-1.2
            MigData__c = True,  //Anish v-1.2
            //StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today().adddays(3),
            AccountId = acc.Id,
            cLeadID__c = NULL,
            ownerid = ulist[0].id,
            BO1stRegistrationDate__c = dt,
            StageName = 'Z04',
            XP7_CONDUCT_DATE__c =Date.today().adddays(2),
            XP6_CONDUCT_DATE__c=Date.today().adddays(2),
            CMBizType__c = 'CSP_SCP',
            CspMspType__c='CSP'
        );
        Opportunity opptyadiHQ4 = new Opportunity(
            Name = 'Test Opportunity Adi4',
            RecordTypeId = HQRecId,
            SalesOrganization__c = org.id,
            amount=13567,
            //ProposalPM_User__c = migUser.Id, //Anish v-1.2
            MigData__c = True,  //Anish v-1.2
            //StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today().adddays(3),
            AccountId = acc.Id,
            cLeadID__c = NULL,
            ownerid = ulist[0].id,
            BO1stRegistrationDate__c = dt,
            StageName = 'Z04',
            cRevenueStartDate__c = Date.today().addMonths(1),
            XP7_CONDUCT_DATE__c =Date.today().adddays(2),
            XP6_CONDUCT_DATE__c=Date.today().adddays(2),
            CMBizType__c = 'CSP_SCP',
            CspMspType__c='CSP'
        );
        Opportunity opptyadiHQ5 = new Opportunity(
            Name = 'Test Opportunity Adi5',
            RecordTypeId = HQRecId,
            SalesOrganization__c = org.id,
            amount=13567,
            //ProposalPM_User__c = migUser.Id, //Anish v-1.2
            MigData__c = True,  //Anish v-1.2
            //StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today().adddays(3),
            AccountId = acc.Id,
            cLeadID__c = NULL,
            ownerid = ulist[0].id,
            BO1stRegistrationDate__c = dt,
            StageName = 'Z04',
            cRevenueStartDate__c = Date.today().addMonths(1),
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
            opptyadiHQ3.RecordTypeId = HQRecId;
            opptyadiHQ3.SalesOrganization__c = org.id;
            opptyadiHQ3.amount=1356;
            opptyadiHQ3.SalesDepartment__c = costCenter1.Id;
            insert opptyadiHQ3;
            opptyadiHQ1.RecordTypeId = HQRecId;
            opptyadiHQ1.SalesOrganization__c = org.id;
            opptyadiHQ1.amount=1356;
            opptyadiHQ1.SalesDepartment__c = costCenter1.Id;
            insert opptyadiHQ1;
            opptyadiHQ2.RecordTypeId = HQRecId;
            opptyadiHQ2.SalesOrganization__c = org.id;
            opptyadiHQ2.amount=1356;
            opptyadiHQ2.SalesDepartment__c = costCenter1.Id;
            insert opptyadiHQ2;
            opptyadiHQ4.RecordTypeId = HQRecId;
            opptyadiHQ4.SalesOrganization__c = org.id;
            opptyadiHQ4.amount=1356;
            opptyadiHQ4.SalesDepartment__c = costCenter1.Id;
            insert opptyadiHQ4;
            opptyadiHQ5.RecordTypeId = HQRecId;
            opptyadiHQ5.SalesOrganization__c = org.id;
            opptyadiHQ5.amount=135126;
            opptyadiHQ5.SalesDepartment__c = costCenter1.Id;
            insert opptyadiHQ5;
        }
        
        TXPmanpower__c txpTemp      = new TXPmanpower__c();
        txpTemp.Opportunity__c      = opptyHQ3.Id;
        txpTemp.BOCode__c           = 'SDS-123456';
        txpTemp.companycode__c      = 'T100';
        txpTemp.ProposalPMNo__c     = '12345';
        txpTemp.ProposalPMStatus__c = '';
        txpTemp.ProposalPMStDt__c   = Date.valueOf('2023-1-8');
        txpTemp.ProposalPMEdDt__c   = Date.valueOf('2023-12-31');
        txpTemp.ExecutionPMNo__c    = '12345';
        txpTemp.ExecutionPMStatus__c= 'ASSGNEND';
        txpTemp.ExecutionPMStDt__c  = Date.valueOf('2023-10-1');
        txpTemp.ExecutionPMEdDt__c  = Date.valueOf('2024-2-3');
        txpTemp.ProposalPMPlan__c   = 'Y';
        txpTemp.ExecutionPMPlan__c  = 'Y';
        txpTemp.P_Projectcode__c    = '09643';
        txpTemp.E_Projectcode__c    = '123567';
        
        upsert txpTemp;
        System.debug('txpTemp'+txpTemp);
        
        TXPmanpower__c txpTemp1      = new TXPmanpower__c();
        txpTemp1.Opportunity__c      = opptyadiHQ1.Id;
        txpTemp1.BOCode__c           = 'SDS-123459';
        txpTemp1.companycode__c      = 'T100';
        txpTemp1.ProposalPMNo__c     = '12349';
        txpTemp1.ProposalPMStatus__c = 'ASSGNEND';
        txpTemp1.ProposalPMStDt__c   = Date.valueOf('2023-1-8');
        txpTemp1.ProposalPMEdDt__c   = Date.valueOf('2023-12-31');
        txpTemp1.ExecutionPMNo__c    = '12349';
        txpTemp1.ExecutionPMStatus__c= 'ASSGNEND';
        txpTemp1.ExecutionPMStDt__c  = Date.valueOf('2023-10-1');
        txpTemp1.ExecutionPMEdDt__c  = Date.valueOf('2024-2-3');
        txpTemp1.ProposalPMPlan__c   = 'Y';
        txpTemp1.ExecutionPMPlan__c  = 'Y';
        txpTemp1.P_Projectcode__c    = 'SCC21765381D000';
        txpTemp1.E_Projectcode__c    = '123568';
        
        upsert txpTemp1;
        System.debug('txpTemp'+txpTemp1);
        
        TXPmanpower__c txpTemp2      = new TXPmanpower__c();
        txpTemp2.Opportunity__c      = opptyadiHQ2.Id;
        txpTemp2.BOCode__c           = 'SDS-123459';
        txpTemp2.companycode__c      = 'T100';
        txpTemp2.ProposalPMNo__c     = '12349';
        txpTemp2.ProposalPMStatus__c = 'ASSGNEND';
        txpTemp2.ProposalPMStDt__c   = Date.valueOf('2023-1-8');
        txpTemp2.ProposalPMEdDt__c   = Date.valueOf('2023-12-31');
        txpTemp2.ExecutionPMNo__c    = '12349';
        txpTemp2.ExecutionPMStatus__c= 'ASSGNEND';
        txpTemp2.ExecutionPMStDt__c  = Date.valueOf('2023-10-1');
        txpTemp2.ExecutionPMEdDt__c  = Date.valueOf('2024-2-3');
        txpTemp2.ProposalPMPlan__c   = 'Y';
        txpTemp2.ExecutionPMPlan__c  = 'Y';
        txpTemp2.P_Projectcode__c    = 'SCC21765381D000';
        txpTemp2.E_Projectcode__c    = '123568';
        
        upsert txpTemp2;
        System.debug('txpTemp'+txpTemp2);
        
        TXPmanpower__c txpTemp3      = new TXPmanpower__c();
        txpTemp3.Opportunity__c      = opptyadiHQ4.Id;
        txpTemp3.BOCode__c           = 'SDS-123459';
        txpTemp3.companycode__c      = 'T100';
        txpTemp3.ProposalPMNo__c     = '12349';
        txpTemp3.ProposalPMStatus__c = 'ASSGNEND';
        txpTemp3.ProposalPMStDt__c   = Date.valueOf('2023-1-8');
        txpTemp3.ProposalPMEdDt__c   = Date.valueOf('2023-11-29');
        txpTemp3.ExecutionPMNo__c    = '12349';
        txpTemp3.ExecutionPMStatus__c= 'ASSGNEND';
        txpTemp3.ExecutionPMStDt__c  = Date.valueOf('2023-10-1');
        txpTemp3.ExecutionPMEdDt__c  = Date.valueOf('2024-2-3');
        txpTemp3.ProposalPMPlan__c   = 'Y';
        txpTemp3.ExecutionPMPlan__c  = 'Y';
        txpTemp3.P_Projectcode__c    = 'SCC21765381D000';
        txpTemp3.E_Projectcode__c    = '123568';
        
        upsert txpTemp3;
        System.debug('txpTemp'+txpTemp3);
        
        TXPmanpower__c txpTemp4      = new TXPmanpower__c();
        txpTemp4.Opportunity__c      = opptyadiHQ5.Id;
        txpTemp4.BOCode__c           = 'SDS-123459';
        txpTemp4.companycode__c      = 'T100';
        txpTemp4.ProposalPMNo__c     = '12349';
        txpTemp4.ProposalPMStatus__c = 'ASSGNEND';
        txpTemp4.ProposalPMStDt__c   = Date.valueOf('2023-1-8');
        txpTemp4.ProposalPMEdDt__c   = Date.valueOf('2024-11-29');
        txpTemp4.ExecutionPMNo__c    = '12349';
        txpTemp4.ExecutionPMStatus__c= 'ASSGNEND';
        txpTemp4.ExecutionPMStDt__c  = Date.valueOf('2023-10-1');
        txpTemp4.ExecutionPMEdDt__c  = Date.valueOf('2024-2-3');
        txpTemp4.ProposalPMPlan__c   = 'Y';
        txpTemp4.ExecutionPMPlan__c  = 'Y';
        txpTemp4.P_Projectcode__c    = 'SCC21765381D000';
        txpTemp4.E_Projectcode__c    = '123568';
        
        upsert txpTemp4;
        System.debug('txpTemp'+txpTemp4);
               
        List<Opportunity> lstOpp = new List<Opportunity>();
        lstOpp = [select Id, Amount,Name,OpportunityCode__c,ZP61_PROPOSAL_SUBMIT_DATE__c,ProposalPM__c,ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name,cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, StageName,BO1stRegistrationDate__c,CloseDate,XP7_CONDUCT_DATE__c,XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId,Account.Owner.Name,Account.Name,OriginAcc_BizTypeL1__c,BusinessLevel__c, RecordType.Name from opportunity where  OwnerId = : u.Id];
        system.debug('ashish lstOpp'+lstOpp);
        
        Project__c project = new Project__c(
            Opportunity__c =  opptyadiHQ1.Id,
            Name = opptyadiHQ1.Name,
            Description__c = '',
            ProjectCode__c = 'SCC21765381D000'
            );
        insert project;
        
        Project__c project1 = new Project__c(
            Opportunity__c =  opptyadiHQ2.Id,
            Name = opptyadiHQ1.Name,
            Description__c = '',
            ProjectCode__c = 'SCC2176538'
            );
        insert project1;
        
        SCPSimulation__c temp = new SCPSimulation__c();
        temp.BOCode__c = 'SDS-20000200';
        temp.companyCode__c = 'T100';
        temp.quotNm__c = 'Test';
        temp.quotId__c = '1';
        temp.orderRate__c = Decimal.valueOf('1234');
        temp.az__c = '';
        temp.totAmt__c = Decimal.valueOf('43');
        temp.crncyCd__c = '12';
        temp.serviceDt__c = '';
        temp.quotStat__c = '';
        temp.regDate__c = Date.valueOf('2023-07-25');
        temp.chgDate__c = Date.valueOf('2023-07-25');
        temp.Opportunity__c = opptyadiHQ2.Id;
        upsert temp;
        
        Batch_WeeklySalesReport obj = new Batch_WeeklySalesReport();
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
        
        
        Batch_WeeklySalesReport obj = new Batch_WeeklySalesReport();
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
            ZP61_PROPOSAL_SUBMIT_DATE__c = Date.today().adddays(2),
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
        
        
        Batch_WeeklySalesReport obj = new Batch_WeeklySalesReport();
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
        
        
        Batch_WeeklySalesReport obj = new Batch_WeeklySalesReport();
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
       
        
        Batch_WeeklySalesReport obj = new Batch_WeeklySalesReport();
        database.executeBatch(obj);
    }
    
    @isTest
    public static void noOppty(){
        Batch_WeeklySalesReport obj = new Batch_WeeklySalesReport();
        database.executeBatch(obj);
    }
}