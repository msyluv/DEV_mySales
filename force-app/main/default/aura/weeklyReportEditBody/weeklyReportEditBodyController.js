/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 02-04-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   02-04-2021   woomg@dkbmc.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        helper.doInit(component, event);
    },

    clickSave : function(component, event, helper) {
        helper.saveContent(component);
    },

})