/**
 * @description       : 
 * @author            : gitesh.s@samsung.com
 * @group             : 
 * @last modified on  : 15-03-2023
 * @last modified by  : gitesh.s@smsung.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   15-03-2023   gitesh.s@samsung.com   Initial Version
**/
@isTest
private class WeeklyReportHandlerController_Test {
    static Account acc;
    static WeeklyReport__c wr1, wr2;
    static String weeklyReportIds;

    static {
        acc = new Account(Name = 'TestAccountName');
        insert acc;
        acc.MDGCheck__c = true;
        update acc;

        wr1 = new WeeklyReport__c(Name = 'TestWeeklyReport1', ReportingDate__c = System.today(), Account__c = acc.Id);
        insert wr1;

        wr2 = new WeeklyReport__c(Name = 'TestWeeklyReport2', ReportingDate__c = System.today(), Account__c = acc.Id);
        insert wr2;

        weeklyReportIds = String.valueOf(wr1.Id) + '-' + String.valueOf(wr2.Id);
    }

    @isTest
    public static void getWeeklyIssueReports_Test() {
        Test.startTest();
        WeeklyReportHandlerController.getWeeklyIssueReports(weeklyReportIds);
        Test.stopTest();
    }

    @isTest
    public static void getRelatedWeeklyReports_Test() {
        Test.startTest();
        WeeklyReportHandlerController.getRelatedWeeklyReports(String.valueOf(acc.Id));
        Test.stopTest();
    }

    @isTest
    public static void getAccountName_Test() {
        Test.startTest();
        WeeklyReportHandlerController.getAccountName(String.valueOf(acc.Id));
        Test.stopTest();
    }
}