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
public with sharing class Flow_OpportunityCheckPermission {
    @InvocableMethod(label='Check Opportunity Permission' description='Check Opportunity Permission')
    public static list<Boolean> checkPermission(){
        return new list<Boolean>{Schema.sObjectType.Opportunity.fields.Name.isCreateable()};
    }
}