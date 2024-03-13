/**
 * @description       : 
 * @author            : wonjune.oh@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-03-16
 * @last modified by  : Junghwa.Kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-25   wonjune.oh@partner.samsung.com   Initial Version
**/
@isTest
public with sharing class VRBRequest_Test {
    
    static User adminUser;
    static Profile adminpf;
    static {
        adminpf =  [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1];
        
        adminUser = new User(
            Alias = 'testUser'
            , Email = 'adminUser@test.com.test'
            , EmailEncodingKey = 'UTF-8'
            , LastName = 'Testing'
            , LanguageLocaleKey = 'en_US'
            , LocaleSidKey = 'en_US'
            , EmployeeNumber = 'AC100000'
            , TimeZoneSidKey = 'Asia/Seoul'
            , ProfileId = adminpf.Id
            , UserName = 'adminUser@test.com.test'
            , FederationIdentifier = 'epId1'
        );    
        insert adminUser;
        // [Trigger Switch Setting ]
        TriggerSwitch__c profileSwitch = new TriggerSwitch__c(
            All__c = true,
            Opportunity__c = true,
            OpportunityActivity__c = true,
            SetupOwnerId = UserInfo.getProfileId()
        );
        insert profileSwitch;

        RecordType recordId = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'HQ' Limit 1];
        
        Account accAct = new Account(Name = 'accTest', MDGCheck__c = true);

        insert accAct;

        Opportunity oper = new Opportunity(Name ='Test' , RecordTypeId = recordId.Id ,AccountId =accAct.Id
                                             ,CloseDate =System.today() ,StageName = 'Z01');
        insert oper;

        MasterActivity__c mastrtAct = new MasterActivity__c(Stage__c='Z01',Order__c=1
                                 , IsRequiredKnoxApproval__c=false
                                 , Position__c='1',IsImportant__c=true,IsRequired__c=true
                                 , ObjectApiName__c='Opportunity',IsActive__c=true,Type__c='HQ');

        Opportunity_Activity__c operAct = new Opportunity_Activity__c( Status__c='Not Started', DueDate__c=System.today()
                                            ,WhatId__c=oper.Id);
        
        insert mastrtAct;
        insert operAct;

        VRBRequest__C vrbR = new VRBRequest__c(Business_Level__c ='S',VRBMethod__c= '전사'
                                                    ,VRBDueDate__c = System.today(),Opportunity__c = oper.Id ,Opportunity_Activity__c = operAct.Id);
        insert vrbR;
    }
    
    @isTest static void test_method_one() {
		Test.startTest();

        Opportunity_Activity__c operAct = [SELECT Id FROM Opportunity_Activity__c LIMIT 1];
        VRBRequest.getLabel('VRBRequest__c');
        VRBRequest.initComponent(operAct.Id);
        VRBRequest__c vrb = [SELECT Id, VRBOwner__c FROM VRBRequest__c LIMIT 1];
        Opportunity oper = [SELECT Id FROM Opportunity LIMIT 1];
        VRBRequest.getTeamMemberList(String.valueOf(oper.Id));
        VRBRequest.sendKnoxEmail(String.valueOf(vrb.Id));
        try {
            VRBRequest.changeVRBOwner(String.valueOf(vrb.Id));
            vrb.VRBOwner__c = adminUser.Id;
            update vrb;
            VRBRequest.changeVRBOwner(String.valueOf(vrb.Id));
        } catch (Exception e) {
            System.debug(e);
        }

		Test.stopTest();
	}
}