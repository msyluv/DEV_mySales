/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-10-05
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-02-08   younghoon.kim@dkbmc.com   Initial Version
**/
@isTest
public class TriggerControl_Test {
	static Campaign campaign1;
    static Campaign campaign2;
    static User owner;
    static User member1;
    static Sales_Lead_Team__c slt;

    static User salesUser1;
    static User migUser;
    static Employee__c emp1;
    static Employee__c migEmp;

    static {
        campaign1 = new Campaign(Name = 'test1');
        campaign2 = new Campaign(Name = 'test2');
        insert campaign1;
        insert campaign2;

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

        insert userList;

        Sales_Lead_Team__c slt = new Sales_Lead_Team__c(
            OwnerId = owner.Id,
            SalesLead_TeamMember__c = member1.Id, 
            AccessLevel__c = 'Read'
        );

        insert slt;

        // Mig User Setting
        migEmp  = Utils_TestDataFactory.createEmployee('migEmp', 'migEmp');
        migUser = Utils_TestDataFactory.createUserFull(Utils_TestDataFactory.getProfile('System Administrator')
                                                        , migEmp.EvMailAddr__c
                                                        , migEmp.EvUniqID__c);
        emp1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'EPID1');
        salesUser1 = Utils_TestDataFactory.createUserFull(
            Utils_TestDataFactory.getProfile('Sales Rep.(Logi)')
            , emp1.EvMailAddr__c
            , emp1.EvUniqID__c);
    }

    @isTest
    public static void SalesLeadCountTrigger(){
        Sales_Lead__c sl = new Sales_Lead__c(
            Amount__c = 5000
            , CampaignId__c = campaign1.Id
            , Company__c = 'Company__c'
            , Email__c = 'tse@sdfjo.com.vop'
            , OwnerId = owner.Id
            , LeadStage__c = 'Warm');
        insert sl;

        sl.CampaignId__c = campaign2.Id;
        update sl;
        
        delete sl;
    }

    @isTest static void test_changeOwner() {
        Test.startTest();
        system.runAs(salesUser1) {
            Sales_Lead__c tempSalesLead = new Sales_Lead__c(
                Amount__c = 5000
                , CampaignId__c = campaign1.Id
                , Company__c = 'Company__c'
                , Email__c = 'tse@sdfjo.com.vop'
                , OwnerId = salesUser1.Id
                , LeadStage__c = 'Warm');
            insert tempSalesLead;

            tempSalesLead.OwnerId = migUser.id;
            update tempSalesLead;
        }
        Test.stopTest();
    }
}