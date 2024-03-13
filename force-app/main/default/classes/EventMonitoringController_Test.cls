/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 04-07-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   04-07-2021   woomg@dkbmc.com   Initial Version
**/
@isTest
private with sharing class EventMonitoringController_Test {

    @isTest
    private static void testMethodOne(){
        Test.startTest();
        system.debug(EventMonitoringController.getSessionId());
        system.debug(EventMonitoringController.checkAccessPermission());
        system.debug(EventMonitoringController.getDateRanges());
        system.debug(EventMonitoringController.getEventTypes());
        String logDate = system.now().addDays(-3).format('yyyy-MM-dd');
        system.debug(EventMonitoringController.getEventLogs('Login', 'Daily', logDate));
        system.debug(EventMonitoringController.getEventLogs('Login', 'Hourly', logDate));
        try {
            system.debug(EventMonitoringController.getEventLogs('Login', 'Daily', 'yyyy-mm'));
        } catch(Exception ex){
            //
        }
        Test.stopTest();
    }

}