/**
 * @description       : 
 * @author            : chae_ho.yang@samsung.com
 * @group             : 
 * @last modified on  : 12-29-2022
 * @last modified by  : chae_ho.yang@samsung.com
**/

@isTest
public class OpportunityManualSharingTrigger_Test {
    
    public static Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    public static String cloudRoleId; // 클라우드서비스사업부
    
    @isTest
    public static void OpportunityEdit() {

        if (isSandbox) cloudRoleId = '00G1s000001x10zEAA';
        else cloudRoleId = '00G2w000000kO4cEAE';

        Opportunity newOpty;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
        
        User user = new User(Alias = 'standt1', Email='user0001@samsung.com', 
        EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
        UserName='user0001@samsung.com', FederationIdentifier='16241');
        insert user;

        Company__c comp = new Company__c(
            Name = 'Test Company',
            CompanyCode__c = 'T100'
        );
        insert comp;

        CostCenter__c cc = new CostCenter__c(
            Name = 'Test Cost Center', 
            Company__c = comp.Id,
            CompanyCode__c = 'T100', 
            Node2__c = 'T100S3',
            Text2__c = '테스트'
        );
        insert cc;

        RecordType mdgRcdType = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType WHERE SobjectType = 'Account' AND IsActive = TRUE AND Name LIKE '%MDG%'];
        Account mdgAcc = new Account(
			Name = 'Test MDG Account',
            AccountNumber = 'M1234567',
            mDomesticForeign__c = '20',
            mCountry__c = 'US',
            RecordTypeId = mdgRcdType.Id,
            MDGCheck__c = true
       	);
        insert mdgAcc;

        RecordType hqRcdType = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'HQ'];
        newOpty = new Opportunity(
            Name = 'Test Opportunity', 
            RecordTypeId = hqRcdType.Id,
            StageName = 'Z01', 
            AccountId = mdgAcc.Id, 
            OwnerId = user.Id, 
            SalesDepartment__c = cc.Id, 
            cPrimarySalesDepartment__c = cc.Id, 
            CloseDate = Date.today(),
            OpportunityCode__c = 'SDS-12345678'
        );
        insert newOpty;

        newOpty.cPrimarySalesDepartment__c = null;
        update newOpty;

        newOpty.cPrimarySalesDepartment__c = cc.Id;
        update newOpty;
    }
}