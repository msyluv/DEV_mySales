/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 12-18-2020
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   12-18-2020   woomg@dkbmc.com   Initial Version
**/
({
    clickSave : function(component, event, helper) {
        var submit = component.get("v.onsubmit");
        $A.enqueueAction(submit);
    },

    clickCancel : function(component, event, helper) {
        component.find("overlayLib").notifyClose();
    }

})