/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 02-24-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   02-24-2021   woomg@dkbmc.com   Initial Version
**/
@isTest
public class Schedule_ResetAutoNumberOpportunity_Test {
    @isTest
    public static void testMethodOne() {
        Test.startTest();
        System.schedule('Reset AutoNember Field of Opportunity', '0 0 0 1 1 ? *', new Schedule_ResetAutoNumberOpportunity());
        Test.stopTest();
    }
}