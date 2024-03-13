/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2024-02-06
 * @last modified by  : sarthak.j1@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-11-26   younghoon.kim@dkbmc.com   Initial Version
 * 1.1   2024-02-06   sarthak.j1@samsung.com    MYSALES-443
**/
({
	doInit : function(component, event, helper) {
		// Data table column setting
		component.set('v.columns', [
			{label: $A.get( "$Label.c.COLLABO_LAB_OPPTYNAME"), fieldName: 'Name', type: 'text'}
            , {label: $A.get( "$Label.c.COLLABO_LAB_ACCNAME"), fieldName: 'AccName', type: 'text'}
            , {label: $A.get( "$Label.c.COLLABO_LAB_CLOSEDATE"), fieldName: 'CloseDate', type: 'date'}
			, {label: $A.get( "$Label.c.COLLABO_LAB_AMOUNT"), fieldName: 'Amount', type: 'number'}
			, {label: $A.get( "$Label.c.COLLABO_LAB_CURRENCY"), fieldName: 'Currency', type: 'text'}
			, {label: $A.get( "$Label.c.COLLABO_LAB_STAGE"), fieldName: 'StageName', type: 'text'}
			, {label: $A.get( "$Label.c.COLLABO_LAB_OPPTYCODE"), fieldName: 'OpptyCode', type: 'url', typeAttributes: { label: { fieldName : 'opportunityCode'}, target: '_black'}}
            , {label: $A.get( "$Label.c.COLLABO_LAB_COMPANYCODE"), fieldName: 'CompanyCode', type: 'text'}
			, {label: $A.get( "$Label.c.COLLABO_LAB_COMPANYNAME"), fieldName: 'CompanyName', type: 'text'}
            , {label: $A.get( "$Label.c.COLLABO_LAB_STATUS"), fieldName: 'Status', type: 'text'}
			// , {label: 'In/Out', fieldName: 'InOut', cellAttributes: {"iconName": {"fieldName": "displayIconName"}}}
		]);

		// spinner start
		component.set("v.showSpinner", true);
		component.set("v.myOpptySpinner", true);
		component.set("v.collaboOpptySpinner", true);

		// helperInit call
		helper.helperInit(component, event);
	},

	search : function(component, event, helper) {
        component.set('v.selectedRows', []); //Added as part of v-1.1 [MYSALES-443]
		component.set('v.rowNumberOffset', 0);
		component.set('v.totalNumberOfRows', 0);
		component.set('v.enableInfiniteLoading', true);
		component.set('v.myOppty', '');
		component.set('v.collaboOppty', '');

		component.set("v.showSpinner", true);
		component.set("v.myOpptySpinner", true);
		component.set("v.collaboOpptySpinner", true);

		helper.getOpptyList(component, event, 'INIT');
	},

	loadMoreData: function (component, event, helper) {
		// Infinite loading start
		event.getSource().set("v.isLoading", true);
		component.set('v.loadMoreStatus', $A.get( "$Label.c.COLLABO_MSG_0007")); // Loading...
		
		helper.getOpptyList(component, event, 'MORE');
	},
	
	columnSelect : function(component, event, helper) {        
		if(event.getSource().get("v.isLoading")) return;
        
        component.set('v.myOppty', '');
		component.set('v.collaboOppty', '');
		
		// spinner start
		// component.set("v.showSpinner", true);
		component.set("v.myOpptySpinner", true);
		component.set("v.collaboOpptySpinner", true);

		// My Opportunity set
        var selectedRow = event.getParam('selectedRows');
        component.set('v.myOppty', selectedRow[0].Id);
		
		// getOpptyInfo call
		helper.getOpptyInfo(component, event, selectedRow[0].CollaborationId);
	},

	openMyOppty : function(component, event, helper) {
		let hostname = window.location.hostname;
		if(component.get('v.myOppty') != '') window.open('https://' + hostname + '/' + component.get('v.myOppty'));
	},

	openCollaboOppty : function(component, event, helper) {
		let hostname = window.location.hostname;
		if(component.get('v.collaboOppty') != '') window.open('https://' + hostname + '/' + component.get('v.collaboOppty'));
	}
})