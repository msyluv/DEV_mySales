/**
 * @description       : 
 * @author            : d.ashish@samsung.com
 * @group             : 
 * @last modified on  : 2024-02-22
 * @last modified by  : d.ashish@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2024-02-22   d.ashish@samsung.com          Initial Version
 **/

trigger OppRevenueSchTrigger on RevenueScheduleOpportunity__c (before insert, before delete, after insert, after update) {
	
    if(trigger.isAfter && (trigger.isUpdate || trigger.isInsert)){
                OppRevenueSchTriggerHandler.afterUpdate(trigger.new , null, null);
    }
}