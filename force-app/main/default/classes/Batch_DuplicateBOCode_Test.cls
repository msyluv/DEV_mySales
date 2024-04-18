/**
* @description       : Test class of Batch_ManagerWeeklySalesReport 
* @author            : kajal.c@samsung.com
* @group             : 
* @last modified on  : 2024-04-11
* @last modified by  : kajal.c@samsung.com
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2024-04-11   kajal.c@samsung.com   Initial Version
**/
@isTest(SeeAllData=false)
public class Batch_DuplicateBOCode_Test {
    private static Boolean isSandbox = Utils.getIsSandbox();
    
    @testSetup static void setup(){
		
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Manager(HQ)' ];
        Profile p1 = [SELECT Id FROM Profile WHERE Name = 'Sales Rep.(HQ)' ];
        User u = new User(Alias = '박 재만', Email='testsa@test.com', 
                              EmailEncodingKey='UTF-8', LastName='박 재만', FirstName='박 재만', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                              UserName='user0001@samsung.com' ,IsActive = true, EvKostl__c = 'T100-10384', CompanyCode__c = 'T100', CostCenter_Level_5__c = '기술전략팀(T100-10384)');
        insert u;
        system.debug('Inserted User : '+ u);
        
        User u1 = new User(Alias = '박 재만1', Email='test1@test.com', 
                              EmailEncodingKey='UTF-8', LastName='박 재만', FirstName='박 재만1', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p1.Id, TimeZoneSidKey='Asia/Seoul', 
                              UserName='user0002@samsung.com' ,IsActive = true, EvKostl__c = 'T100-10384', CompanyCode__c = 'T100', CostCenter_Level_5__c = '기술전략팀(T100-10384)');
        insert u1;
        system.debug('Inserted User1 : '+ u1);
        
        User u2 = new User(Alias = '박 재만2', Email='test2@test.com', 
                              EmailEncodingKey='UTF-8', LastName='박 재만', FirstName='박 재만2', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p1.Id, TimeZoneSidKey='Asia/Seoul', 
                              UserName='user0003@samsung.com' ,IsActive = true, EvKostl__c = 'T100-10384', CompanyCode__c = 'T100', CostCenter_Level_5__c = '기술전략팀(T100-10384)');
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
                    CompanyCode__c = 'T100'
                );
        insert cmp;
        system.debug('Inserted Company : '+ cmp);
            
        Company__c cmp1 = new Company__c(
                    Name = 'comp1',
                    CompanyCode__c = 'T100'
                );
        insert cmp1;
        system.debug('Inserted Company : '+ cmp1);
            
        Company__c cmp2 = new Company__c(
                    Name = 'comp2',
                    CompanyCode__c = 'T100'
                );
        insert cmp2;
        system.debug('Inserted Company : '+ cmp2);
        
		Employee__c emp = new Employee__c(
                    Name = 'testUser',
                    EvMailAddr__c = 'test@test.com',
                    EvTitleJikchakEN__c = 'Group Leader',
                    EvUniqID__c = 'k123451789',
                    Knox_Id__c = 'knoxId5',
                    EvKostl__c = 'T100-10384'
                );
        insert emp;
        system.debug('Inserted Employee : '+ emp);

        Employee__c emp1 = new Employee__c(
                    Name = 'testUser1',
                    EvMailAddr__c = 'test1@test.com',
                    EvUniqID__c = 'k123456789',
                    Knox_Id__c = 'knoxId6',
                    EvKostl__c = 'T100-10384'
                );
        insert emp1;
        system.debug('Inserted Employee1 : '+ emp1);
            
        Employee__c emp2 = new Employee__c(
                    Name = 'testUser2',
                    EvMailAddr__c = 'test2@test.com',
                    EvUniqID__c = 'k123457789',
                    Knox_Id__c = 'knoxId7',
                    EvKostl__c = 'T100-10384'
                );
        insert emp2;
        system.debug('Inserted Employee1 : '+ emp2);
        
        CostCenter__c costCenter1 = new CostCenter__c(
                    Name                = '기술전략팀(T100-10384)'
                    , DeptManager__c    = emp.Id
                    , CurrencyIsoCode   = 'KRW'
                    , CompanyCode__c    = 'T100'
                    , CostCenterName__c = '기술전략팀'
                    , Company__c = cmp.Id
                    , CostCenter__c     = 'T100-10384'
                    , Node1__c          = 'T100'
                    , Node2__c          = 'T100SB'
                    , Node3__c          = 'T100SB1'
                    , Node4__c          = 'T100SB13'
                    , Node5__c          = 'T100SB131'
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
            
         Opportunity oppty = new Opportunity(
            Name = 'Test Opportunity', 
            OwnerId = u.Id,
            AccountId = acc.Id,
            StageName = 'Z01',
            Type = 'New Business',
            LeadSource = 'Other',
            CloseDate = System.today(),
            cPrimarySalesDepartment__c = costCenter1.Id,
            SalesDepartment__c = costCenter1.Id
        );
            
        insert oppty;
        
        
        }
        
    }
    
   
    @isTest
    public static void noOppty(){
        Batch_DuplicateBOCode obj = new Batch_DuplicateBOCode();
        database.executeBatch(obj);
        //Batch_ManagerWeeklySalesReportClone.tempCoverage();
        Id batchJobId = Database.executeBatch(new Batch_DuplicateBOCode(), 200); 
    }
    
   
}