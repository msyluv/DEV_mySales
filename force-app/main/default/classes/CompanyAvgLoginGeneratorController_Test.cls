/**
 * @description       : Test Class of Company Average Login Generator Controller
 * @author            : vikrant.ks@samsung.com
 * @group             : 
 * @last modified on  : 2023-09-22
 * @last modified by  : vikrant.ks@samsung.com 
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2023-09-22   vikrant.ks@samsung.com   Initial Version(MySales 303)
**/
@isTest
public class CompanyAvgLoginGeneratorController_Test {

    @isTest
    public static void CompanyAvgLoginGeneratorTest_1(){
        List<String> company = new List<String>{'SDS','SDSA'};
        List<String> profile = new List<String>{'Sales Support(HQ)','Sales Manager(HQ)'};
        Test.startTest();
        CompanyAverageLoginGeneratorController.getBatchJobStatus(CompanyAverageLoginGeneratorController.executeBatchJob('9','2023','IT',company,profile));
        Test.stopTest();
    }
}