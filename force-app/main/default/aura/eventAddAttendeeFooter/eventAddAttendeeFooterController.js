/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 01-20-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   01-14-2021   woomg@dkbmc.com   Initial Version
**/
({
    clickAdd : function(component, event, helper) {
        var addEvent = component.get("v.onadd");
        if(addEvent != null) $A.enqueueAction(addEvent);
    },

    clickCancel : function(component, event, helper) {
        component.find("overlayLib").notifyClose();
    }
})