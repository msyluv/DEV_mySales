@istest
public class Batch_OpportunityExcelGenerate_Test {
	static String recordTypeId = String.valueOf([SELECT Id FROM RecordType WHERE DeveloperName = 'HQ' AND SobjectType = 'Opportunity' LIMIT 1].Id);
    static Account acc;
    static Organization__c org;
    static Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자' LIMIT 1];
    static User u;
    static Employee__c emp;
    static CostCenter__c costCenter;
    static Company__c cmp;
    static {
        cmp = new Company__c(
            Name = 'comp',
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
            Alias = 'testUser',
            Email='SysAdminTestuser@dkbmc.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            EmployeeNumber='k123456789',
            TimeZoneSidKey='Asia/Seoul',
            UserName='SysAdminTestuser@samsung.com',
            ProfileId = pf.Id,
            EvKostl__c = 'T604-11331',
            FederationIdentifier = 'k123456789'
        );
        insert u;
        emp = new Employee__c(
            Name = 'testUser',
            EvMailAddr__c = 'SysAdminTestuser@samsung.com',
            EvUniqID__c = 'k123456789',
            Knox_Id__c = 'knoxId5',
            EvKostl__c = 'T604-11331'
        );
        insert emp;
        
        costCenter = new CostCenter__c(
            Name                = '기술전략팀(T604-11331)'
            , DeptManager__c    = emp.Id
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T604'
            , CostCenterName__c = '기술전략팀'
            , Company__c = cmp.Id
            , CostCenter__c     = 'T604-11331'
            , Node1__c          = 'T604'
            , Node2__c          = 'T604SB'
            , Node3__c          = 'T604SB1'
            , Node4__c          = 'T604SB13'
            , Node5__c          = 'T604SB131'            
        );
        insert costCenter;
    }
    
    @isTest
    public static void Test_Batch_OpportunityExcelGenerate(){
		Opportunity opp1;
        Opportunity opp2;
        Opportunity opp3;
        //SalesDepartment__r.Company__r.CompanyCode__c
        opp1 = new Opportunity(
            Name = 'opportunity',
            AccountId = acc.Id,
            SalesDepartment__c = costCenter.Id,
            OpportunityCode__c = 'oppCode',
            ActivityStatus__c = 'ZAC4',
            StageName = 'Z03',
            CloseDate = Date.today().addDays(-14),
            RecordTypeId = recordTypeId,
            FirstCloseDate__c = Date.today(),
            OwnerId = u.Id
            		 //00e2w000002RvtEAAS
            
        );
        insert opp1;
        
        opp2 = new Opportunity(
            Name = 'opportunity',
            AccountId = acc.Id,
            SalesDepartment__c = costCenter.Id,
            OpportunityCode__c = 'oppCode',
            ActivityStatus__c = 'ZAC4',
            StageName = 'Z04',
            cRevenueStartDate__c = Date.today().addDays(14),
            CloseDate = Date.today().addDays(-21),
            RecordTypeId = recordTypeId,
            OwnerId = u.Id
        );
        insert opp2;
		opp3 = new Opportunity(
            Name = 'opportunity',
            AccountId = acc.Id,
            SalesDepartment__c = costCenter.Id,
            OpportunityCode__c = 'oppCode',
            ActivityStatus__c = 'ZAC4',
            StageName = 'Z01',
            LogisticsCustomerType__c = 'EXTAC',
            LBSExceptionType__c = '08',
            cRevenueStartDate__c = Date.today().addDays(14),
            CloseDate = Date.today().addDays(14),
            RecordTypeId = recordTypeId,
            OwnerId = u.Id
        );
        insert opp3;
        
        Test.startTest();

        Set<Id> testIdSet = new Set<Id>();
        testIdSet.add(opp1.Id);
        Batch_OpportunityExcelGenerate bo = new Batch_OpportunityExcelGenerate(testIdSet);
        DataBase.executeBatch( bo, 50);

        Test.stopTest();
    }
}