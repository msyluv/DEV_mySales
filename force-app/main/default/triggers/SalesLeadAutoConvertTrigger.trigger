/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 12-07-2020
 * @last modified by  : Junghwa.Kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   12-07-2020   woomg@dkbmc.com   Initial Version
**/
trigger SalesLeadAutoConvertTrigger on Sales_Lead__c (before insert, before update) {

    for(Sales_Lead__c sl : Trigger.new){
        // LeadStage__c 값이 Converted가 아닐경우
        if(sl.LeadStage__c != 'Converted'){
            Integer cnt = 0;
            if(sl.Budget__c) cnt++;
            if(sl.Authority__c) cnt++;
            if(sl.Needs__c) cnt++;
            if(sl.TimeLine__c) cnt++;
            sl.LeadStage__c = cnt >= 2 ? 'Hot':'Warm';
        }
    }
}