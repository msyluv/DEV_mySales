/**
 * @description       : 
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-10-28
 * @last modified by  : younghoon.kim@dkbmc.com
**/
@isTest
public class WonLostDropListViewController_Test {
    static User user;
    static Account old_acc;
    static Account new_acc;
    static Company__c hqCompany;
    static CostCenter__c costCenter;
    static Opportunity originOppty;
    static Won_Lost_Drop__c wld;
    static WonLostDropListViewController.customUser cu;
    static WonLostDropListViewController.selectedValue sv;

    static{
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
        list<User> lu = new list<User>();
        user = new User(Alias = 'standt1', Email='user0001@samsung.com', 
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                    UserName='user0001@samsung.com');
        insert user;

        RecordType mdgRcdType = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType WHERE SobjectType = 'Account' AND IsActive = TRUE AND Name LIKE '%MDG%'];
        old_acc = new Account(
            Name = 'Test old Account',
            AccountNumber = 'T100-00',
            RecordTypeId = mdgRcdType.Id,
            MDGCheck__c = true
        );
        insert old_acc;

        new_acc = new Account(
            Name = 'Test new Account'
        );
        insert new_acc;

        hqCompany = new Company__c(
            Name = 'Test HQ Company',
            CompanyCode__c = 'T100'
        );
        insert hqCompany;

        costCenter = new CostCenter__c(
            Name = 'Test Cost Center',
            Company__c = hqCompany.Id
        );
        insert costCenter;

        RecordType hqRcdType = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'HQ'];
        originOppty = new Opportunity(
            Name = 'Test Opportunity', 
            RecordTypeId = hqRcdType.Id,
            SalesDepartment__c = costCenter.Id,
            AccountId = old_acc.Id,
			OwnerId = user.Id,
            StageName = 'Z01',
            CurrencyIsoCode = 'USD',
            Type = 'New Business',
            LeadSource = 'Other',
			CloseDate = System.today(),
            OpportunityCode__c = 'SDS-1234560'
        );
        insert originOppty;

        wld = new Won_Lost_Drop__c(
            Opportunity__c = originOppty.Id,
            Won_Lost_Drop_Type__c = 'Won',
            Won_Lost_Drop_Reason_Type__c = 'Superiority of Capability',
            Date_of_occurrence__c = Date.today(),
            OwnerId = user.Id
        );
        insert wld;

        cu = new WonLostDropListViewController.customUser();
        cu.Id = user.Id;
        cu.Name = user.Name;

        sv = new WonLostDropListViewController.selectedValue();
        sv.Title = 'Test';
        sv.OpptyCode = 'SDS';
        sv.WLDType = 'Won';
        sv.WLDReasonType = 'Superiority of Capability';
        sv.SalesRep = cu;
        sv.Owner = cu;
    }

    @isTest static void test_getFieldLabel() {
		Test.startTest();
        WonLostDropListViewController.getFieldLabel();
		Test.stopTest();
	}

    @isTest static void test_getDataList() {
		Test.startTest();
        WonLostDropListViewController.getDataList(0, 0, JSON.serialize(sv), 'List');
		Test.stopTest();
	}

    @isTest static void test_generateHTML() {
        Test.startTest();
        WonLostDropListViewController.generateHTML(JSON.serialize(sv));
		Test.stopTest();
    }

    @isTest static void test_getDataList_Excel() {
        Test.startTest();
        ApexPages.currentPage().getParameters().put('searchKeywords', JSON.serialize(sv));
        WonLostDropListViewController wldController = new WonLostDropListViewController();
        wldController.getDataList();
		Test.stopTest();
    }
}