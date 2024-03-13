/**
* @author            : vikrant.ks@samsung.com
* @group             : 
* @description       : 
* @last modified on  : 2024-01-18
* @last modified by  : vikrant.ks@samsung.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   2024-01-18   vikrant.ks@samsung.com    Initial Version
**/
@isTest
private class AddSalesTeamMemberCmpController_Test {
    static User owner;
    static User member1;
    static User member2;
    static Sales_Lead__c sl;
    static Sales_Lead_Team__c slt;

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

        Sales_Lead_Team__c slt = new Sales_Lead_Team__c(
            SalesLead_TeamMember__c = member1.Id, 
            AccessLevel__c = 'Read',
            Sales_Lead__c = sl.Id,
            Team_Role__c = 'Sales Rep'
        );

        insert slt;
    }

 
    @isTest static void test_method_1() {
        Test.startTest();
        AddSalesTeamMemberCmpController.customUser customUser = new AddSalesTeamMemberCmpController.customUser();
        customUser.Id = member1.Id;
        customUser.Name = member1.Name;

        AddSalesTeamMemberCmpController.sltm sltm = new AddSalesTeamMemberCmpController.sltm();
        sltm.User = customUser;
        sltm.AccessLevel = 'Edit';

        List<AddSalesTeamMemberCmpController.sltm> sltmList = new List<AddSalesTeamMemberCmpController.sltm>();
        sltmList.add(sltm);
        AddSalesTeamMemberCmpController.save(JSON.serialize(sltmList),sl.Id);
        AddSalesTeamMemberCmpController.CheckOwner(sl.Id);
		Test.stopTest();
	}
    
    @isTest static void test_method_2() {
        Test.startTest();
        AddSalesTeamMemberCmpController.customUser customUser = new AddSalesTeamMemberCmpController.customUser();
        customUser.Id = member2.Id;
        customUser.Name = member2.Name;

        AddSalesTeamMemberCmpController.sltm sltm = new AddSalesTeamMemberCmpController.sltm();
        sltm.User = customUser;
        sltm.AccessLevel = 'Read';

        List<AddSalesTeamMemberCmpController.sltm> sltmList = new List<AddSalesTeamMemberCmpController.sltm>();
        sltmList.add(sltm);
        AddSalesTeamMemberCmpController.save(JSON.serialize(sltmList),sl.Id);
        System.runAs(member2){
            AddSalesTeamMemberCmpController.save(JSON.serialize(sltmList),sl.Id);
        	AddSalesTeamMemberCmpController.CheckOwner(sl.Id);
        }
		Test.stopTest();
	}
    @isTest static void test_method_3() {
        Test.startTest();
        AddSalesTeamMemberCmpController.customUser customUser = new AddSalesTeamMemberCmpController.customUser();
        customUser.Id = member1.Id;
        customUser.Name = member1.Name;

        AddSalesTeamMemberCmpController.sltm sltm = new AddSalesTeamMemberCmpController.sltm();
        sltm.User = customUser;
        sltm.AccessLevel = 'Read';

        List<AddSalesTeamMemberCmpController.sltm> sltmList = new List<AddSalesTeamMemberCmpController.sltm>();
        sltmList.add(sltm);
        AddSalesTeamMemberCmpController.save(JSON.serialize(sltmList),sl.Id);
		Test.stopTest();
	}
    @isTest static void test_method_4() {
        Test.startTest();
        AddSalesTeamMemberCmpController.customUser customUser = new AddSalesTeamMemberCmpController.customUser();
        customUser.Id = sl.Id;
        customUser.Name = member1.Name;

        AddSalesTeamMemberCmpController.sltm sltm = new AddSalesTeamMemberCmpController.sltm();
        sltm.User = customUser;
        sltm.AccessLevel = 'Write';

        List<AddSalesTeamMemberCmpController.sltm> sltmList = new List<AddSalesTeamMemberCmpController.sltm>();
        sltmList.add(sltm);
        try{
        	AddSalesTeamMemberCmpController.save(JSON.serialize(sltmList),sl.Id);
        }catch(Exception e){
            System.debug('Error: '+e.getMessage());
        }
		Test.stopTest();
	}
}