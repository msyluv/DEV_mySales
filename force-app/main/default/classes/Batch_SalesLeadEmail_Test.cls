/**
 * @description       : 
 * @author            : yeongju.baek@dkbmc.com
 * @group             : 
 * @last modified on  : 12-02-2021
 * @last modified by  : zenith21c@test.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   07-29-2021   yeongju.baek@dkbmc.com   Initial Version
 * 1.1   11-31-2022   anish.jain@partner.samsung.com  Coverage for DeptHead Notification.
**/
@isTest
public class Batch_SalesLeadEmail_Test {
    static Lead l1;
    static Lead l2;
    static User sander;
    static Employee__c sanderEmp;
    static User owner;
    static Employee__c ownerEmp;
    static Datetime deadline = Datetime.now().addDays(-2);
    static Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자' LIMIT 1];
    static String recordTypeId = String.valueOf([SELECT Id FROM RecordType WHERE DeveloperName = 'Logistics' AND SobjectType = 'Opportunity' LIMIT 1].Id);
    static Sales_Lead__c sl1;
    static Sales_Lead__c sl2;
    static Sales_Lead__c sl3;

    static {
        
        l1 = new Lead(LastName = 'TestLead', 
                      //PersonalInfoAgreementExpireDate__c = Date.today(), 
                      PersonalInfoAgreement__c = true, 
                      Company='TestCompany');
        insert l1;

        l2 = new Lead(LastName = 'TestLead', 
                      //PersonalInfoAgreementExpireDate__c = Date.today(), 
                      PersonalInfoAgreement__c = true, 
                      Company='TestCompany');
        insert l2;

        

        owner = new User(
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
        insert owner;

        ownerEmp = new Employee__c(
            Name = 'testUser',
            EvMailAddr__c = 'SysAdminTestuser@samsung.com',
            EvUniqID__c = 'k123456789',
            Knox_Id__c = 'knoxId5'
        );
        insert ownerEmp;

        List<Sales_Lead__c> salesLeadList = new List<Sales_Lead__c>();
        sl1 = new Sales_Lead__c(
            Name = 'TestSalesLead1',
            OwnerId = owner.Id,
            LeadDescription__c = 'TEstDescription\n TEstDescription',
            CreatedDate = Datetime.now().addDays(-3),
            Sales_Alert_Date__c = null,
            CustomerContactDate__c = null,
            Lead__c = l1.Id ,
            LeadStage__c = 'Warm',
            LeadChannel__c= 'Marketing Lead Converted' //Added by Anish - v 1.1
        );
        salesLeadList.add(sl1); 

       sl2 = new Sales_Lead__c(
            Name = 'TestSalesLead2',
            OwnerId = owner.Id,
            LeadDescription__c = 'TEstDescription',
            CreatedDate = Datetime.now().addDays(-2),
            Sales_Alert_Date__c = deadline,
            CustomerContactDate__c = null,
            Lead__c = l2.Id,
            LeadStage__c = 'Warm',
            LeadChannel__c= 'Marketing Lead Converted' //Added by Anish - v 1.1
        );
        salesLeadList.add(sl2); 

       sl3 = new Sales_Lead__c(
            Name = 'TestSalesLead3',
            OwnerId = owner.Id,
            LeadDescription__c = 'TEstDescription',
            CreatedDate = deadline,
            Sales_Alert_Date__c = null,
            CustomerContactDate__c = null,
            Lead__c = null,
            LeadStage__c = 'Warm'
        );
        salesLeadList.add(sl3);
        insert salesLeadList;

        
    }
    @isTest
    public static void Test_Batch_SalesLeadEmail(){
        Test.startTest();
        DataBase.executeBatch( new Batch_SalesLeadEmail(), 10);
        Test.stopTest();
    }
    @isTest
    public static void Test_Batch_SalesLeadEmail2(){
        Test.startTest();
        DataBase.executeBatch( new Batch_SalesLeadEmail(new Set<Id>{sl1.Id}), 10);
        Test.stopTest();
    }

    @isTest
    public static void Test_Shcedule(){
        Test.startTest();
        System.schedule('Test','0 0 4 * * ? *', new Batch_SalesLeadEmail());
        Test.stopTest();
    }

    @isTest
    public static void Test_Batch_SalesLeadEmail3(){
        Test.startTest();
        Set<Id> testIdSet = new Set<Id>();
        testIdSet.add('a0P1s000001s5R5EAI');
        Batch_SalesLeadEmail b = new Batch_SalesLeadEmail(testIdSet);
        Id ttt = Database.executeBatch(b, 1);
        Test.stopTest();
    }
}