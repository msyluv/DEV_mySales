/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 01-12-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   01-11-2021   woomg@dkbmc.com   Initial Version
**/
public with sharing class Flow_RevenueSplitOpportunity {

    @InvocableMethod(label='Create Splitted Revenue' description='Create Splitted Revenue')
    public static list<list<RevenueScheduleOpportunity__c>> createRevenues(list<String> params){
         system.debug('Opportunity one called');
        list<RevenueScheduleOpportunity__c> lrs = RevenueScheduleController.getNewOpportunitySchedules(params[0]);
        
        return new list<list<RevenueScheduleOpportunity__c>>{lrs};
    }
}