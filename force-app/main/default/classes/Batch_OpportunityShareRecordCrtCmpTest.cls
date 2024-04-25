/**
 * @author            : sarthak.j1@samsung.com
 * @group             : 
 * @description       : Test Class for Batch_OpportunityShareRecordCreateComp
 * @last modified on  : 2024-03-28
 * @last modified by  : sarthak.j1@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2024-03-22   sarthak.j1@samsung.com   Initial Version
**/
@isTest(SeeAllData=false)
public class Batch_OpportunityShareRecordCrtCmpTest {
 
    static testMethod  void testBatch1() {
        
         String recordTypeId = String.valueOf([SELECT Id FROM RecordType WHERE DeveloperName = 'HQ' AND SobjectType = 'Opportunity' LIMIT 1].Id);
         Account acc;
         Organization__c org;
         Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자' LIMIT 1];
         User u;
         Employee__c emp;
         CostCenter__c costCenter;
         Company__c cmp;
      
         cmp = new Company__c(
                Name = 'comptest',
                CompanyCode__c = 'T100'
         );
         insert cmp;
            
         acc = new Account(
            Name = 'a_name',
            MDGCheck__c = true
         );
         insert acc;
        
         org = new Organization__c(
            Name = 'test',
            Region__c = 'H'
         );
         insert org;
        
         u = new User(
            Alias = 'tU467',
            Email='SysAdminTestuser467@dkbmc.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing467',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            EmployeeNumber='k123456789467',
            TimeZoneSidKey='Asia/Seoul',
            UserName='SATuser467@samsung.com',
            ProfileId = pf.Id,
            EvKostl__c = 'T604-11331',
            FederationIdentifier = 'k123456789467'
         );
         insert u;
        
         emp = new Employee__c(
            Name = 'tU467',
            EvMailAddr__c = 'SysAdminTestuser467@samsung.com',
            EvUniqID__c = 'k123456789467',
            Knox_Id__c = 'knoxId5467',
            EvKostl__c = 'T100-11331'
         );
         insert emp;
         
         costCenter = new CostCenter__c(
            Name                = 'MYSALES-467 Test'
            , DeptManager__c    = emp.Id
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T100'
            , CostCenterName__c = 'MYSALES-467 Test'
            , Company__c = cmp.Id
            , CostCenter__c     = 'T100-11331'
            , Node1__c          = 'T100'
            , Node2__c          = 'T100S4'
            , Node3__c          = 'T100S3B1'
            , Node4__c          = 'T100S313'
            , Node5__c          = 'T100S3131'            
         );
         insert costCenter;
        
        Opportunity opp1;
        Opportunity opp2;
        
        List<Opportunity> opList = new List<Opportunity>();
        
        opp1 = new Opportunity(
            Name = 'OpportunityTest',
            AccountId = acc.Id,
            SalesDepartment__c = costCenter.Id,
            cPrimarySalesDepartment__c = costCenter.Id,
            OpportunityCode__c = 'oppCode',
            ActivityStatus__c = 'ZAC4',
            StageName = 'Z03',
            CloseDate = Date.today().addDays(-14),
            RecordTypeId = recordTypeId,
            FirstCloseDate__c = Date.today(),
            OwnerId = u.Id
            
        );       
        opList.add(opp1);
        
        opp2 = new Opportunity(
            Name = 'OpportunityTest2',
            AccountId = acc.Id,
            SalesDepartment__c = costCenter.Id,
            cPrimarySalesDepartment__c = costCenter.Id,
            OpportunityCode__c = 'oppCode',
            ActivityStatus__c = 'ZAC4',
            StageName = 'Z03',
            CloseDate = Date.today().addDays(-14),
            RecordTypeId = recordTypeId,
            FirstCloseDate__c = Date.today(),
            OwnerId = u.Id  
        );
        opList.add(opp2);
        
        insert opList;
        
        List<Group> listofcloudRole = [Select Id from Group Where (DeveloperName = 'mig20005' OR DeveloperName = 'mig20002')
                                       AND type = 'RoleAndSubordinates'ORDER By DeveloperName desc limit 2];
        
        List<OpportunityShare> opShareList = new List<OpportunityShare>();
        
        OpportunityShare optyShare = new OpportunityShare();
         optyShare.OpportunityId = opp1.Id;
         optyShare.UserOrGroupId = listofcloudRole[0].Id;
         optyShare.OpportunityAccessLevel = 'Read';
         optyShare.RowCause = 'Manual';
         opShareList.add(optyShare);
        
        insert opShareList; 
        
        Test.startTest();
        
        Batch_OpportunityShareRecordCreateComp batch = new Batch_OpportunityShareRecordCreateComp();
        Database.executeBatch(batch, 200);

        Test.stopTest();
    }
    
    @isTest
    public static void schedule_test() {
        Test.startTest();
        System.schedule('Batch_OpportunityShareRecordCreateComp Job 1', '0 00 * * * ?', new Batch_OpportunityShareRecordCreateComp());
        System.schedule('Batch_OpportunityShareRecordCreateComp Job 2', '0 30 * * * ?', new Batch_OpportunityShareRecordCreateComp());
        Test.stopTest();
    }
}