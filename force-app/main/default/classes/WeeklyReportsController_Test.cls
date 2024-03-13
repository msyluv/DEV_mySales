/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 05-10-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   02-04-2021   woomg@dkbmc.com   Initial Version
**/
@isTest
public without sharing class WeeklyReportsController_Test {
    public static WeeklyReport__c wr;
    static {
        // [Trigger Switch Setting ]
        TriggerSwitch__c profileSwitch = new TriggerSwitch__c(
            All__c = true,
            Opportunity__c = true,
            SetupOwnerId = UserInfo.getProfileId()
        );
        insert profileSwitch;

        RecordType recordId = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'HQ' Limit 1];
        
        Account accAct = new Account(Name = 'accTest', MDGCheck__c = true);

        insert accAct;

        Opportunity oppty = new Opportunity(Name ='Test', RecordTypeId = recordId.Id, AccountId =accAct.Id,
                                            CloseDate =System.today(), StageName = 'Z01');
        insert oppty;

        wr = new WeeklyReport__c(
            Name = 'Weekly Report', 
            ReportingDate__c = system.today(), 
            Critical__c = true,
            Contents__c = 'longtext contents',
            CheckedforIssue__c = true,
            IssueDescription__c = '<div>test</div>'
        );

        insert wr;
    }

    @isTest static void testMethodOne() {
		Test.startTest();
        system.debug(WeeklyReportsController.getMyDomain());
        system.debug(WeeklyReportsController.getWeeklyReports(system.today()));
        system.debug(WeeklyReportsController.getIssueReports(system.today()));
        system.debug(WeeklyReportsController.getWeeklyReport(wr.Id));
        system.debug(WeeklyReportsController.getIssueReport(wr.Id));
        system.debug(WeeklyReportsController.saveWeeklyContent(wr.Id, '<div>update</div>', 1));
        system.debug(WeeklyReportsController.saveIssuesContent(wr.Id, '<div>update</div>', 1));
        list<String> lwr = new list<String>{wr.Id};
        system.debug(WeeklyReportsController.getEmailWeeklyContents(lwr));
        system.debug(WeeklyReportsController.getEmailIssuesContents(lwr));
        list<String> emails = new list<String>();
        emails.add('user@email.com');
        system.debug(WeeklyReportsController.sendReportKnoxEmail(emails, 'subject', '<div>update</div>'));
		Test.stopTest();
	}

    @isTest static void testMethodTwo() {
        Test.startTest();
        try {
            system.debug(WeeklyReportsController.getWeeklyReports(null));
        } catch(Exception e){
            //
        }
        try {
            system.debug(WeeklyReportsController.getWeeklyReport('000000'));
        } catch(Exception e){
            //
        }
        try {
            system.debug(WeeklyReportsController.saveWeeklyContent(null, '<div>update</div>', 1));
        } catch(Exception e){
            //
        }
		Test.stopTest();
	}

    @isTest static void testMethodThree() {
        Test.startTest();
        try {
            system.debug(WeeklyReportsController.getIssueReports(null));
        } catch(Exception e){
            //
        }
        try {
            system.debug(WeeklyReportsController.getIssueReport('000000'));
        } catch(Exception e){
            //
        }
        try {
            system.debug(WeeklyReportsController.saveIssuesContent(null, '<div>update</div>', 1));
        } catch(Exception e){
            //
        }
		Test.stopTest();
	}

    @isTest static void testMethodFour() {
        Test.startTest();
        try {
            list<String> emails = new list<String>();
            emails.add('user@email.com');
            system.debug(WeeklyReportsController.sendReportKnoxEmail(emails, 'subject', '<div>update</div>'));
        } catch(Exception e){
            //
        }
        try {
            list<String> emails = new list<String>();
            emails.add('user@email.com');
            system.debug(WeeklyReportsController.sendReportKnoxEmail(emails, null, '<div>update</div>'));
        } catch(Exception e){
            //
        }
		Test.stopTest();
	}
}