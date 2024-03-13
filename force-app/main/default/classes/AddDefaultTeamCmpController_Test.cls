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
private class AddDefaultTeamCmpController_Test {
    static User owner;
    static User member1;
    static User member2;
    static User member3;
    static Sales_Lead__c sl;
    static Sales_Lead__c sl1;
    static Sales_Lead_Team__c slt;
    static Default_Sales_Lead_Team__c dslt;

    static{
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
        member3 = new User(Alias = 'member3', Email='member3@samsung.com', 
                     EmailEncodingKey='UTF-8', LastName='member3', LanguageLocaleKey='en_US', 
                     LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                     UserName='member3@samsung.com');
        userList.add(member3);

        insert userList;
        sl = new Sales_Lead__c(
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
            Authority__c = true
        );
		insert sl;
        sl1 = new Sales_Lead__c(
            Name = 'TestSalesLead1', 
            Company__c = 'Company__c',
            Email__c = 'tse@sdfjo.com.vop',
            LeadChannel__c='Demand',
            LeadStage__c = 'Hot',
            Amount__c = 5000, 
            CloseDate__c = Date.today().addDays(1),  
            RevenueEndDate__c = Date.today().addDays(3), 
            RevenueStartDate__c = Date.today().addDays(2),
            Budget__c = true,
            Authority__c = true
        );
        System.runAs(member3){
			insert sl1;
        }
        
        Sales_Lead_Team__c slt = new Sales_Lead_Team__c(
            SalesLead_TeamMember__c = member1.Id, 
            AccessLevel__c = 'Read',
            Sales_Lead__c = sl.Id,
            Team_Role__c = 'Proposal PM'
        );

        insert slt;
        Sales_Lead_Team__c slt1 = new Sales_Lead_Team__c(
            SalesLead_TeamMember__c = member3.Id, 
            AccessLevel__c = 'Edit',
            Sales_Lead__c = sl.Id,
            Team_Role__c = 'Proposal PM'
        );

        insert slt1;
        Default_Sales_Lead_Team__c dslt = new Default_Sales_Lead_Team__c(
            User__c = member2.Id, 
            AccessLevel__c = 'Read',
            TeamRole__c = 'Sales Rep'
        );

        insert dslt;
         Default_Sales_Lead_Team__c dslt1 = new Default_Sales_Lead_Team__c(
            User__c = member1.Id, 
            AccessLevel__c = 'Edit',
            TeamRole__c = 'Sales Rep'
        );

        insert dslt1;
        Default_Sales_Lead_Team__c dslt3 = new Default_Sales_Lead_Team__c(
            User__c = member3.Id, 
            AccessLevel__c = 'Edit',
            TeamRole__c = 'Sales Rep'
        );

        insert dslt3;
    }

 
    @isTest static void test_method_1() {
        Test.startTest();
        AddDefaultTeamCmpController.AddDefaultTeam(sl.Id);
		Test.stopTest();
	}
    @isTest static void test_method_2() {
        Test.startTest();
        System.runAs(member3){
        	AddDefaultTeamCmpController.AddDefaultTeam(sl1.Id);
        }
		Test.stopTest();
	}
    @isTest static void test_method_3() {
        Test.startTest();
        System.runAs(member3){
        	AddDefaultTeamCmpController.AddDefaultTeam(sl.Id);
        }
		Test.stopTest();
	}
}