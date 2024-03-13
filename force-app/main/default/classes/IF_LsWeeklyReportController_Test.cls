/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-27
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2021-01-27   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class IF_LsWeeklyReportController_Test {

    // INTERFACE_ID = 'IF-127';
    // APEX_CLASS   = 'IF_LsWeeklyReportController';
    // METHOD_NAME  = 'calloutWeeklyInfo';

    public IF_LsWeeklyReportController_Test() { }

    @TestSetup
    static void makeData(){

        IF_Callout_TestDataSetup.dataSetup();
    }
    
    @isTest
    static void calloutTest(){
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        List<WeeklyReport__c> selectWeeklyReportList = [
            Select  Id
            From    WeeklyReport__c
        ];
        List<String> selectList = new List<String>();
        for (WeeklyReport__c WeeklyReportData : selectWeeklyReportList) {
            selectList.add(WeeklyReportData.Id);
        }

        IF_LsWeeklyReportController.calloutWeeklyInfo(selectList);

        Test.stopTest();
    }    
}