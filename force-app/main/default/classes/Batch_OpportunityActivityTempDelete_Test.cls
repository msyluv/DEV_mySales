/**
 * @description       : 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-05-06
 * @last modified by  : hj.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2021-04-26   hj.lee@dkbmc.com   Initial Version
**/
@isTest
public class Batch_OpportunityActivityTempDelete_Test {
    @TestSetup
    private static void setData() {
        Opportunity oppty = new Opportunity(
            Name = 'Oppty',
            StageName = 'Z01',
            CloseDate = System.today()
        );
        insert oppty;

        Opportunity_Activity__c opptyAct1 = new Opportunity_Activity__c(
            WhatId__c = oppty.Id
            , Status__c = ''
            , CreatedDate = System.today().addDays(-2)
        );
        insert opptyAct1;


        Opportunity_Activity__c opptyAct2 = new Opportunity_Activity__c(
            WhatId__c = oppty.Id
            , Status__c = ''
        );
        insert opptyAct2;

    }

    @isTest
    public static void batch_DeleteDataTest(){

        Test.startTest();
        Batch_OpportunityActivityTempDelete batch = new Batch_OpportunityActivityTempDelete();
        DataBase.executeBatch(batch, 2);
        Test.stopTest();
        
        List<SObject> scopeList = DataBase.query(batch.query);

        System.assertEquals(scopeList.size(), 1);
        System.debug('scopeList::::' + scopeList);
    }

    @isTest
    public static void schedule_test() {
        Test.startTest();
        System.schedule('Batch_OpportunityActivityTempDelete', '0 0 3 * * ? *', new Batch_OpportunityActivityTempDelete());
        Test.stopTest();
    }

}