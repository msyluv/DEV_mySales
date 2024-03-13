/**
 * @description       : 
 * @author            : yeongju.baek@dkbmc.com
 * @group             : 
 * @last modified on  : 04-06-2022
 * @last modified by  : yeongju.baek@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   04-01-2022   yeongju.baek@dkbmc.com   Initial Version
**/
({
	init : function(component, event, helper) {
		console.log('Preview init');
		helper.doInit(component, event);
		
		// helper.helperInit(component, event, '-', true);
	},

	getApprovalBody : function (component, event, helper) {
		
        helper.getApprovalBody(component, event);
	},

	clickCancel: function(component, event, helper) {
        component.find("overlayLib").notifyClose();
	},

	clickApprove : function(component, event, helper) {
        helper.clickApprove(component, event);
	},
	
	setKnoxApprovalField : function(component, event, helper) {
        helper.setKnoxApprovalField(component, event);
    },

	firePreviewPassEvent : function(component, event, helper) {
		console.log('firePreviewPassEvent');
		helper.firePreviewPassEvent(component, event);
	},

	setApexLoading : function(component, event, helper) {
		console.log(' ## event.getParam("isApexLoading") ', event.getParam("isApexLoading"));
		component.set('v.isApexLoading', event.getParam("isApexLoading") );
	}
})