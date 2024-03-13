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
private class WeeklyReportExtension_Test {
    static Account acc;
    static WeeklyReport__c wr1, wr2;
    static List <WeeklyReport__c> weeklyReports = new List<WeeklyReport__c>();
    
    static {
        acc = new Account(Name = 'TestAccountName');
        insert acc;
        acc.MDGCheck__c = true;
        update acc;
        
        wr1 = new WeeklyReport__c(Name = 'TestWeeklyReport1', ReportingDate__c = System.today(), Account__c = acc.Id);
        weeklyReports.add(wr1);
        wr2 = new WeeklyReport__c(Name = 'TestWeeklyReport2', ReportingDate__c = System.today(), Account__c = acc.Id);
        weeklyReports.add(wr2);
        insert weeklyReports;
    }

    @isTest
    public static void WeeklyReportExtension_Test() {
        Test.startTest();
        PageReference pageRef = Page.WeeklyReportPreview;
		Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('Id', String.valueOf(acc.Id));

        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(weeklyReports);
        WeeklyReportExtension cntlr = new WeeklyReportExtension(ssc);
        
        cntlr.redirectToLC();
        Test.stopTest();
    }
}