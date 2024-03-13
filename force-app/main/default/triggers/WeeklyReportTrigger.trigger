/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-03-30
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-02-16   younghoon.kim@dkbmc.com   Initial Version
**/
trigger WeeklyReportTrigger on WeeklyReport__c (before delete) {
    System.debug('UserInfo.getUserId() : ' + UserInfo.getUserId());
    System.debug('UserInfo.getName() : ' + UserInfo.getName());
    // Trigger Switch
    TriggerSwitch__c trSwitch = TriggerSwitch__c.getInstance(UserInfo.getUserId()); // Current User 기준으로 Custom Setting 가져옴
    System.debug('trSwitch : ' + trSwitch);
    Boolean weeklyReportSend = trSwitch.WeeklyReportSend__c; // WeeklyReportSend__c가 False인 경우 전송 X
    System.debug('weeklyReportSend : ' + weeklyReportSend);

    switch on trigger.operationType{
        when BEFORE_DELETE{
            if(weeklyReportSend) deleteWeeklyReport(Trigger.old);
        }
    }

    private static void deleteWeeklyReport(List<WeeklyReport__c> wrList){ 
        List<String> targetIdList = new List<String>();
        for(WeeklyReport__c wr : wrList){
            targetIdList.add(wr.Id);
        } 
        
        if(targetIdList.size() > 0){
            IF_LsWeeklyReportController.calloutWeeklyInfo(targetIdList);
        }
    }
}