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
public class WeeklyReportHandlerController {
    @AuraEnabled
    public static List<WeeklyReport__c> getWeeklyIssueReports(string weeklyReportIds) {
        List<String> weeklyReports;
        String weeklyReportId;

        if(weeklyReportIds.contains('-')) {  
            weeklyReports = weeklyReportIds.split('-');
            weeklyReportId = String.join(weeklyReports,'\',\'');
        }
        else {
            weeklyReportId = weeklyReportIds;
        }
        String queryString = 'SELECT Id, Name, OwnerId, Owner.Alias, Owner.Name, Department__c, Opportunity__c, Opportunity__r.Name, Opportunity__r.AccountId, Opportunity__r.Account.Name, SalesLead__c, SalesLead__r.Name, SalesLead__r.AccountId__c, SalesLead__r.AccountId__r.Name, DisplayOrder__c, Contents__c, IssueDescription__c, ReportingDate__c FROM WeeklyReport__c WHERE Id IN (\''+weeklyReportId+'\') ORDER BY ReportingDate__c DESC';
        return Database.query(queryString);
    }

    @AuraEnabled
    public static List<WeeklyReport__c> getRelatedWeeklyReports(String recordId) {
        String queryString = 'SELECT Id, Name, Account__r.Name FROM WeeklyReport__c WHERE Account__c IN (\''+recordId+'\')';
        return Database.query(queryString);
    }

    @AuraEnabled
    public static List<Account> getAccountName(String recordId){
        String queryString = 'SELECT Id, Name FROM Account WHERE Id IN (\''+recordId+'\')';
        return Database.query(queryString);
    }
}