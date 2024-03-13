/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 05-10-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   01-06-2021   woomg@dkbmc.com   Initial Version
**/
@isTest
public without sharing class WeeklyIssueReportController_Test {
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

        wr = new WeeklyReport__c(Name = 'Weekly Report', ReportingDate__c = system.today(), CheckedforIssue__c = true,
                                    IssueDescription__c = '<div>test</div>'
        );

        insert wr;
    }

    @isTest static void testMethodOne() {
		Test.startTest();
        system.debug(WeeklyIssueReportController.getMyDomain());
        system.debug(WeeklyIssueReportController.getWeeklyReports(system.today()));
        system.debug(WeeklyIssueReportController.getWeeklyReport(wr.Id));
        system.debug(WeeklyIssueReportController.saveContent(wr.Id, '<div>update</div>', 1));
        list<String> emails = new list<String>();
        emails.add('user@email.com');
        system.debug(WeeklyIssueReportController.sendIssueKnoxEmail(emails, 'subject', '<div>update</div>'));
        list<String> lwr = new list<String>{wr.Id};
        system.debug(WeeklyIssueReportController.getEmailContents(lwr));
		Test.stopTest();
	}

    @isTest static void testMethodTwo() {
        Test.startTest();
        try {
            system.debug(WeeklyIssueReportController.getWeeklyReports(null));
        } catch(Exception e){
            //
        }
        try {
            system.debug(WeeklyIssueReportController.getWeeklyReport('000000'));
        } catch(Exception e){
            //
        }
        try {
            system.debug(WeeklyIssueReportController.saveContent(null, '<div>update</div>', 1));
        } catch(Exception e){
            //
        }
        try {
            list<String> emails = new list<String>();
            emails.add('user@email.com');
            system.debug(WeeklyIssueReportController.sendIssueKnoxEmail(emails, 'subject', '<div>update</div>'));
        } catch(Exception e){
            //
        }
        try {
            list<String> emails = new list<String>();
            emails.add('user@email.com');
            system.debug(WeeklyIssueReportController.sendIssueKnoxEmail(emails, null, '<div>update</div>'));
        } catch(Exception e){
            //
        }

		Test.stopTest();
	}

}