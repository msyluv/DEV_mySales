/**
 * @description       : 
 * @author            : kilhwan.an@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-05
 * @last modified by  : kilhwan.an@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2021-01-05   kilhwan.an@partner.samsung.com   Initial Version
**/
@isTest
public with sharing class Batch_DeleteApexLogRt_Test {
    public static testMethod void Batch_DeleteApexLogRtTest() {

        Test.startTest();
        Batch_DeleteApexLogRt batch = new Batch_DeleteApexLogRt();
        batch.start( null);
        batch.execute( null , new List<ApexLog>());
        batch.finish( null);
        Test.stopTest();        
    }
}