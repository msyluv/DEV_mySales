public with sharing class ReportSearchController {
    @AuraEnabled(cacheable=true)
    public static List<ReportWrapper> getAllReports() {
        List<ReportWrapper> reportWrappers = new List<ReportWrapper>();
        List<Report> reports = [SELECT Id, Name FROM Report where Format='Tabular' or Format='Summary'];
        
        for (Report report : reports) {
            reportWrappers.add(new ReportWrapper(report.Id, report.Name));
        }
        
        return reportWrappers;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        return [SELECT Id, Name FROM Account LIMIT 10];
    }
    
     @AuraEnabled(cacheable=true)
    public static List<User> getUsers(String searchTerm) {
        searchTerm = '%' + searchTerm + '%'; // Add wildcards to perform a partial match
        return [SELECT Id, Name, Email
                FROM User
                WHERE IsActive = true AND (Name LIKE :searchTerm OR Email LIKE :searchTerm)
                LIMIT 10]; // You can adjust the limit based on your requirements
    }
     
    public class ReportWrapper {
        @AuraEnabled
        public Id reportId;
        @AuraEnabled
        public String reportName;
        
        public ReportWrapper(Id id, String name) {
            reportId = id;
            reportName = name;
        }
    }
    
     public class UserWrapper {
        @AuraEnabled
        public String userName;
        @AuraEnabled
        public String userEmail;
        
        public UserWrapper(String name, String email) {
            userName = name;
            userEmail = email;
        }
    }
}