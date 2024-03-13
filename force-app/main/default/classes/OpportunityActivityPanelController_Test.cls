/**
 * @description       : 
 * @author            : wonjune.oh@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-28
 * @last modified by  : hj.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-10   wonjune.oh@partner.samsung.com   Initial Version
**/

@isTest
private class OpportunityActivityPanelController_Test {

    static RecordType RT_OPPTY_HQ;
    static RecordType RT_OPPTY_LOGISTICS;

    static {
        // [Trigger Switch Setting ] Default Org Switch Setup
        TriggerSwitch__c trSwitch_default = new TriggerSwitch__c(
            All__c = false,
            Opportunity__c = false,
            OpportunityActivity__c = false
        );
        insert trSwitch_default;
        
        // [Function Switch Setting ] Default Org Switch Setup
        FunctionSwitch__c funcSwitch_default = new FunctionSwitch__c();
        insert funcSwitch_default;
        
        RT_OPPTY_HQ        = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
        RT_OPPTY_LOGISTICS = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Logistics' Limit 1];
    
        
        Account accAct = new Account(Name = 'accTest', MDGCheck__c=true);
        insert accAct;

        Opportunity oper = new Opportunity(Name ='Test' , RecordTypeId = RT_OPPTY_HQ.Id ,AccountId =accAct.Id
                                             ,CloseDate =System.today() ,StageName = 'Z01');
        insert oper;

        MasterActivity__c mastrtAct1 = new MasterActivity__c(TransactionName__c=Utils.getPicklistOptionType('MasterActivity__c','TransactionName__c')[0].get('value')
                                 , Stage__c='Z01',Order__c=1
                                 , IsRequiredKnoxApproval__c=false
                                 , Position__c='1',IsImportant__c=true,IsRequired__c=true
                                 , ObjectApiName__c='Opportunity',IsActive__c=true,Type__c='HQ');

        MasterActivity__c mastrtAct2 = new MasterActivity__c(TransactionName__c=Utils.getPicklistOptionType('MasterActivity__c','TransactionName__c')[6].get('value')
                                 , Stage__c='Z01',Order__c=1
                                 , IsRequiredKnoxApproval__c=false
                                 , Position__c='2',IsImportant__c=true,IsRequired__c=true
                                 , ObjectApiName__c='Opportunity',IsActive__c=true,Type__c='HQ');

        Opportunity_Activity__c operAct = new Opportunity_Activity__c( Status__c='Not Started'
        , DueDate__c=System.today()
        , TransactionName__c=Utils.getPicklistOptionType('Opportunity_Activity__c','TransactionName__c')[2].get('value')
        , WhatId__c=oper.Id);

        
        insert mastrtAct1;
        insert mastrtAct2;
        insert operAct;
    }
    
    @isTest static void test_method_one() {
		Test.startTest();

        Opportunity operAct = [SELECT Id FROM Opportunity LIMIT 1];

        OpportunityActivityPanelController.initComponent(operAct.Id, true);

		Test.stopTest();
	}

}