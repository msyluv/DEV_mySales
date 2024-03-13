/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 04-05-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   04-05-2021   woomg@dkbmc.com   Initial Version
**/
@isTest
public with sharing class Flow_OpportunityCheckPermission_Test {
    @isTest 
    static void testFeedItem() {
        system.debug(Flow_OpportunityCheckPermission.checkPermission());
    }
}