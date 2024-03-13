/**
 * @description       : Test class for Batch Program that sends user access logs from MySales to DataLake every hour(IF-181)
 * @author            : vikrant.ks@samsung.com
 * @group             : 
 * @last modified on  : 2023-05-11 
 * @last modified by  : vikrant.ks@samsung.com 
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2023-05-11   vikrant.ks@samsung.com   Initial Version(MySales 195)
**/
@isTest(SeeAllData=true)
public class Batch_UserLogstoDataLake_Test
{    
    @isTest
    public static void SendUserLogstoDataLake(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        DataBase.executeBatch(new Batch_UserLogstoDataLake(), 200);
        Test.stopTest();
    }
}