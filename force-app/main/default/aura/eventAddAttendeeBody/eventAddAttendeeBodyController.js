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
    doInit : function(component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        if(device != "DESKTOP"){
            component.set('v.isMobile',true);
        }
        helper.doInit(component, event);
    },

    addAttendee: function(component, event, helper) {
		helper.addAttendee(component, event);
	},

    onChangeSearch: function(component, event, helper) {
		helper.onChangeSearch(component, event);
    },

    onChangeType: function(component, event, helper) {
        helper.onChangeType(component, event);
    },

})