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
public class WeeklyReportExtension {
    public List<WeeklyReport__c> selectedWeeklyReports;
    public String weeklyReportIds;
    public String recordId;
    
    // Constructor
    public WeeklyReportExtension(ApexPages.StandardSetController cntlr) {
        selectedWeeklyReports = cntlr.getSelected();
        weeklyReportIds = '';  
        for(WeeklyReport__c wr : selectedWeeklyReports){
            weeklyReportIds += wr.Id + '-';
        }
        weeklyReportIds = weeklyReportIds.removeEnd('-');
    }
    
    public PageReference redirectToLC() {
        recordId = ApexPages.CurrentPage().getparameters().get('id');
        String returnUrl = '/lightning/cmp/c__WeeklyReportComponent?c__listofWeeklyReports='+weeklyReportIds+'&c__id='+recordId;
        PageReference returnPage = new PageReference(returnUrl);
        returnPage.setRedirect(true);
        return returnPage;
    }
}