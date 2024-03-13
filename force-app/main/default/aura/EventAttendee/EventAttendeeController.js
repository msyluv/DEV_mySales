/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 01-20-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   01-18-2021   woomg@dkbmc.com   Initial Version
**/
({
	doInit : function(component, event, helper) {
		helper.doInit(component);
	},
    clickAdd : function(component, event, helper) {
        helper.clickAdd(component);
    },
    reloadAttendee : function(component, event, helper) {
        helper.reloadAttendee(component, event);
    },
    addAttendee : function(component, event, helper) {
        var modalBody = component.get("v.modalBody");
        modalBody.addAttendee();
    },
})