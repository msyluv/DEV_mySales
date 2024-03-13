/**
* @description       : This class is a Test coverge for  lost countermeasure type data table lwc lostCounterMeasure
* @author            : rakshit.s@samsung.com
* @group             : 
* @last modified on  : 03-23-2023
* @last modified by  : rakshit.s@samsung.com
* Modifications Log 
* Ver   Date         Author                  Modification
* 1.0   03-23-2023  rakshit.s@samsung.com   Initial Version
**/
@istest
public class LostCounterMeasureTableControllerTest {
    
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
        
        
        Lost_Countermeasure__c lc = new Lost_Countermeasure__c();
        
        
        lc.LostActivity__c= oppAct.id;
        lc.Opportunity__c= op.id;
        lc.Master_Lost_Type_Code__c= 'test';
        insert lc;
    }
    
    @isTest static void testMasterLostTypeData() {
        
        Test.startTest();
        Opportunity opp = [select id from Opportunity limit 1];
        Opportunity_Activity__c oAc = [Select id from Opportunity_Activity__c limit 1];
        LostCounterMeasureTableController.getCounterMeasureData('ko' ,opp.id,oAc.id);
        LostCounterMeasureTableController.getCounterMeasureData('en-US' ,opp.id,oAc.id);
        LostCounterMeasureTableController.isLostOrDrop(oAc.id,opp.id);
        
        Test.stopTest();
        
    }
    
    
}