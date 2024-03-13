/**
* @author            : vikrant.ks@samsung.com
* @group             : 
* @description       : 
* @last modified on  : 2024-01-22
* @last modified by  : vikrant.ks@samsung.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   2024-01-22   vikrant.ks@samsung.com    Initial Version
**/
@isTest
private class SalesLeadTeamTrigger_Test {
    static User owner;
    static User member1;
    static User member2;
    static Campaign campaign1;
    static CostCenter__c costCenter;
    static Sales_Lead__c sl;
    static Sales_Lead_Team__c slt;

    @isTest static void test_method_1() {
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];

        list<User> userList = new list<User>();

        owner = new User(Alias = 'owner', Email='owner@samsung.com', 
                     EmailEncodingKey='UTF-8', LastName='owner', LanguageLocaleKey='en_US', 
                     LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                     UserName='owner@samsung.com');
        userList.add(owner);

        member1 = new User(Alias = 'member1', Email='member1@samsung.com', 
                     EmailEncodingKey='UTF-8', LastName='member1', LanguageLocaleKey='en_US', 
                     LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                     UserName='member1@samsung.com');
        userList.add(member1);

        member2 = new User(Alias = 'member2', Email='member2@samsung.com', 
                     EmailEncodingKey='UTF-8', LastName='member2', LanguageLocaleKey='en_US', 
                     LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                     UserName='member2@samsung.com');
        userList.add(member2);

        insert userList;
        
        campaign1 = new Campaign(Name = 'test1');
        insert campaign1;
        
        costCenter = new CostCenter__c(CostCenterName__c = 'Test1', Name ='Test1');
        insert costCenter;
        sl = new Sales_Lead__c(
            Name = 'TestSalesLead', 
            CampaignId__c = campaign1.Id,
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

        Sales_Lead_Team__c slt = new Sales_Lead_Team__c(
            SalesLead_TeamMember__c = member1.Id, 
            AccessLevel__c = 'Read',
            Sales_Lead__c = sl.Id,
            Team_Role__c = 'Sales Rep'
        );
        Sales_Lead_Team__c slt0 = new Sales_Lead_Team__c(
            SalesLead_TeamMember__c = member2.Id, 
            AccessLevel__c = 'Read',
            Sales_Lead__c = sl.Id,
            Team_Role__c = 'Sales Rep'
        );

        insert slt;
        try{
            Sales_Lead_Team__c slttemp = new Sales_Lead_Team__c(
                SalesLead_TeamMember__c = member1.Id, 
                AccessLevel__c = 'Read',
                Sales_Lead__c = sl.Id,
                Team_Role__c = 'Sales Rep'
            );
            insert slttemp;
        }catch(Exception e){
            System.debug('Error: '+e.getMessage());
        }
        
        insert slt0;
        try{
            System.runAs(member1){
                update slt0;
            }
        }catch(Exception e){
            System.debug('Error: '+e.getMessage());
        }
        try{
            System.runAs(member1){
                delete slt0;
            }
        }catch(Exception e){
            System.debug('Error: '+e.getMessage());
        }
        try{
            slt0.SalesLead_TeamMember__c = Null;
        	update slt0;
        }catch(Exception e){
            System.debug('Error: '+e.getMessage());
        }
        try{
            slt0.Sales_Lead__c = Null;
        	update slt0;
        }catch(Exception e){
            System.debug('Error: '+e.getMessage());
        }
        Sales_Lead_Team__c slt1 = new Sales_Lead_Team__c(
            SalesLead_TeamMember__c = member1.Id, 
            AccessLevel__c = 'Read',
            Team_Role__c = 'Sales Rep'
        );
        try{
        	insert slt1;
        }catch(Exception e){
            System.debug('Error: '+e.getMessage());
        }
        
        Sales_Lead_Team__c slt2 = new Sales_Lead_Team__c(
            AccessLevel__c = 'Read',
            Sales_Lead__c = sl.Id,
            Team_Role__c = 'Sales Rep'
        );
        try{
        	insert slt2;
        }catch(Exception e){
            System.debug('Error: '+e.getMessage());
        }
        
        slt.AccessLevel__c = 'Edit';
        update slt;
        delete slt;
                
        Test.stopTest();
    }
}