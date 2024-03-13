/**
* @author            : vikrant.ks@samsung.com
* @group             : 
* @description       : 
* @last modified on  : 2024-01-31
* @last modified by  : vikrant.ks@samsung.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   2024-01-31   vikrant.ks@samsung.com    Initial Version
**/
@isTest
public class SalesLeadOwnerChangeController_Test {
    @isTest 
    public static void test_method_1() {
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
        
        User member1 = new User(Alias = 'member1', Email='member1@samsung.com', 
                     EmailEncodingKey='UTF-8', LastName='member1', LanguageLocaleKey='en_US', 
                     LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                     UserName='member1@samsung.com',FederationIdentifier = 'k123451789');
        insert member1;
        User member2 = new User(Alias = 'member2', Email='member2@samsung.com', 
                     EmailEncodingKey='UTF-8', LastName='member1', LanguageLocaleKey='en_US', 
                     LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                     UserName='member2@samsung.com',FederationIdentifier = 'k12345178999');
        insert member2;
        
        Employee__c emp1 = new Employee__c(
                    Name = 'member1',
                    EvMailAddr__c = 'member1@samsung.com',
                    EvTitleJikchakEN__c = 'Group Leader',
                    EvUniqID__c = 'k123451789',
                    Knox_Id__c = 'knoxId5',
                    EvKostl__c = 'T201-10384'
                );
        insert emp1;
        Employee__c emp2 = new Employee__c(
                    Name = 'member2',
                    EvMailAddr__c = 'member2@samsung.com',
                    EvTitleJikchakEN__c = 'Group Leader',
                    EvUniqID__c = 'k12345178999',
                    Knox_Id__c = 'knoxId6',
                    EvKostl__c = 'T201-10384'
                );
        insert emp2;
        
        CostCenter__c costCenter = new CostCenter__c(CostCenterName__c = 'Test1', Name ='Test1');
        insert costCenter;
        
        Sales_Lead__c sl = new Sales_Lead__c(
            OwnerId = member2.Id,
            Name = 'TestSalesLead', 
            Company__c = 'Company__c',
            Email__c = 'tse@sdfjo.com.vop',
            LeadChannel__c='Demand',
            LeadStage__c = 'Hot',
            Amount__c = 5000, 
            CloseDate__c = Date.today().addDays(1),  
            RevenueEndDate__c = Date.today().addDays(3), 
            RevenueStartDate__c = Date.today().addDays(2),
            Budget__c = true,
            Authority__c = true,
            SalesDepartment__c = costCenter.Id
        );
        insert sl;
        String salesLeadId = sl.Id;
        String s = SalesLeadOwnerChangeController.OwnerChangeAlertMsg(salesLeadId);
        sl.OwnerId = member1.Id;
        update sl;
        String s1 = SalesLeadOwnerChangeController.OwnerChangeAlertMsg(salesLeadId);
        Test.stopTest();
    }
}