/**
* @description       : This class is a Test coverge for master lost type data table lwc masterLostTypeDataTable
* @author            : rakshit.s@samsung.com
* @group             : 
* @last modified on  : 03-23-2023
* @last modified by  : rakshit.s@samsung.com
* Modifications Log 
* Ver   Date         Author                  Modification
* 1.0   03-23-2023  rakshit.s@samsung.com   Initial Version
**/
@istest
private class MasterLostTypeDataControllerTest {
    static User user;
    @testSetup 
    static void setup(){
        Profile pf = [SELECT Id,name FROM Profile where name='System Administrator'];
        user = new User(Alias = 'Test', Email='Testgroup@Test.com', 
                        EmailEncodingKey='UTF-8', LastName='Test', FirstName='Test', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = pf.Id, TimeZoneSidKey='Asia/Seoul',
                        EvKostl__c='T100-12345',
                        UserName='user0001@samsung.com');
        Insert user;
        Opportunity op = new opportunity();
        
        op.CloseDate = Date.today().addDays(6);
        op.Name = 'sample';
        op.StageName  = 'Z02';
        op.owner = user;
        // op.owner.EvKostl__c = 'T100-12345';
        insert op;
        //system.debug('opportunity inserted-->' + op.owner.EvKostl__c);
        Opportunity op1 = new opportunity();
        
          Opportunity_Activity__c oppAct = new Opportunity_Activity__c(
            WhatId__c = op.id,
            ExtID__c = op.id+'ZPZ1',
            TransactionName__c = 'ZPZ1'
        );
        
        insert oppAct;
    }
    
    @isTest static void testMasterLostTypeData() {
        
        Test.startTest();
        Opportunity opp = [select id from Opportunity limit 1];
         Opportunity_Activity__c oAc = [Select id from Opportunity_Activity__c limit 1];
        MasterLostTypeDataController.getMasterLostType('en-US', true, opp.id,oAc.id);
        MasterLostTypeDataController.getMasterLostType('en-US', false, opp.id,oAc.id);
        
        MasterLostTypeDataController.getMasterLostType('ko', true, opp.id,oAc.id);
        MasterLostTypeDataController.getMasterLostType('ko', false, opp.id,oAc.id);
        
         MasterLostTypeDataController.getMasterLostType('other', true, opp.id,oAc.id);
        
        MasterLostTypeDataController.isLostOrDrop(oAc.id,opp.id);
        Test.stopTest();
        
    }
    
}