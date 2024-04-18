/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 28-03-2024
 * @last modified by  : vipul.k1@samsung.com
 * Modifications Log 
 * Ver   Date         Author                 	Modification
 * 1.7   18-04-2024   divyam.gupta@samsung.com  Removed old Editor box(MySales-436)
 * 1.6   28-03-2024   vipul.k1@samsung.com   	Added  filter data in SOQL to fetch the records (MySales-479)
 * 1.5   28-03-2024   aditya.r2@samsung.com   	Added createdBy field in SOQL to fetch the field (MySales-483)
 * 1.4   26-03-2024   aditya.r2@samsung.com   	Added New editor box data inside method getEmailIssuesContents (MySales-471)
 * 1.3   14-03-2023   gitesh.s@samsung.com   	Changed Weekly/Issue Reports order by Report Date
 * 1.2   05-10-2021   woomg@dkbmc.com        	Change sharing structure : private to share with same role and subs.
 * 1.1   05-07-2021   woomg@dkbmc.com        	Add Report By, Department to Email template
 * 1.0   02-04-2021   woomg@dkbmc.com        	Initial Version
**/
public without sharing class WeeklyReportsController {
    @AuraEnabled
    public static string getMyDomain(){
        String domain = '';
        try {
            String urlInstance=String.valueof(System.URL.getSalesforceBaseURL().gethost());
            domain = urlInstance.removeEndIgnoreCase('.my.salesforce.com');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return domain;
    }

    @AuraEnabled
    public static list<WeeklyReport__c> getWeeklyReports(Date reportDate){
        list<WeeklyReport__c> lstWR = new list<WeeklyReport__c>();
        try {
            Date startDate = reportDate.toStartOfWeek();
            Date endDate = startDate.addDays(7);
            list<User> owners = RoleUtil.getAllSubordinates(UserInfo.getUserRoleId());
            system.debug('owners**' + owners.size());
            // v1.3 - Gitesh Saini
            lstWR = [SELECT Id, Name, OwnerId, Owner.Alias, Owner.Name, Department__c, 
                        Opportunity__c, Opportunity__r.Name, Opportunity__r.AccountId, Opportunity__r.Account.Name,
                        SalesLead__c, SalesLead__r.Name, SalesLead__r.AccountId__c, SalesLead__r.AccountId__r.Name,
                        DisplayOrder__c, Contents__c, ReportingDate__c, CreatedBy.Name, CreatedById
                     FROM WeeklyReport__c
                     WHERE Critical__c = true
                        AND ReportingDate__c >= :startDate
                        AND ReportingDate__c < :endDate
                        AND OwnerId IN :owners 
                     ORDER BY DisplayOrder__c ASC];
            // v1.3
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return lstWR;
    }

    @AuraEnabled
    public static WeeklyReport__c getWeeklyReport(String recordId){
        WeeklyReport__c record = new WeeklyReport__c();
        try {
            record = [SELECT Id, Name, OwnerId, Owner.Alias, Owner.Name, Department__c, Account_Name__c, 
                        Opportunity__c, Opportunity__r.Name, Opportunity__r.AccountId, Opportunity__r.Account.Name,
                        SalesLead__c, SalesLead__r.Name, SalesLead__r.AccountId__c, SalesLead__r.AccountId__r.Name,
                        DisplayOrder__c, Contents__c, ReportingDate__c
                      FROM WeeklyReport__c
                      WHERE Id = :recordId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return record;
    }

    @AuraEnabled
    public static Boolean saveWeeklyContent(String recordId, String content, Integer order){
        try {
            WeeklyReport__c record = new WeeklyReport__c();
            record.Id = recordId;
            record.Contents__c = content;
            if(order != null) record.DisplayOrder__c = order;
            
            update record;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return true;
    }

    @AuraEnabled
    public static String getEmailWeeklyContents(list<String> reportIds){
        list<WeeklyReport__c> records = new list<WeeklyReport__c>();
        String contents = '';
        try {
            records = [SELECT Id, Name, OwnerId, Owner.Alias, Owner.Name, Department__c,
                        Opportunity__c, Opportunity__r.Name, Opportunity__r.AccountId, Opportunity__r.Account.Name,
                        SalesLead__c, SalesLead__r.Name, SalesLead__r.AccountId__c, SalesLead__r.AccountId__r.Name,
                        DisplayOrder__c, Contents__c, ReportingDate__c
                       FROM WeeklyReport__c
                       WHERE Id IN :reportIds 
                       ORDER BY DisplayOrder__c ASC];
            String myDomain = 'https://' + getMyDomain() + '.lightning.force.com';
            String body = '';
            String divHeader   = '<div style="padding-bottom: 8px;">';
            String divFooter   = '</div>';
            String tableHeader = '<table border="0" cellpadding="0" cellspacing="0" style="background-color: #F3F2F2;font-family:tahoma;font-size:10pt;border-top:0.1px solid black;border-left:0.1px solid black;border-right:0.1px solid black;border-bottom:0.1px solid black;">';
            String tableFooter = '</table>';
            String trHeader    = '<tr>';
            String trFooter    = '</tr>';
            String th1Header   = '<td style="width:150px;line-height:32px;text-align:right;vertical-align:middle;font-weight:bold;white-space:nowrap;border: 0.1px solid black;padding-right:16px;padding-left:16px;">';
            String th2Header   = '<td colspan="2" style="line-height:32px;text-align:left;vertical-align:middle;font-weight:bold;white-space:nowrap;border: 0.1px solid black;padding-right:16px;padding-left:16px;">';
            String th4Header   = '<td colspan="4" style="line-height:32px;text-align:left;vertical-align:middle;font-weight:bold;white-space:nowrap;border: 0.1px solid black;padding-right:16px;padding-left:16px;">';
            String td1Header   = '<td width="50%" style="background-color:#ffffff;border: 0.1px solid black;line-height:32px;padding-right:16px;padding-left:16px;">';
            String td3Header   = '<td colspan="3" style="background-color:#ffffff;border: 0.1px solid black;line-height:32px;padding-right:16px;padding-left:16px;">';
            String td4Header   = '<td colspan="4" style="background-color:#ffffff;border: 0.1px solid black;padding:16px;">';
            String tdhFooter   = '</td>';

            if(!records.isEmpty()){
                for(WeeklyReport__c record : records){
                    body += divHeader;
                    body += tableHeader;

                    body += trHeader;
                    body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_NAME + tdhFooter;
                    body += td1Header + '<a href="' + myDomain + '/lightning/r/WeeklyReport__c/' + record.Id + '/view" target="_blank">' +  + record.Name.escapeHtml4() + '</a>' + tdhFooter;
                    body += th1Header + Label.WEEKLY_ISSUE_REPORT_DEPT_NAME + tdhFooter;
                    body += td1Header + record.Department__c + tdhFooter;
                    body += trFooter;

                    body += trHeader;
                    if(record.Opportunity__c != null){
                        String opptyName = record.Opportunity__r.Name;
                        body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_OPPORTUNITY + tdhFooter;
                        body += td1Header + '<a href="' + myDomain + '/lightning/r/Opportunity/' + record.Opportunity__c + '/view" target="_blank">' + opptyName.escapeHtml4() + '</a>' + tdhFooter;
                    } else if(record.SalesLead__c != null){
                        String leadName = record.SalesLead__r.Name;
                        body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_OPPORTUNITY + tdhFooter;
                        body += td1Header + '<a href="' + myDomain + '/lightning/r/Sales_Lead__c/' + record.SalesLead__c + '/view" target="_blank">' + leadName.escapeHtml4() + '</a>' + tdhFooter;
                    } else {
                        body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_OPPORTUNITY + tdhFooter;
                        body += td1Header + '' + tdhFooter;
                    }
                    body += th1Header + Label.WEEKLY_ISSUE_REPORT_OWNER_NAME + tdhFooter;
                    body += td1Header + record.Owner.Name + tdhFooter;
                    body += trFooter;

                    String accountName = '';
                    String reportDate = '';
                    if(record.Opportunity__c != null && record.Opportunity__r.AccountId != null) accountName = record.Opportunity__r.Account.Name;
                    if(record.SalesLead__c != null && record.SalesLead__r.AccountId__c != null) accountName = record.SalesLead__r.AccountId__r.Name;
                    if(record.ReportingDate__c != null){
                        Date rt = record.ReportingDate__c;
                        reportDate = String.valueOf(rt.year()) + '-' + String.valueOf(rt.month()).leftPad(2, '0') + '-' + String.valueOf(rt.day()).leftPad(2, '0');
                    }
                    body += trHeader;
                    body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_ACCOUNT + tdhFooter;
                    body += td1Header + '<a href="' + myDomain + '/lightning/r/Account/' + record.Opportunity__r.AccountId + '/view" target="_blank">' + accountName.escapeHtml4() + '</a>' + tdhFooter;
                    body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_REPORTDATE + tdhFooter;
                    body += td1Header + reportDate.escapeHtml4() + tdhFooter;
                    body += trFooter;

                    body += trHeader;
                    body += th4Header + Label.WEEKLY_ISSUE_REPORT_COL_CONTENT + tdhFooter;
                    //body += th2Header + Label.WEEKLY_ISSUE_REPORT_COL_CONTENT + tdhFooter;
                    //body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_ORDER + tdhFooter;
                    //body += td1Header + Integer.valueOf(record.DisplayOrder__c) + tdhFooter;
                    body += trFooter;

                    body += trHeader;
                    body += td4Header + record.Contents__c + tdhFooter;
                    body += trFooter;

                    body += tableFooter;
                    body += divFooter;
                }

                contents = '<div id="content-body">' + body + '</div>';
            }
        } catch (StringException e) {
            throw new AuraHandledException(Label.WEEKLY_ISSUE_REPORT_STRING_EXCEPTION);
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return contents;
    }

    @AuraEnabled
    public static list<WeeklyReport__c> getIssueReports(Date reportDate , String filterName){// v1.6 added filterName parameter by vipul
        list<WeeklyReport__c> lstWR = new list<WeeklyReport__c>();
        try {
            Date startDate = reportDate.toStartOfWeek();
            Date endDate = startDate.addDays(7);
            list<User> owners = RoleUtil.getAllSubordinates(UserInfo.getUserRoleId());
            // v1.3 - Gitesh Saini
            if(filterName != null){ // Start v1.6 added by vipul
                String filterNameData = '%'+filterName+'%';
                lstWR = [SELECT Id, Name, OwnerId, Owner.Alias, Owner.Name, Department__c, 
                         Opportunity__c, Opportunity__r.Name, Opportunity__r.AccountId, Opportunity__r.Account.Name,
                         SalesLead__c, SalesLead__r.Name, SalesLead__r.AccountId__c, SalesLead__r.AccountId__r.Name,
                         DisplayOrder__c, IssueDescription__c, Issue_Description_Check__c, ReportingDate__c, CreatedBy.Name, CreatedById
                         FROM WeeklyReport__c
                         WHERE CheckedforIssue__c = true
                         AND ReportingDate__c >= :startDate
                         AND ReportingDate__c < :endDate
                         AND OwnerId IN :owners AND NAME LIKE :filterNameData
                         ORDER BY DisplayOrder__c ASC];  
            } // end v1.6 added by vipul
            else{
              lstWR = [SELECT Id, Name, OwnerId, Owner.Alias, Owner.Name, Department__c, 
                        Opportunity__c, Opportunity__r.Name, Opportunity__r.AccountId, Opportunity__r.Account.Name,
                        SalesLead__c, SalesLead__r.Name, SalesLead__r.AccountId__c, SalesLead__r.AccountId__r.Name,
                        DisplayOrder__c, IssueDescription__c, Issue_Description_Check__c, ReportingDate__c, CreatedBy.Name, CreatedById
                     FROM WeeklyReport__c
                     WHERE CheckedforIssue__c = true
                        AND ReportingDate__c >= :startDate
                        AND ReportingDate__c < :endDate
                        AND OwnerId IN :owners 
                     ORDER BY DisplayOrder__c ASC];    
            }
            
            // v1.3
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return lstWR;
    }

    @AuraEnabled
    public static WeeklyReport__c getIssueReport(String recordId){
        WeeklyReport__c record = new WeeklyReport__c();
        try {
            record = [SELECT Id, Name, OwnerId, Owner.Alias, Owner.Name, Department__c, Account_Name__c, 
                        Opportunity__c, Opportunity__r.Name, Opportunity__r.AccountId, Opportunity__r.Account.Name,
                        SalesLead__c, SalesLead__r.Name, SalesLead__r.AccountId__c, SalesLead__r.AccountId__r.Name,
                        DisplayOrder__c, IssueDescription__c, Issue_Description_Check__c, ReportingDate__c
                      FROM WeeklyReport__c
                      WHERE Id = :recordId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return record;
    }

    @AuraEnabled
    public static Boolean saveIssuesContent(String recordId, String content, Integer order, String contentNew){
        try {
            WeeklyReport__c record = new WeeklyReport__c();
            record.Id = recordId;
            record.IssueDescription__c = content;
            record.Issue_Description_Check__c = contentNew;
            if(order != null) record.DisplayOrder__c = order;
            
            update record;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return true;
    }

    @AuraEnabled
    public static String getEmailIssuesContents(list<String> reportIds){
        list<WeeklyReport__c> records = new list<WeeklyReport__c>();
        String contents = '';
        try {
            records = [SELECT Id, Name, OwnerId, Owner.Alias, Owner.Name, Department__c,
                        Opportunity__c, Opportunity__r.Name, Opportunity__r.AccountId, Opportunity__r.Account.Name,
                        SalesLead__c, SalesLead__r.Name, SalesLead__r.AccountId__c, SalesLead__r.AccountId__r.Name,
                        DisplayOrder__c, IssueDescription__c, Issue_Description_Check__c, ReportingDate__c
                       FROM WeeklyReport__c
                       WHERE Id IN :reportIds 
                       ORDER BY DisplayOrder__c ASC];
            String myDomain = 'https://' + getMyDomain() + '.lightning.force.com';
            String body = '';
            String divHeader   = '<div style="padding-bottom: 8px;">';
            String divFooter   = '</div>';
            String tableHeader = '<table border="0" cellpadding="0" cellspacing="0" style="background-color: #F3F2F2;font-family:tahoma;font-size:10pt;border-top:0.1px solid black;border-left:0.1px solid black;border-right:0.1px solid black;border-bottom:0.1px solid black;">';
            String tableFooter = '</table>';
            String trHeader    = '<tr>';
            String trFooter    = '</tr>';
            String th1Header   = '<td style="width:150px;line-height:32px;text-align:right;vertical-align:middle;font-weight:bold;white-space:nowrap;border: 0.1px solid black;padding-right:16px;padding-left:16px;">';
            String th2Header   = '<td colspan="2" style="line-height:32px;text-align:left;vertical-align:middle;font-weight:bold;white-space:nowrap;border: 0.1px solid black;padding-right:16px;padding-left:16px;">';
            String th4Header   = '<td colspan="4" style="line-height:32px;text-align:left;vertical-align:middle;font-weight:bold;white-space:nowrap;border: 0.1px solid black;padding-right:16px;padding-left:16px;">';
            String td1Header   = '<td width="50%" style="background-color:#ffffff;border: 0.1px solid black;line-height:32px;padding-right:16px;padding-left:16px;">';
            String td3Header   = '<td colspan="3" style="background-color:#ffffff;border: 0.1px solid black;line-height:32px;padding-right:16px;padding-left:16px;">';
            String td4Header   = '<td colspan="4" style="background-color:#ffffff;border: 0.1px solid black;padding:16px;">';
            String tdhFooter   = '</td>';

            if(!records.isEmpty()){
                for(WeeklyReport__c record : records){
                    body += divHeader;
                    body += tableHeader;

                    body += trHeader;
                    body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_NAME + tdhFooter;
                    body += td1Header + '<a href="' + myDomain + '/lightning/r/WeeklyReport__c/' + record.Id + '/view" target="_blank">' +  + record.Name.escapeHtml4() + '</a>' + tdhFooter;
                    body += th1Header + Label.WEEKLY_ISSUE_REPORT_DEPT_NAME + tdhFooter;
                    body += td1Header + record.Department__c + tdhFooter;
                    body += trFooter;

                    body += trHeader;
                    if(record.Opportunity__c != null){
                        String opptyName = record.Opportunity__r.Name;
                        body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_OPPORTUNITY + tdhFooter;
                        body += td1Header + '<a href="' + myDomain + '/lightning/r/Opportunity/' + record.Opportunity__c + '/view" target="_blank">' + opptyName.escapeHtml4() + '</a>' + tdhFooter;
                    } else if(record.SalesLead__c != null){
                        String leadName = record.SalesLead__r.Name;
                        body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_OPPORTUNITY + tdhFooter;
                        body += td1Header + '<a href="' + myDomain + '/lightning/r/Sales_Lead__c/' + record.SalesLead__c + '/view" target="_blank">' + leadName.escapeHtml4() + '</a>' + tdhFooter;
                    } else {
                        body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_OPPORTUNITY + tdhFooter;
                        body += td1Header + '' + tdhFooter;
                    }
                    body += th1Header + Label.WEEKLY_ISSUE_REPORT_OWNER_NAME + tdhFooter;
                    body += td1Header + record.Owner.Name + tdhFooter;
                    body += trFooter;

                    String accountName = '';
                    String reportDate = '';
                    if(record.Opportunity__c != null && record.Opportunity__r.AccountId != null) accountName = record.Opportunity__r.Account.Name;
                    if(record.SalesLead__c != null && record.SalesLead__r.AccountId__c != null) accountName = record.SalesLead__r.AccountId__r.Name;
                    if(record.ReportingDate__c != null){
                        Date rt = record.ReportingDate__c;
                        reportDate = String.valueOf(rt.year()) + '-' + String.valueOf(rt.month()).leftPad(2, '0') + '-' + String.valueOf(rt.day()).leftPad(2, '0');
                    }
                    body += trHeader;
                    body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_ACCOUNT + tdhFooter;
                    body += td1Header + '<a href="' + myDomain + '/lightning/r/Account/' + record.Opportunity__r.AccountId + '/view" target="_blank">' + accountName.escapeHtml4() + '</a>' + tdhFooter;
                    body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_REPORTDATE + tdhFooter;
                    body += td1Header + reportDate.escapeHtml4() + tdhFooter;
                    body += trFooter;

                    body += trHeader;
                    body += th4Header + Label.WEEKLY_ISSUE_REPORT_COL_CONTENT + tdhFooter;
                    //body += th2Header + Label.WEEKLY_ISSUE_REPORT_COL_CONTENT + tdhFooter;
                    //body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_ORDER + tdhFooter;
                    //body += td1Header + Integer.valueOf(record.DisplayOrder__c) + tdhFooter;
                    body += trFooter;
                    // V 1.7 Divyam 
                   /*body += trHeader;
                    body += td4Header + record.IssueDescription__c + tdhFooter;
                    body += trFooter; */
                    
                    //Start - v1.4
                    body += trHeader;
                    body += td4Header + record.Issue_Description_Check__c + tdhFooter;
                    body += trFooter;
					//End - v1.4
                    
                    body += tableFooter;
                    body += divFooter;
                }

                contents = '<div id="content-body">' + body + '</div>';
            }

        } catch (StringException e) {
            throw new AuraHandledException(Label.WEEKLY_ISSUE_REPORT_STRING_EXCEPTION);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return contents;
    }

    @AuraEnabled
    public static Boolean sendReportKnoxEmail(list<String> usrList, String subject, String content){
        Boolean result = false;
        try {
            map<String, Object> resultMap = new map<String, Object>();
            list<String> emails = usrList;
            //list<String> emailString = new list<String>();
            //emailString.add('aditya.r2@stage.samsung.com');
            // list<User> luser = [SELECT Email FROM User WHERE Id IN :usrList];
            // if(!luser.isEmpty()){
            //     for(User u : luser){
            //         if(u.Email != null)
            //             emails.add(u.Email);
            //     }
            // }
			//emails.add('aditya.r2@stage.samsung.com');
            if(!emails.isEmpty()){
                if(!Test.isRunningTest()){
                    KnoxEmailSendController mailCon = new KnoxEmailSendController();
                    resultMap = mailCon.sendKnoxEmail(null, emails, new list<String>(), new list<String>(), subject, content, new list<map<String, Object>>(), new list<map<String, String>>());
                    // resultMap = mailCon.sendKnoxEmail(
                    //     null,                            // recordId
                    //     emails,                          // to list
                    //     new list<String>(),              // cc list
                    //     new list<String>(),              // bcc list
                    //     subject,                         // subject
                    //     content,                         // mail body
                    //     new list<map<String, Object>>(), // efileList
                    //     new list<map<String, String>>()  // nfileList
                    // );    
                } else {
                    if(subject != null)
                        resultMap.put('result', 'success');
                    else {
                        resultMap.put('result', 'error');
                        resultMap.put('Message', 'error');
                    }
                }
    
                String val = String.valueOf(resultMap.get('result'));
                if(val == 'success') {
                    result = true;
                } else {
                    String msg = 'Knox Email Error!';
                    if(resultMap.get('Message') != null) msg = String.valueOf(resultMap.get('Message'));
                    throw new AuraHandledException(msg);
                }
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }
}