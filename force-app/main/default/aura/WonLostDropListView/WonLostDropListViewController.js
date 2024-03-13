/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-11-12
 * @last modified by  : younghoon.kim@dkbmc.com
**/
({
	init : function(component, event, helper) {
		window.console.log('Controller init');

		component.set('v.selectedValue', {
			'Title' 	 	: '',	// Title
			'OpptyCode'  	: '',	// Opportunity Code
			'WLDType'	 	: '',	// Won/Lost/Drop Type
			'WLDReasonType'	: '', 	// Won/Lost/Drop Reason Type
			'SalesRep'		: {},	// Sales Rep.
			'Owner' 		: {}	// Owner
		});
		helper.doInit(component, event);
	},

	wldTypeChange : function(component, event, helper) {
		window.console.log('Controller wldTypeChange');
		
		component.set('v.wldReasonType', []);
		component.set('v.selectedValue.WLDReasonType', '');
		helper.getWLDReasonType(component, event);
	},

	loadMoreData: function (component, event, helper) {
		window.console.log('Controller loadMoreData');

		event.getSource().set("v.isLoading", true);
		component.set('v.loadMoreStatus', $A.get( "$Label.c.COLLABO_MSG_0007")); // Loading...
		
		helper.getData(component, event, 'MORE');
	},
	
	search : function(component, event, helper) {
		window.console.log('Controller search');
		
		helper.getData(component, event, 'INIT');
    },

	new : function(component, event, helper) {
		window.console.log('Controller new');

		var createRecordEvent = $A.get("e.force:createRecord");
		createRecordEvent.setParams({
			"entityApiName": "Won_Lost_Drop__c"
		});
		createRecordEvent.fire();
	},

	scriptLoaded : function(component, event, helper) {
		window.console.log('Controller scriptLoaded');

        helper.scriptLoaded(component, event);
    },

	handleSort: function(component, event, helper) {
		window.console.log('Controller handleSort');

        helper.handleSort(component, event);
    }
})