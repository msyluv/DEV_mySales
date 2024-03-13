/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 01-06-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   01-05-2021   woomg@dkbmc.com   Initial Version
**/
({
    handleCancel : function(component, event, helper) {
        //closes the modal or popover from the component
        component.find("overlayLib").notifyClose();
    },

    handleSend : function(component, event, helper) {
        var submit = component.get("v.onsubmit");
        $A.enqueueAction(submit);
    }
})