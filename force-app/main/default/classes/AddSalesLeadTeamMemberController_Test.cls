/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2024-01-24
 * @last modified by  : vikrant.ks@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-02-05   younghoon.kim@dkbmc.com   Initial Version
 * 1.1   2024-01-16   vikrant.ks@samsung.com    Changed Sales_Lead_Team to Default_Sales_Lead_Team(MySales-389)
**/
@isTest
private class AddSalesLeadTeamMemberController_Test {
    static User owner;
    static User member1;
    static User member2;
    static Sales_Lead__c sl;
    static Default_Sales_Lead_Team__c slt;

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
        Default_Sales_Lead_Team__c slt = new Default_Sales_Lead_Team__c(
            User__c = member1.Id, 
            AccessLevel__c = 'Read',
            TeamRole__c = 'Sales Rep'
        );

        insert slt;
    }

    @isTest static void test_method_1() {
        Test.startTest();
        AddSalesLeadTeamMemberController.defaultSetting();
		Test.stopTest();
    }
    
    @isTest static void test_method_2() {
        Test.startTest();
        AddSalesLeadTeamMemberController.customUser customUser = new AddSalesLeadTeamMemberController.customUser();
        customUser.Id = member2.Id;
        customUser.Name = member2.Name;

        AddSalesLeadTeamMemberController.sltm sltm = new AddSalesLeadTeamMemberController.sltm();
        sltm.User = customUser;
        sltm.AccessLevel = 'Edit';
        sltm.TeamRole = 'Sales Rep';

        List<AddSalesLeadTeamMemberController.sltm> sltmList = new List<AddSalesLeadTeamMemberController.sltm>();
        sltmList.add(sltm);
        AddSalesLeadTeamMemberController.save(JSON.serialize(sltmList));
		Test.stopTest();
	}
    @isTest static void test_method_3() {
        Test.startTest();
        AddSalesLeadTeamMemberController.customUser customUser = new AddSalesLeadTeamMemberController.customUser();
        customUser.Id = sl.Id;
        customUser.Name = member2.Name;

        AddSalesLeadTeamMemberController.sltm sltm = new AddSalesLeadTeamMemberController.sltm();
        sltm.User = customUser;
        sltm.AccessLevel = 'Edit';
        sltm.TeamRole = 'Sales Rep';

        List<AddSalesLeadTeamMemberController.sltm> sltmList = new List<AddSalesLeadTeamMemberController.sltm>();
        sltmList.add(sltm);
        try{
        	AddSalesLeadTeamMemberController.save(JSON.serialize(sltmList));
        }catch(Exception e){
            System.debug('Error: '+e.getMessage());
        }
		Test.stopTest();
	}
}