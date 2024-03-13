/**
 * @description       : 
 * @author            : kilhwan.an@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-04-21
 * @last modified by  : kilhwan.an@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2021-04-21   kilhwan.an@partner.samsung.com   Initial Version
**/
@isTest
public class Batch_DeleteData_Test {

    @TestSetup
    private static void setData() {

        MDGAccount__c acct = new MDGAccount__c();
        acct.Name = 'ABC';
        insert acct;
    }

    public static testMethod void Batch_DeleteDataTest(){

        Test.startTest();
        Batch_DeleteData batch = new Batch_DeleteData();
        batch.query = ' SELECT Id FROM MDGAccount__c ';
        DataBase.executeBatch( batch, 1);
        Test.stopTest();

        List<SObject> scopeList = DataBase.query( batch.query);

        System.assertEquals(scopeList.size(), 0);

        System.debug( 'scopeList::::' + scopeList);
    }
}