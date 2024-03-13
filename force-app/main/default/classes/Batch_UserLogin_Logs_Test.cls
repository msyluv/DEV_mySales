/**
 * @description       : Test class for Batch Program of UserLogin_Logs
 * @author            : vikrant.ks@samsung.com
 * @group             : 
 * @last modified on  : 2023-04-11
 * @last modified by  : vikrant.ks@samsung.com 
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2023-04-11   vikrant.ks@samsung.com   Initial Version
**/
@isTest (SeeAllData=true)
public class Batch_UserLogin_Logs_Test
{
    @isTest
    public static void Test_Batch_UserLogin()
    {
        Test.startTest();
        DataBase.executeBatch(new Batch_UserLogin_Logs(),200);
        Test.stopTest();
    }   
}