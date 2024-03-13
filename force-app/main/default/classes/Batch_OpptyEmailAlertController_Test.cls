/**
 * @description       : 
 * @author            : Junghwa.Kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-02-09
 * @last modified by  : Junghwa.Kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   2021-01-22   Junghwa.Kim@dkbmc.com   Initial Version
**/
@istest
public class Batch_OpptyEmailAlertController_Test {
    static String recordTypeId = String.valueOf([SELECT Id FROM RecordType WHERE DeveloperName = 'Logistics' AND SobjectType = 'Opportunity' LIMIT 1].Id);
    static Account acc;
    static Organization__c org;
    static Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자' LIMIT 1];
    static User u;
    static Employee__c emp;
    static {
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
            FederationIdentifier = 'k123456789'
        );
        insert u;
        emp = new Employee__c(
            Name = 'testUser',
            EvMailAddr__c = 'SysAdminTestuser@samsung.com',
            EvUniqID__c = 'k123456789',
            Knox_Id__c = 'knoxId5'
        );
        insert emp;
    }


    @isTest
    public static void Test_Batch_OpptyEmailAlertController(){

        Opportunity opp1;
        Opportunity opp2;
        Opportunity opp3;

        opp1 = new Opportunity(
            Name = 'opportunity',
            AccountId = acc.Id,
            OpportunityCode__c = 'oppCode',
            ActivityStatus__c = 'ZAC4',
            StageName = 'Z03',
            CloseDate = Date.today().addDays(-14),
            RecordTypeId = recordTypeId
        );
        insert opp1;
        opp2 = new Opportunity(
            Name = 'opportunity',
            AccountId = acc.Id,
            OpportunityCode__c = 'oppCode',
            ActivityStatus__c = 'ZAC4',
            StageName = 'Z04',
            cRevenueStartDate__c = Date.today().addDays(14),
            CloseDate = Date.today().addDays(-21),
            RecordTypeId = recordTypeId
        );
        insert opp2;
        Test.setCreatedDate(opp2.Id, Date.today().addDays(-30));
        opp2.cRevenueStartDate__c = Date.today().addDays(14);
        opp2.CloseDate = Date.today().addDays(14);
        opp2.DeliveryOrganization__c = org.Id;
        update opp2;
        opp3 = new Opportunity(
            Name = 'opportunity',
            AccountId = acc.Id,
            OpportunityCode__c = 'oppCode',
            ActivityStatus__c = 'ZAC4',
            StageName = 'Z01',
            LogisticsCustomerType__c = 'EXTAC',
            LBSExceptionType__c = '08',
            cRevenueStartDate__c = Date.today().addDays(14),
            CloseDate = Date.today().addDays(14),
            RecordTypeId = recordTypeId
        );
        insert opp3;
        Test.setCreatedDate(opp3.Id, Date.today().addDays(-30));

        //opp3.cRevenueStartDate__c = Date.today().addDays(-14);
        //opp3.CloseDate = Date.today().addDays(-14);
        update opp3;
        Test.startTest();

        Batch_OpptyEmailAlertController bo = new Batch_OpptyEmailAlertController();
        bo.EMAIL_TEMP = bo.STAGE_CHANGE;
        DataBase.executeBatch( bo, 50);

        //system.schedule('Merge Job', '0 0 13 * * ?', new scheduledMerge());

        Test.stopTest();
    }
}