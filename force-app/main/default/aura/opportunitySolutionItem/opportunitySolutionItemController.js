/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-03-16
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2020-11-18   seonju.jin@dkbmc.com   Initial Version
**/
({
	init : function(component, event, helper) {
		helper.doInit(component);
	},

	addRow: function(component, event){
		var sInstance = component.get('v.sInstance');
		component.getEvent("addRowEvt").setParams({"eventType" : 'solution', 'serviceIdx':sInstance.serviceIdx}).fire();
	},

	removeRow: function(component, event){
		var sInstance = component.get('v.sInstance');
		component.getEvent("removeRowEvt").setParams({"eventType" : 'solution'
			, 'serviceIdx' : sInstance.serviceIdx
			, 'solutionIdx' : component.get('v.rowIndex')}).fire();
	},

	onSolSelectChange: function(component, event, helper){
		helper.onSolSelectChange(component,event);
	},

	onAttrSelectChange: function(component, event, helper){
		helper.onAttrSelectChange(component,event);	
	},

	onSalesTypeSelectChange: function(component, event, helper){
		helper.onSalesTypeSelectChange(component,event);
	},

	rowSelect:function(component,event,helper){
		helper.rowSelect(component);
	},


})