/**
* @description       : Test class of Batch_WeeklySalesReport_Overseas_Test 
* @author            : atul.k1@samsung.com
* @group             : 
* @last modified on  : 2024-10-01
* @last modified by  : atul.k1@samsung.com
* Modifications Log 
**/
@isTest(SeeAllData=false)
public class Batch_ManagerTest_Report_Overseas_Test {
    private static Boolean isSandbox = Utils.getIsSandbox();
    
    @testSetup static void setup(){
		
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Manager(Overseas Corp)' ];
        Profile p1 = [SELECT Id FROM Profile WHERE Name = 'Sales Rep.(Overseas Corp)' ];
        User u = new User(Alias = '박 재만', Email='testsa@test.com', 
                              EmailEncodingKey='UTF-8', LastName='박 재만', FirstName='박 재만', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                              UserName='user0001@samsung.com' ,IsActive = true, EvKostl__c = 'T201-10384', CompanyCode__c = 'T201', CostCenter_Level_5__c = '기술전략팀(T201-10384)');
        insert u;
        system.debug('Inserted User : '+ u);
        
        User u1 = new User(Alias = '박 재만1', Email='test1@test.com', 
                              EmailEncodingKey='UTF-8', LastName='박 재만', FirstName='박 재만1', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p1.Id, TimeZoneSidKey='Asia/Seoul', 
                              UserName='user0002@samsung.com' ,IsActive = true, EvKostl__c = 'T201-10384', CompanyCode__c = 'T201', CostCenter_Level_5__c = '기술전략팀(T201-10384)');
        insert u1;
        system.debug('Inserted User1 : '+ u1);
        
        User u2 = new User(Alias = '박 재만2', Email='test2@test.com', 
                              EmailEncodingKey='UTF-8', LastName='박 재만', FirstName='박 재만2', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p1.Id, TimeZoneSidKey='Asia/Seoul', 
                              UserName='user0003@samsung.com' ,IsActive = true, EvKostl__c = 'T201-10384', CompanyCode__c = 'T201', CostCenter_Level_5__c = '기술전략팀(T201-10384)');
        insert u2;
        system.debug('Inserted User2 : '+ u2);

		Account acc = new Account( 
                Name = 'Test Account',
                MDGCheck__c = true,
                mDomesticForeign__c = '20'
            );
        insert acc;
        system.debug('Inserted Account : '+ acc);
        
        Organization__c org = new Organization__c(name='SDSAE');
        insert org;
        system.debug('Inserted Org : '+ org);
        
        system.runAs(u1){
        Company__c cmp = new Company__c(
                    Name = 'comp',
                    CompanyCode__c = 'T201'
                );
        insert cmp;
        system.debug('Inserted Company : '+ cmp);
            
        Company__c cmp1 = new Company__c(
                    Name = 'comp1',
                    CompanyCode__c = 'T201'
                );
        insert cmp1;
        system.debug('Inserted Company : '+ cmp1);
            
        Company__c cmp2 = new Company__c(
                    Name = 'comp2',
                    CompanyCode__c = '201'
                );
        insert cmp2;
        system.debug('Inserted Company : '+ cmp2);
        
		Employee__c emp = new Employee__c(
                    Name = 'testUser',
                    EvMailAddr__c = 'test@test.com',
                    EvTitleJikchakEN__c = 'Group Leader',
                    EvUniqID__c = 'k123451789',
                    Knox_Id__c = 'knoxId5',
                    EvKostl__c = 'T201-10384'
                );
        insert emp;
        system.debug('Inserted Employee : '+ emp);

        Employee__c emp1 = new Employee__c(
                    Name = 'testUser1',
                    EvMailAddr__c = 'test1@test.com',
                    EvUniqID__c = 'k123456789',
                    Knox_Id__c = 'knoxId6',
                    EvKostl__c = 'T201-10384'
                );
        insert emp1;
        system.debug('Inserted Employee1 : '+ emp1);
            
        Employee__c emp2 = new Employee__c(
                    Name = 'testUser2',
                    EvMailAddr__c = 'test2@test.com',
                    EvUniqID__c = 'k123457789',
                    Knox_Id__c = 'knoxId7',
                    EvKostl__c = 'T201-10384'
                );
        insert emp2;
        system.debug('Inserted Employee1 : '+ emp2);
        
        CostCenter__c costCenter1 = new CostCenter__c(
                    Name                = '기술전략팀(T201-10384)'
                    , DeptManager__c    = emp.Id
                    , CurrencyIsoCode   = 'KRW'
                    , CompanyCode__c    = 'T201'
                    , CostCenterName__c = '기술전략팀'
                    , Company__c = cmp.Id
                    , CostCenter__c     = 'T201-10384'
                    , Node1__c          = 'T201'
                    , Node2__c          = 'T201SB'
                    , Node3__c          = 'T201SB1'
                    , Node4__c          = 'T201SB13'
                    , Node5__c          = 'T201SB131'
                    , ZZCheck__c = true
                );
        insert costCenter1; 
        costCenter1 = [select id,name,DeptManager__c, DeptManagerEmail__c from CostCenter__c where id =: costCenter1.Id];
        system.debug('Inserted CostCenter : '+ costCenter1);
        system.debug('Inserted CostCenter details : '+ costCenter1.DeptManagerEmail__c);
        
        BulletinBoard__c bulletinRec = new BulletinBoard__c();
        bulletinRec.Name = 'Bulletin Rec';
        bulletinRec.Notice__c = true; // V 1.2
        // bulletinRec.RecordTypeId = '0121s0000008wCnAAI';
        insert bulletinRec;
        
        /*SCpSimulation__c Scp = new SCpSimulation__c();
        Scp.BOCode__c = 'SDS-0001001';
        insert Scp;*/
         
        /*CostCenter__c costCenter2 = new CostCenter__c(
                    Name                = '기술전략팀(T100-10384-1)'
                    , DeptManager__c    = emp1.Id
                    , CurrencyIsoCode   = 'KRW'
                    , CompanyCode__c    = 'T100'
                    , CostCenterName__c = '기술전략팀1'
                    , Company__c = cmp1.Id
                    , CostCenter__c     = 'T100-12211'
                    , Node1__c          = 'T100'
                    , Node2__c          = 'T100SC'
                    , Node3__c          = 'T100SC1'
                    , Node4__c          = 'T100SC13'
                    , Node5__c          = 'T100SC131'
                    , ZZCheck__c = true
                );
        insert costCenter2; 
        system.debug('Inserted CostCenter : '+ costCenter2);
            
        CostCenter__c costCenter3 = new CostCenter__c(
                    Name                = '기술전략팀(T100-10384-2)'
                    , DeptManager__c    = emp2.Id
                    , CurrencyIsoCode   = 'KRW'
                    , CompanyCode__c    = 'T100'
                    , CostCenterName__c = '기술전략팀2'
                    , Company__c = cmp2.Id
                    , CostCenter__c     = 'T100-12212'
                    , Node1__c          = 'T100'
                    , Node2__c          = 'T100SD'
                    , Node3__c          = 'T100SD1'
                    , Node4__c          = 'T100SD13'
                    , Node5__c          = 'T100SD131'
                    , ZZCheck__c = true
                );
        insert costCenter1; 
        system.debug('Inserted CostCenter : '+ costCenter3);*/
        }
        
    }
    
    @isTest
        public static void testWeeklySalesBatch(){
            List<User> alluser = [select id , name from user]; 
            system.debug('allUser' + alluser.size() + 'name--' + alluser[0].name);
            List<user> ulist = new List<user>();
            if(isSandbox) ulist = [ Select Id , name, Profile.Name,Email from User where  Profile.Name = 'Sales Manager(Overseas Corp)'  AND IsActive = true ];
            else ulist = [ Select Id , name, Profile.Name,Email from User where Name = '곽 승동' AND IsActive = true ];
            system.debug('ash ulist'+ulist);
            system.debug('adi ulist size '+ulist.size());
            RecordType recordId = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'HQ' Limit 1];
            Account acc = [select id,name from Account where name = 'Test Account' Limit 1];
            CostCenter__c costCenterHQ = [select id,name,CompanyCode__c from CostCenter__c where name = '기술전략팀(T201-10384)' Limit 1];
            System.debug('Cost Center Company Code : ' + costCenterHQ.CompanyCode__c);
            User u = [select id,name from user where email = 'Test1@Test.com' Limit 1];
            User u1 = [select id,name from user where email = 'Test2@Test.com' Limit 1];
            
            DateTime dt = DateTime.now().addDays(-7);

            Opportunity oppty = new Opportunity(Name ='Test', RecordTypeId = recordId.Id, AccountId =acc.Id, CurrencyIsoCode = 'KRW', Amount = 1010000,
                                cRevenueStartDate__c = system.today(), cRevenueEndDate__c = System.today().addMonths(2), 
                                CloseDate = System.today().addMonths(2), StageName = 'Z01', cPrimarySalesDepartment__c = costCenterHQ.Id,
            					SalesDepartment__c = costCenterHQ.Id, cOriginAcc__c = acc.Id, CspMspType__c = 'CSP',
            					OtherCSP__c = 'CSP1', MSP_Amount__c = 200, cLeadID__c = NULL, Opportunitycode__c= 'SDS-123456');
            Opportunity oppty9 = new Opportunity(Name ='Test', RecordTypeId = recordId.Id, AccountId =acc.Id, CurrencyIsoCode = 'KRW', Amount = 1010000,
                                cRevenueStartDate__c = system.today(), cRevenueEndDate__c = System.today().addMonths(2), 
                                CloseDate = System.today().addMonths(2), StageName = 'Z01', cPrimarySalesDepartment__c = costCenterHQ.Id,
            					SalesDepartment__c = costCenterHQ.Id, cOriginAcc__c = acc.Id, CspMspType__c = 'CSP',
            					OtherCSP__c = 'CSP1', MSP_Amount__c = 200, cLeadID__c = NULL, Opportunitycode__c= 'SDS-123457');
            
          
            system.runAs(u1){
                Id ProfileId = UserInfo.getProfileId();
                Id CurrentUser = userinfo.getUserid();
                String CurrentCompanyCode = [select id,name,CompanyCode__c from user where id =: CurrentUser].CompanyCode__c;
                String ProfileName = [select id,name from profile where id =: ProfileId].Name;
                system.debug('Current user profile : '+ ProfileName + ' SalesDepartment__c Closed : '+ oppty.SalesDepartment__r.Closed__c + ' Current user Company code : '+ CurrentCompanyCode + 'Oppty Comapny Code : ' + oppty.SalesDepartment__r.CompanyCode__c + 'Oppty ZZCode : ' + oppty.SalesDepartment__r.ZZCheck__c + 'Opp Owner Id: ' + oppty.ownerId + ' Current user Id : '+ CurrentUser);
                insert oppty;
                insert oppty9;
            }
            oppty = [select id, name, companycode__c from opportunity where id =: oppty.id];
            oppty9 = [select id, name, companycode__c from opportunity where id =: oppty9.id];
            System.debug('--->Inserted oppty from method : '+ oppty.CompanyCode__c);
              TXPmanpower__c tt = new TXPmanpower__c();
            
            tt.ProposalPMStatus__c = null;
            tt.companycode__c = 'SDS-123456';
            tt.BOCode__c ='SDS-123456';
            tt.Opportunity__c  = oppty.id;
            insert tt;
            
             TXPmanpower__c tt1 = new TXPmanpower__c();
            
            tt1.ProposalPMStatus__c = 'test';
            tt1.companycode__c = 'SDS-123457';
            tt1.BOCode__c ='SDS-123457';
            tt1.P_Projectcode__c ='pCode123';
            tt1.Opportunity__c  = oppty9.id;
            tt1.ProposalPMStDt__c = Date.valueOf('2020-12-21');
            tt1.ProposalPMEdDt__c = Date.valueOf('2020-12-21');
            insert tt1;
            Project__c pp = new Project__c();
            pp.Opportunity__c = oppty.id;
            pp.ProjectCode__c = 'pCode123';
            pp.name='testproject';
            insert pp;
            Opportunity oppty1 = new Opportunity(Name ='TestAdi', RecordTypeId = recordId.Id, AccountId =acc.Id, CurrencyIsoCode = 'KRW', Amount = 1000001,
                                cRevenueStartDate__c = system.today(), cRevenueEndDate__c = System.today().addMonths(2), 
                                CloseDate = System.today().addMonths(2), StageName = 'Z01', cPrimarySalesDepartment__c = costCenterHQ.Id,
            					SalesDepartment__c = costCenterHQ.Id, cOriginAcc__c = acc.Id, CspMspType__c = 'CSP', 
            					OtherCSP__c = 'CSP1', MSP_Amount__c = 200, cLeadID__c = NULL, Opportunitycode__c= 'SDS-123456');
            system.runAs(u1){
                insert oppty1;
            }
            oppty1 = [select id, name, companycode__c from opportunity where id =: oppty1.id];
            System.debug('--->Inserted oppty1 from method : '+ oppty1.CompanyCode__c);
            
            aggregateResult aggres = [select max(owner.CostCenter_Level_4__c),owner.EvKostl__c from opportunity where recordtype.name = 'HQ' and companycode__c = 'T201' and owner.evkostl__c != null group by owner.EvKostl__c];
            system.debug('Agg Result ---> ' + aggres + '  Aggs evkostal : '+ aggres.get('EvKostl__c'));
                
            opportunityamt__c oppamt = new opportunityamt__c(name = 'Test', Opportunitycode__c= 'SDS-123456', Companycode__c= 'T201', Version__c= 'S001', CurrencyIsoCode= 'KRW', Opportunity__c= oppty.Id, DiffAmtUSD__c= 1000,DiffAmt__c = 1000);
            insert oppamt;
            
            WeeklyReport__c weere = new WeeklyReport__c(name = 'Test', ReportingDate__c = system.today(), Opportunity__c = oppty.id);
            insert weere;
            
            WeeklyReport__c weere1 = new WeeklyReport__c(name = 'Test1', ReportingDate__c = system.today(), Opportunity__c = oppty1.id);
            insert weere1;
            
            List<Opportunity> lstOpp = new List<Opportunity>();
            lstOpp = [select Id, Amount,Name,OpportunityCode__c,ZP61_PROPOSAL_SUBMIT_DATE__c,ProposalPM__c,ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name,cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, StageName,BO1stRegistrationDate__c,CloseDate,XP7_CONDUCT_DATE__c,XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId,Account.Owner.Name,Account.Name,OriginAcc_BizTypeL1__c,BusinessLevel__c, RecordType.Name,CompanyCode__c from opportunity where  OwnerId = : u.Id];
            system.debug('ashish lstOpp'+lstOpp);
            
            BulletinBoard__c bulletinRec = new BulletinBoard__c();
       	 	bulletinRec.Name = 'Bulletin Rec1';
        	bulletinRec.Notice__c = true; // V 1.2
       		// bulletinRec.RecordTypeId = '0121s0000008wCnAAI';
        	insert bulletinRec;
            
            test.startTest();
            Batch_ManagerTest_SalesReport_Overseas obj = new Batch_ManagerTest_SalesReport_Overseas();
            database.executeBatch(obj);
            test.stopTest();
        }
    
    @isTest
    public static void testWeeklySalesBatch1(){
        List<user> ulist = new List<user>();
            if(isSandbox) ulist = [ Select Id , name, Profile.Name,Email from User where  Profile.Name = 'Sales Manager(Overseas Corp)'  AND IsActive = true ];
            else ulist = [ Select Id , name, Profile.Name,Email from User where Name = '곽 승동' AND IsActive = true ];
            system.debug('ash ulist'+ulist);
            system.debug('adi ulist size '+ulist.size());
            RecordType recordId = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'HQ' Limit 1];
            Account acc = [select id,name from Account where name = 'Test Account' Limit 1];
            CostCenter__c costCenterHQ = [select id,name,CompanyCode__c from CostCenter__c where name = '기술전략팀(T201-10384)' Limit 1];
            System.debug('Cost Center Company Code : ' + costCenterHQ.CompanyCode__c);
            User u = [select id,name from user where email = 'Test1@Test.com' Limit 1];
            
            DateTime dt = DateTime.now().addDays(-7);

            Opportunity oppty = new Opportunity(Name ='Test1', RecordTypeId = recordId.Id, AccountId =acc.Id, CurrencyIsoCode = 'KRW', Amount = 100000,
                                cRevenueStartDate__c = system.today(), cRevenueEndDate__c = System.today().addMonths(2), CloseDate = System.today(), 
                                StageName = 'Z01', cPrimarySalesDepartment__c = costCenterHQ.Id, SalesDepartment__c = costCenterHQ.Id, cOriginAcc__c = acc.Id, 
            					CspMspType__c = 'CSP', OtherCSP__c = 'CSP1', MSP_Amount__c = 200, cLeadID__c = NULL, XP7_CONDUCT_DATE__c =Date.today().adddays(2), 
            					XP6_CONDUCT_DATE__c=Date.today().adddays(2), ZP61_PROPOSAL_SUBMIT_DATE__c=Date.today().adddays(2), Opportunitycode__c= 'SDS-123456');
            system.runAs(u){
                Id ProfileId = UserInfo.getProfileId();
                Id CurrentUser = userinfo.getUserid();
                String CurrentCompanyCode = [select id,name,CompanyCode__c from user where id =: CurrentUser].CompanyCode__c;
                String ProfileName = [select id,name from profile where id =: ProfileId].Name;
                system.debug('Current user profile : '+ ProfileName + ' SalesDepartment__c Closed : '+ oppty.SalesDepartment__r.Closed__c + ' Current user Company code : '+ CurrentCompanyCode + 'Oppty Comapny Code : ' + oppty.SalesDepartment__r.CompanyCode__c + 'Oppty ZZCode : ' + oppty.SalesDepartment__r.ZZCheck__c + 'Opp Owner Id: ' + oppty.ownerId + ' Current user Id : '+ CurrentUser);
                insert oppty;
            }
        
        	opportunityamt__c oppamt = new opportunityamt__c(name = 'Test', Opportunitycode__c= 'SDS-123456', Companycode__c= 'T201', Version__c= 'S001', CurrencyIsoCode= 'KRW', Opportunity__c= oppty.Id, DiffAmtUSD__c= 1000,DiffAmt__c = 1000);
            insert oppamt;
        
        	WeeklyReport__c weere = new WeeklyReport__c(name = 'Test', ReportingDate__c = system.today(), Opportunity__c = oppty.id);
            insert weere;
        
            List<Opportunity> lstOpp = new List<Opportunity>();
            lstOpp = [select Id, Amount,Name,OpportunityCode__c,ZP61_PROPOSAL_SUBMIT_DATE__c,ProposalPM__c,ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name,cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, StageName,BO1stRegistrationDate__c,CloseDate,XP7_CONDUCT_DATE__c,XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId,Account.Owner.Name,Account.Name,OriginAcc_BizTypeL1__c,BusinessLevel__c, RecordType.Name,CompanyCode__c from opportunity where  OwnerId = : u.Id];
            system.debug('ashish lstOpp'+lstOpp);
            
            BulletinBoard__c bulletinRec = new BulletinBoard__c();
       	 	bulletinRec.Name = 'Bulletin Rec2';
        	bulletinRec.Notice__c = true; // V 1.2
       		// bulletinRec.RecordTypeId = '0121s0000008wCnAAI';
        	insert bulletinRec;
        
            test.startTest();
            Batch_ManagerTest_SalesReport_Overseas obj = new Batch_ManagerTest_SalesReport_Overseas();
            database.executeBatch(obj);
        	test.stopTest();
    }
    
    @isTest
    public static void testWeeklySalesBatch2(){
        List<user> ulist = new List<user>();
            if(isSandbox) ulist = [ Select Id , name, Profile.Name,Email from User where  Profile.Name = 'Sales Manager(Overseas Corp)'  AND IsActive = true ];
            else ulist = [ Select Id , name, Profile.Name,Email from User where Name = '곽 승동' AND IsActive = true ];
            system.debug('ash ulist'+ulist);
            system.debug('adi ulist size '+ulist.size());
            RecordType recordId = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'HQ' Limit 1];
            Account acc = [select id,name from Account where name = 'Test Account' Limit 1];
            CostCenter__c costCenterHQ = [select id,name,CompanyCode__c from CostCenter__c where name = '기술전략팀(T201-10384)' Limit 1];
            System.debug('Cost Center Company Code : ' + costCenterHQ.CompanyCode__c);
            User u = [select id,name from user where email = 'Test1@Test.com' Limit 1];
            
            DateTime dt = DateTime.now().addDays(-7);

            Opportunity oppty = new Opportunity(Name ='Test2', RecordTypeId = recordId.Id, AccountId =acc.Id, CurrencyIsoCode = 'KRW', Amount = 100000,
                                cRevenueStartDate__c = system.today(), cRevenueEndDate__c = System.today().addMonths(2), CloseDate = System.today(), 
                                StageName = 'Z05', cPrimarySalesDepartment__c = costCenterHQ.Id, SalesDepartment__c = costCenterHQ.Id, cOriginAcc__c = acc.Id, 
            					CspMspType__c = 'CSP', OtherCSP__c = 'CSP1', MSP_Amount__c = 200, cLeadID__c = NULL, XP7_CONDUCT_DATE__c =Date.today().adddays(2), 
            					XP6_CONDUCT_DATE__c=Date.today().adddays(2), ZP61_PROPOSAL_SUBMIT_DATE__c=Date.today().adddays(2), Opportunitycode__c= 'SDS-123456');
            system.runAs(u){
                Id ProfileId = UserInfo.getProfileId();
                Id CurrentUser = userinfo.getUserid();
                String CurrentCompanyCode = [select id,name,CompanyCode__c from user where id =: CurrentUser].CompanyCode__c;
                String ProfileName = [select id,name from profile where id =: ProfileId].Name;
                system.debug('Current user profile : '+ ProfileName + ' SalesDepartment__c Closed : '+ oppty.SalesDepartment__r.Closed__c + ' Current user Company code : '+ CurrentCompanyCode + 'Oppty Comapny Code : ' + oppty.SalesDepartment__r.CompanyCode__c + 'Oppty ZZCode : ' + oppty.SalesDepartment__r.ZZCheck__c + 'Opp Owner Id: ' + oppty.ownerId + ' Current user Id : '+ CurrentUser);
                insert oppty;
            }
        
        	opportunityamt__c oppamt = new opportunityamt__c(name = 'Test', Opportunitycode__c= 'SDS-123456', Companycode__c= 'T201', Version__c= 'S001', CurrencyIsoCode= 'KRW', Opportunity__c= oppty.Id, DiffAmtUSD__c= 100,DiffAmt__c = 100, Closedate__c = Date.today(), Confirmdate__c = Date.today());
            insert oppamt;
        
        	opportunityamt__c oppamt1 = new opportunityamt__c(name = 'Test1', Opportunitycode__c= 'SDS-123456', Companycode__c= 'T201', Version__c= 'S002', CurrencyIsoCode= 'KRW', Opportunity__c= oppty.Id, DiffAmtUSD__c= 1000,DiffAmt__c = 1000, Closedate__c = Date.today(), Confirmdate__c = Date.today());
            insert oppamt1;
        
        	WeeklyReport__c weere = new WeeklyReport__c(name = 'Test', ReportingDate__c = system.today(), Opportunity__c = oppty.id);
            insert weere;
        
            List<Opportunity> lstOpp = new List<Opportunity>();
            lstOpp = [select Id, Amount,Name,OpportunityCode__c,ZP61_PROPOSAL_SUBMIT_DATE__c,ProposalPM__c,ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name,cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, StageName,BO1stRegistrationDate__c,CloseDate,XP7_CONDUCT_DATE__c,XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId,Account.Owner.Name,Account.Name,OriginAcc_BizTypeL1__c,BusinessLevel__c, RecordType.Name,CompanyCode__c from opportunity where  OwnerId = : u.Id];
            system.debug('ashish lstOpp'+lstOpp);
            
            BulletinBoard__c bulletinRec = new BulletinBoard__c();
       	 	bulletinRec.Name = 'Bulletin Rec3';
        	bulletinRec.Notice__c = true; // V 1.2
       		// bulletinRec.RecordTypeId = '0121s0000008wCnAAI';
        	insert bulletinRec;
            
            TXPmanpower__c tt = new TXPmanpower__c();
            
            tt.ProposalPMStatus__c = null;
            tt.companycode__c = 'SDS-123456';
            tt.BOCode__c ='SDS-123456';
            tt.Opportunity__c  = oppty.id;
            insert tt;
            
             TXPmanpower__c tt1 = new TXPmanpower__c();
            
            tt1.ProposalPMStatus__c = 'test';
            tt1.companycode__c = 'SDS-123457';
            tt1.BOCode__c ='SDS-123457';
            tt1.P_Projectcode__c ='pCode123';
            tt1.Opportunity__c  = oppty.id;
            tt1.ProposalPMStDt__c = Date.valueOf('2020-12-21');
            tt1.ProposalPMEdDt__c = Date.valueOf('2024-01-21');
            insert tt1;
            Project__c pp = new Project__c();
            pp.Opportunity__c = oppty.id;
            pp.ProjectCode__c = 'pCode123';
            pp.name='testproject';
            insert pp;
        
            test.startTest();
            Batch_ManagerTest_SalesReport_Overseas obj = new Batch_ManagerTest_SalesReport_Overseas();
            database.executeBatch(obj);
        	test.stopTest();
    }
    
    /*@isTest
    public static void testWeeklySalesBatch3(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Manager(HQ)' ];
        List<user> ulist = new List<user>();
        if(isSandbox) ulist = [ Select Id , name, Profile.Name,Email from User where  Profile.Name = 'Sales Manager(HQ)'  AND IsActive = true ];
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
                EvMailAddr__c = 'trust.park@samsung.com',
                EvUniqID__c = 'k123456789',
                Knox_Id__c = 'knoxId5',
                EvKostl__c = 'T100-12210'
            );
            insert emp;
            Employee__c emp1 = new Employee__c(
                    Name = 'testUser1',
                    EvMailAddr__c = 'dragon7@samsung.com',
                    EvTitleJikchakEN__c = 'Group Leader',
                    EvUniqID__c = 'k123454789',
                    Knox_Id__c = 'knoxId5',
                    EvKostl__c = 'T100-12210'
                );
                insert emp1;
            
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
        
        
        Batch_ManagerWeeklySalesReportClone obj = new Batch_ManagerWeeklySalesReportClone();
        database.executeBatch(obj);
    }
    @isTest
    public static void testWeeklySalesBatch4(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Manager(HQ)' ];
        List<user> ulist = new List<user>();
        if(isSandbox) ulist = [ Select Id , name, Profile.Name,Email from User where  Profile.Name = 'Sales Manager(HQ)'  AND IsActive = true ];
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
                EvMailAddr__c = 'trust.park@samsung.com',
                EvUniqID__c = 'k123456789',
                Knox_Id__c = 'knoxId5',
                EvKostl__c = 'T100-12210'
            );
            insert emp;
            Employee__c emp1 = new Employee__c(
                    Name = 'testUser1',
                    EvMailAddr__c = 'dragon7@samsung.com',
                    EvTitleJikchakEN__c = 'Group Leader',
                    EvUniqID__c = 'k123455789',
                    Knox_Id__c = 'knoxId5',
                    EvKostl__c = 'T100-12210'
                );
                insert emp1;
            
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
        
        
        Batch_ManagerWeeklySalesReportClone obj = new Batch_ManagerWeeklySalesReportClone();
        database.executeBatch(obj);
    }
    @isTest
    public static void testWeeklySalesBatch5(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Manager(HQ)' ];
        List<user> ulist = new List<user>();
        if(isSandbox) ulist = [ Select Id , name, Profile.Name,Email from User where  Profile.Name = 'Sales Manager(HQ)'  AND IsActive = true ];
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
                EvMailAddr__c = 'trust.park@samsung.com',
                EvUniqID__c = 'k123456789',
                Knox_Id__c = 'knoxId5',
                EvKostl__c = 'T100-12210'
            );
            insert emp;
            Employee__c emp1 = new Employee__c(
                    Name = 'testUser1',
                    EvMailAddr__c = 'dragon7@samsung.com',
                    EvTitleJikchakEN__c = 'Group Leader',
                    EvUniqID__c = 'k123457789',
                    Knox_Id__c = 'knoxId5',
                    EvKostl__c = 'T100-12210'
                );
                insert emp1;
            
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
        
        
        Batch_ManagerWeeklySalesReport obj = new Batch_ManagerWeeklySalesReport();
        database.executeBatch(obj);
    }
    @isTest
    public static void testWeeklySalesBatch6(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Manager(HQ)' ];
        List<user> ulist = new List<user>();
        if(isSandbox) ulist = [ Select Id , name, Profile.Name,Email from User where  Profile.Name = 'Sales Manager(HQ)'  AND IsActive = true ];
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
                EvMailAddr__c = 'trust.park@samsung.com',
                EvUniqID__c = 'k123456789',
                Knox_Id__c = 'knoxId5',
                EvKostl__c = 'T100-12210'
            );
            insert emp;
            Employee__c emp1 = new Employee__c(
                    Name = 'testUser1',
                    EvMailAddr__c = 'dragon7@samsung.com',
                    EvTitleJikchakEN__c = 'Group Leader',
                    EvUniqID__c = 'k123458789',
                    Knox_Id__c = 'knoxId5',
                    EvKostl__c = 'T100-12210'
                );
                insert emp1;
            
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
        
        
        Batch_ManagerWeeklySalesReport obj = new Batch_ManagerWeeklySalesReport();
        database.executeBatch(obj);
    }*/
    @isTest
        public static void testWeeklySalesBatchAtul(){
            List<User> alluser = [select id , name from user]; 
            system.debug('allUser' + alluser.size() + 'name--' + alluser[0].name);
            List<user> ulist = new List<user>();
            if(isSandbox) ulist = [ Select Id , name, Profile.Name,Email from User where  Profile.Name = 'Sales Manager(Overseas Corp)'  AND IsActive = true ];
            else ulist = [ Select Id , name, Profile.Name,Email from User where Name = '곽 승동' AND IsActive = true ];
            system.debug('ash ulist'+ulist);
            system.debug('adi ulist size '+ulist.size());
            RecordType recordId = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'HQ' Limit 1];
            Account acc = [select id,name from Account where name = 'Test Account' Limit 1];
            CostCenter__c costCenterHQ = [select id,name,CompanyCode__c from CostCenter__c where name = '기술전략팀(T201-10384)' Limit 1];
            System.debug('Cost Center Company Code : ' + costCenterHQ.CompanyCode__c);
            User u = [select id,name from user where email = 'Test1@Test.com' Limit 1];
            User u1 = [select id,name from user where email = 'Test2@Test.com' Limit 1];
            
            DateTime dt = DateTime.now().addDays(-7);

            Opportunity oppty = new Opportunity(Name ='Test', RecordTypeId = recordId.Id, AccountId =acc.Id, CurrencyIsoCode = 'KRW', Amount = 1010000,
                                cRevenueStartDate__c = system.today()-5, cRevenueEndDate__c = System.today().addMonths(2), 
                                CloseDate = System.today().addMonths(2), StageName = 'Z01', cPrimarySalesDepartment__c = costCenterHQ.Id,
            					SalesDepartment__c = costCenterHQ.Id, cOriginAcc__c = acc.Id, CspMspType__c = 'CSP',
            					OtherCSP__c = 'CSP1', MSP_Amount__c = 200, cLeadID__c = NULL, Opportunitycode__c= 'SDS-123456');
            Opportunity oppty9 = new Opportunity(Name ='Test', RecordTypeId = recordId.Id, AccountId =acc.Id, CurrencyIsoCode = 'KRW', Amount = 1010000,
                                cRevenueStartDate__c = system.today()-5, cRevenueEndDate__c = System.today().addMonths(2), 
                                CloseDate = System.today().addMonths(2), StageName = 'Z01', cPrimarySalesDepartment__c = costCenterHQ.Id,
            					SalesDepartment__c = costCenterHQ.Id, cOriginAcc__c = acc.Id, CspMspType__c = 'CSP',
            					OtherCSP__c = 'CSP1', MSP_Amount__c = 200, cLeadID__c = NULL, Opportunitycode__c= 'SDS-123457');
            
          
            system.runAs(u1){
                Id ProfileId = UserInfo.getProfileId();
                Id CurrentUser = userinfo.getUserid();
                String CurrentCompanyCode = [select id,name,CompanyCode__c from user where id =: CurrentUser].CompanyCode__c;
                String ProfileName = [select id,name from profile where id =: ProfileId].Name;
                system.debug('Current user profile : '+ ProfileName + ' SalesDepartment__c Closed : '+ oppty.SalesDepartment__r.Closed__c + ' Current user Company code : '+ CurrentCompanyCode + 'Oppty Comapny Code : ' + oppty.SalesDepartment__r.CompanyCode__c + 'Oppty ZZCode : ' + oppty.SalesDepartment__r.ZZCheck__c + 'Opp Owner Id: ' + oppty.ownerId + ' Current user Id : '+ CurrentUser);
                insert oppty;
                insert oppty9;
            }
            oppty = [select id, name, companycode__c from opportunity where id =: oppty.id];
            oppty9 = [select id, name, companycode__c from opportunity where id =: oppty9.id];
            System.debug('--->Inserted oppty from method : '+ oppty.CompanyCode__c);
              TXPmanpower__c tt = new TXPmanpower__c();
            
            tt.ProposalPMStatus__c = null;
            tt.companycode__c = 'SDS-123456';
            tt.BOCode__c ='SDS-123456';
            tt.Opportunity__c  = oppty.id;
            insert tt;
            
             TXPmanpower__c tt1 = new TXPmanpower__c();
            
            tt1.ProposalPMStatus__c = 'test';
            tt1.companycode__c = 'SDS-123457';
            tt1.BOCode__c ='SDS-123457';
            tt1.P_Projectcode__c ='pCode123';
            tt1.Opportunity__c  = oppty9.id;
            tt1.ProposalPMStDt__c = Date.valueOf('2020-12-21');
            tt1.ProposalPMEdDt__c = Date.valueOf('2024-01-21');
            insert tt1;
            Project__c pp = new Project__c();
            pp.Opportunity__c = oppty.id;
            pp.ProjectCode__c = 'pCode123';
            pp.name='testproject';
            insert pp;
            Opportunity oppty1 = new Opportunity(Name ='TestAdi', RecordTypeId = recordId.Id, AccountId =acc.Id, CurrencyIsoCode = 'KRW', Amount = 1000001,
                                cRevenueStartDate__c = system.today(), cRevenueEndDate__c = System.today().addMonths(2), 
                                CloseDate = System.today().addMonths(2), StageName = 'Z01', cPrimarySalesDepartment__c = costCenterHQ.Id,
            					SalesDepartment__c = costCenterHQ.Id, cOriginAcc__c = acc.Id, CspMspType__c = 'CSP', 
            					OtherCSP__c = 'CSP1', MSP_Amount__c = 200, cLeadID__c = NULL, Opportunitycode__c= 'SDS-123456');
            system.runAs(u1){
                insert oppty1;
            }
            oppty1 = [select id, name, companycode__c from opportunity where id =: oppty1.id];
            System.debug('--->Inserted oppty1 from method : '+ oppty1.CompanyCode__c);
            
            aggregateResult aggres = [select max(owner.CostCenter_Level_4__c),owner.EvKostl__c from opportunity where recordtype.name = 'HQ' and companycode__c = 'T201' and owner.evkostl__c != null group by owner.EvKostl__c];
            system.debug('Agg Result ---> ' + aggres + '  Aggs evkostal : '+ aggres.get('EvKostl__c'));
                
            opportunityamt__c oppamt = new opportunityamt__c(name = 'Test', Opportunitycode__c= 'SDS-123456', Companycode__c= 'T201', Version__c= 'S001', CurrencyIsoCode= 'KRW', Opportunity__c= oppty.Id, DiffAmtUSD__c= 1000,DiffAmt__c = 1000);
            insert oppamt;
            
            WeeklyReport__c weere = new WeeklyReport__c(name = 'Test', ReportingDate__c = system.today(), Opportunity__c = oppty.id);
            insert weere;
            
            WeeklyReport__c weere1 = new WeeklyReport__c(name = 'Test1', ReportingDate__c = system.today(), Opportunity__c = oppty1.id);
            insert weere1;
            
            List<Opportunity> lstOpp = new List<Opportunity>();
            lstOpp = [select Id, Amount,Name,OpportunityCode__c,ZP61_PROPOSAL_SUBMIT_DATE__c,ProposalPM__c,ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name,cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, StageName,BO1stRegistrationDate__c,CloseDate,XP7_CONDUCT_DATE__c,XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId,Account.Owner.Name,Account.Name,OriginAcc_BizTypeL1__c,BusinessLevel__c, RecordType.Name,CompanyCode__c from opportunity where  OwnerId = : u.Id];
            system.debug('ashish lstOpp'+lstOpp);
            
            BulletinBoard__c bulletinRec = new BulletinBoard__c();
       	 	bulletinRec.Name = 'Bulletin Rec1';
        	bulletinRec.Notice__c = true; // V 1.2
       		// bulletinRec.RecordTypeId = '0121s0000008wCnAAI';
        	insert bulletinRec;
            
            test.startTest();
            Batch_ManagerTest_SalesReport_Overseas obj = new Batch_ManagerTest_SalesReport_Overseas();
            database.executeBatch(obj);
            test.stopTest();
        }
    @isTest
        public static void testWeeklySalesBatchAtul2(){
            List<User> alluser = [select id , name from user]; 
            system.debug('allUser' + alluser.size() + 'name--' + alluser[0].name);
            List<user> ulist = new List<user>();
            if(isSandbox) ulist = [ Select Id , name, Profile.Name,Email from User where  Profile.Name = 'Sales Manager(Overseas Corp)'  AND IsActive = true ];
            else ulist = [ Select Id , name, Profile.Name,Email from User where Name = '곽 승동' AND IsActive = true ];
            system.debug('ash ulist'+ulist);
            system.debug('adi ulist size '+ulist.size());
            RecordType recordId = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'HQ' Limit 1];
            Account acc = [select id,name from Account where name = 'Test Account' Limit 1];
            CostCenter__c costCenterHQ = [select id,name,CompanyCode__c from CostCenter__c where name = '기술전략팀(T201-10384)' Limit 1];
            System.debug('Cost Center Company Code : ' + costCenterHQ.CompanyCode__c);
            User u = [select id,name from user where email = 'Test1@Test.com' Limit 1];
            User u1 = [select id,name from user where email = 'Test2@Test.com' Limit 1];
            
            DateTime dt = DateTime.now().addDays(-7);

            Opportunity oppty = new Opportunity(Name ='Test', RecordTypeId = recordId.Id, AccountId =acc.Id, CurrencyIsoCode = 'KRW', Amount = 1010000,
                                cRevenueStartDate__c = system.today()-5, cRevenueEndDate__c = System.today().addMonths(2), 
                                CloseDate = System.today().addMonths(2), StageName = 'Z01', cPrimarySalesDepartment__c = costCenterHQ.Id,
            					SalesDepartment__c = costCenterHQ.Id, cOriginAcc__c = acc.Id, CspMspType__c = 'CSP',
            					OtherCSP__c = 'CSP1', MSP_Amount__c = 200, cLeadID__c = NULL, Opportunitycode__c= 'SDS-123444');
            Opportunity oppty9 = new Opportunity(Name ='Test', RecordTypeId = recordId.Id, AccountId =acc.Id, CurrencyIsoCode = 'KRW', Amount = 1010000,
                                cRevenueStartDate__c = system.today()-5, cRevenueEndDate__c = System.today().addMonths(2), 
                                CloseDate = System.today().addMonths(2), StageName = 'Z01', cPrimarySalesDepartment__c = costCenterHQ.Id,
            					SalesDepartment__c = costCenterHQ.Id, cOriginAcc__c = acc.Id, CspMspType__c = 'CSP',
            					OtherCSP__c = 'CSP1', MSP_Amount__c = 200, cLeadID__c = NULL, Opportunitycode__c= 'SDS-123555');
            
          
            system.runAs(u1){
                Id ProfileId = UserInfo.getProfileId();
                Id CurrentUser = userinfo.getUserid();
                String CurrentCompanyCode = [select id,name,CompanyCode__c from user where id =: CurrentUser].CompanyCode__c;
                String ProfileName = [select id,name from profile where id =: ProfileId].Name;
                system.debug('Current user profile : '+ ProfileName + ' SalesDepartment__c Closed : '+ oppty.SalesDepartment__r.Closed__c + ' Current user Company code : '+ CurrentCompanyCode + 'Oppty Comapny Code : ' + oppty.SalesDepartment__r.CompanyCode__c + 'Oppty ZZCode : ' + oppty.SalesDepartment__r.ZZCheck__c + 'Opp Owner Id: ' + oppty.ownerId + ' Current user Id : '+ CurrentUser);
                insert oppty;
                insert oppty9;
            }
            oppty = [select id, name, companycode__c from opportunity where id =: oppty.id];
            oppty9 = [select id, name, companycode__c from opportunity where id =: oppty9.id];
            System.debug('--->Inserted oppty from method : '+ oppty.CompanyCode__c);
            List<TXPmanpower__c> txpLst = new List<TXPmanpower__c>();
             List<Project__c> allProjects = new  List<Project__c>();
              TXPmanpower__c tt = new TXPmanpower__c();
            
            tt.ProposalPMStatus__c = null;
            tt.companycode__c = 'SSDS-123444';
            tt.BOCode__c ='SDS-123444';
            tt.Opportunity__c  = oppty.id;
            insert tt;
            txpLst.add(tt);
            
             TXPmanpower__c tt1 = new TXPmanpower__c();
            
            tt1.ProposalPMStatus__c = null;
            tt1.companycode__c = 'SDS-123555';
            tt1.BOCode__c ='SDS-123555';
            tt1.P_Projectcode__c ='pCode111';
            tt1.Opportunity__c  = oppty9.id;
           tt1.ProposalPMStDt__c = Date.valueOf('2020-12-21');
            tt1.ProposalPMEdDt__c = Date.valueOf('2024-01-21');
            insert tt1;
           txpLst.add(tt1);
            Project__c pp = new Project__c();
            pp.Opportunity__c = oppty.id;
            pp.ProjectCode__c = 'pCode111';
            pp.name='testproject';
            insert pp;
            allProjects.add(pp);
            Opportunity oppty1 = new Opportunity(Name ='TestAtul', RecordTypeId = recordId.Id, AccountId =acc.Id, CurrencyIsoCode = 'KRW', Amount = 1000001,
                                cRevenueStartDate__c = system.today(), cRevenueEndDate__c = System.today().addMonths(2), 
                                CloseDate = System.today().addMonths(2), StageName = 'Z01', cPrimarySalesDepartment__c = costCenterHQ.Id,
            					SalesDepartment__c = costCenterHQ.Id, cOriginAcc__c = acc.Id, CspMspType__c = 'CSP', 
            					OtherCSP__c = 'CSP1', MSP_Amount__c = 200, cLeadID__c = NULL, Opportunitycode__c= 'SDS-123444');
            system.runAs(u1){
                insert oppty1;
            }
            oppty1 = [select id, name, companycode__c from opportunity where id =: oppty1.id];
            System.debug('--->Inserted oppty1 from method : '+ oppty1.CompanyCode__c);
            
            aggregateResult aggres = [select max(owner.CostCenter_Level_4__c),owner.EvKostl__c from opportunity where recordtype.name = 'HQ' and companycode__c = 'T201' and owner.evkostl__c != null group by owner.EvKostl__c];
            system.debug('Agg Result ---> ' + aggres + '  Aggs evkostal : '+ aggres.get('EvKostl__c'));
                
            opportunityamt__c oppamt = new opportunityamt__c(name = 'Test', Opportunitycode__c= 'SDS-123444', Companycode__c= 'T201', Version__c= 'S001', CurrencyIsoCode= 'KRW', Opportunity__c= oppty.Id, DiffAmtUSD__c= 1000001,DiffAmt__c = 1000001);
            insert oppamt;
            
            WeeklyReport__c weere = new WeeklyReport__c(name = 'Test', ReportingDate__c = system.today(), Opportunity__c = oppty.id);
            insert weere;
            
            WeeklyReport__c weere1 = new WeeklyReport__c(name = 'Test1', ReportingDate__c = system.today(), Opportunity__c = oppty1.id);
            insert weere1;
            
            List<Opportunity> lstOpp = new List<Opportunity>();
            lstOpp = [select Id, Amount,Name,OpportunityCode__c,ZP61_PROPOSAL_SUBMIT_DATE__c,ProposalPM__c,ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name,cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, StageName,BO1stRegistrationDate__c,CloseDate,XP7_CONDUCT_DATE__c,XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId,Account.Owner.Name,Account.Name,OriginAcc_BizTypeL1__c,BusinessLevel__c, RecordType.Name,CompanyCode__c from opportunity where  OwnerId = : u.Id];
            system.debug('ashish lstOpp'+lstOpp);
            
            BulletinBoard__c bulletinRec = new BulletinBoard__c();
       	 	bulletinRec.Name = 'Bulletin Rec5';
        	bulletinRec.Notice__c = true; // V 1.2
       		// bulletinRec.RecordTypeId = '0121s0000008wCnAAI';
        	insert bulletinRec;
            
            test.startTest();
            Batch_ManagerTest_SalesReport_Overseas obj = new Batch_ManagerTest_SalesReport_Overseas();
            database.executeBatch(obj);
            //Batch_ManagerWeeklySalesReportClone.getTable6ProposalPMData(txpLst,allProjects,oppty);            
            test.stopTest();
        }

    
    @isTest
    public static void noOppty(){
        Batch_ManagerTest_SalesReport_Overseas obj = new Batch_ManagerTest_SalesReport_Overseas();
        database.executeBatch(obj);
        Batch_ManagerTest_SalesReport_Overseas.tempCoverage();
    }
    
   
}