/**
 * @description       : Test class for Batch Program of Batch_CompanyAverageLoginGenerator
 * @author            : vikrant.ks@samsung.com
 * @group             : 
 * @last modified on  : 2023-09-22
 * @last modified by  : vikrant.ks@samsung.com 
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2023-09-22   vikrant.ks@samsung.com   Initial Version
**/
@isTest(SeeAllData=True)
public class Batch_CompanyAverageLoginGenerator_Test{
    
    @isTest
    public static void Test_Batch_UserLogin1()
    {
        Test.startTest();
        DataBase.executeBatch(new Batch_CompanyAverageLoginGenerator());
        Test.stopTest();
    } 
	@isTest
    public static void Test_Batch_UserLogin2()
    {
        Set<String> company = new Set<String>{'SDS','SDSA'};
        Set<String> profile = new Set<String>{'Sales Support(HQ)','Sales Manager(HQ)'};
        Test.startTest();
        DataBase.executeBatch(new Batch_CompanyAverageLoginGenerator('9','2023','IT',company,profile));
        Test.stopTest();
    } 
}