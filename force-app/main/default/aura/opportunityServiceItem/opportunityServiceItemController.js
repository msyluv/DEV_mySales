/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-10-26
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2020-11-17   seonju.jin@dkbmc.com   Initial Version
**/
({
	init : function(component, event, helper) {
		helper.getService(component);
		
		try {
			var sInstance = component.get('v.sInstance');

			if(sInstance.checked) helper.rowSelect(component);
			component.set('v.orignServiceId',sInstance.serviceId);
			component.set('v.orignDeptInfo',{Id:sInstance.deptRecord.Id,Name:sInstance.deptRecord.Name});
		} catch (error) {
			console.log(error);
		}
	},

	// Service tr onclick event
	rowSelect: function(component, event, helper){
		helper.rowSelect(component);
	},

	addRow: function(component, event, helper){
		component.getEvent("addRowEvt").setParams({"eventType" : 'service'}).fire();
		helper.rowSelect(component);
	},

	removeRow: function(component, event, helper){
		//tr onclick linstener(rowSelect) 이후 작동되도록 timeout
		setTimeout(() => {
			if(confirm($A.get("$Label.c.SVC_DEL_MSG"))){	//Are you sure you want to delete the service?
				component.getEvent("removeRowEvt").setParams({"eventType" : 'service', 'serviceIdx' : component.get('v.rowIndex')}).fire();
			}
		}, 10);
	},

	onClickCustomlookup: function(component, event, helper){
		helper.onClickCustomlookup(component, event);
	},

	onSvcSelectChange: function(component, event, helper){
		helper.onSvcSelect(component, event);
	},
	
	onDeptSelectChange: function(component, event, helper){
		helper.onDeptSelect(component, event);
	},

	recordSelectedEventHandler:function(component,event){
		//console.log('recordSelectedEventHandler');
	},
})