/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 10-21-2020
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   10-21-2020   woomg@dkbmc.com   Initial Version
**/
@isTest  
private class MiniMETAUtils_Test {

    @isTest
    private static void testMethod1() {
        Test.startTest();
        MiniMETAUtils.ResetAutoNumberField('objectAPIName', 'fieldAPIName', 'field label', '{0000}', 1);
        Test.stopTest();
    }
}