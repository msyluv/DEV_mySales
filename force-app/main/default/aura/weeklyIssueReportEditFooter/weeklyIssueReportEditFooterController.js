/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 01-04-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   01-04-2021   woomg@dkbmc.com   Initial Version
**/
({
    handleCancel : function(component, event, helper) {
        //closes the modal or popover from the component
        component.find("overlayLib").notifyClose();
    },

    handleSave : function(component, event, helper) {
        var submit = component.get("v.onsubmit");
        $A.enqueueAction(submit);
    }
})