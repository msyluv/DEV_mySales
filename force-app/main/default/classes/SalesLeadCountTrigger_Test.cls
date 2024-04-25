/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2024-04-17
 * @last modified by  : sarthak.j1@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-02-08   younghoon.kim@dkbmc.com   Initial Version
 * 1.1   2024-01-24   sarthak.j1@samsung.com    Changes for resolving test class errors as part of MYSALES-413
 * 1.2   2024-02-15   sarthak.j1@samsung.com	Sales Lead - Internal/External field changing -> MYSALES-448
 * 1.3   2024-04-17   sarthak.j1@samsung.com	Sales Lead Enhancement -> MYSALES-497
**/
@isTest(SeeAllData=true) //Added SeeAllData=true as part of v-1.2 [MYSALES-448]
public class SalesLeadCountTrigger_Test {
    static Campaign campaign1;
    static Campaign campaign2;
    static User owner;
    static User member1;
    static Sales_Lead_Team__c slt;

    static User salesUser1;
    static User migUser;
    static Employee__c emp1;
    static Employee__c migEmp;
  
    static CostCenter__c costCenter; //Added v-1.1 [MYSALES-413]
    static Sales_Lead__c salesLead; //Added v-1.1 [MYSALES-413]

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
        
        //Start v-1.1 [MYSALES-413]
        costCenter = new CostCenter__c(CostCenterName__c = 'Test1', Name ='Test1');
        //insert costCenter;
        //End v-1.1 [MYSALES-413]

        //Start v-1.1 [MYSALES-413]
        salesLead = new Sales_Lead__c(
            Amount__c = 5000
            , CampaignId__c = campaign1.Id
            , Company__c = 'Company__c'
            , Email__c = 'tse@sdfjo.com.vop'
            , OwnerId = owner.Id
            , LeadStage__c = 'Warm'
            , LeadStatus__c = 'In Process' // Added as part of v-1.3
        	, CloseDate__c = Date.valueOf('2024-01-10'));
        	//, SalesDepartment__c = costCenter.Id);
        insert salesLead;
        //End v-1.1 [MYSALES-413]
        
        Sales_Lead_Team__c slt = new Sales_Lead_Team__c(
            OwnerId = owner.Id,
            SalesLead_TeamMember__c = member1.Id, 
            AccessLevel__c = 'Read',
            Sales_Lead__c = salesLead.Id //Added v-1.1 [MYSALES-413]
        );
		system.runAs(owner) {
        	insert slt;
        }
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
            , LeadStage__c = 'Warm'
            , LeadStatus__c = 'In Process' // Added as part of v-1.3
            //Start v-1.1 [MYSALES-413]
        	, CloseDate__c = Date.valueOf('2024-01-10'));
        	//, SalesDepartment__c = costCenter.Id);
        	//End v-1.1 [MYSALES-413] [SJOSHI End]*/
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
                , LeadStage__c = 'Warm'
                , LeadStatus__c = 'In Process' // Added as part of v-1.3
                //Start v-1.1 [MYSALES-413]
                , CloseDate__c = Date.valueOf('2024-01-10'));
                //, SalesDepartment__c = costCenter.Id);
                //End v-1.1 [MYSALES-413] [SJOSHI]*/
            insert tempSalesLead;

            tempSalesLead.OwnerId = migUser.id;
            update tempSalesLead;
        }
        Test.stopTest();
    }
}