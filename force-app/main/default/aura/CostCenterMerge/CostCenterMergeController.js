/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-07-28
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-06-15   younghoon.kim@dkbmc.com   Initial Version
**/
({
	init : function(component, event, helper) {
		window.console.log('Controller init');

		component.set('v.columns', [
			{label: 'To-Be Opportunity Code Format', fieldName: 'Oppty_CodeFormat_ToBe__c', type: 'text'}
			, {label: 'As-Is Company Code', fieldName: 'CompanyCode_AsIs__c', type: 'text'}
			, {label: 'As-Is Opportunity Code', fieldName: 'OpptyCode_AsIs__c', type: 'text'}
			, {label: 'To-Be Opportunity Sales Dept', fieldName: 'Oppty_SalesDept_ToBe__c', type: 'text'}
			, {label: 'To-Be Opportunity Delivery Dept', fieldName: 'Oppty_DeliveryDept_ToBe__c', type: 'text'}
			, {label: 'Project', fieldName: 'Project__c', type: 'text'}
			, {label: 'Project Code', fieldName: 'ProjectCode__c', type: 'text'}
			, {label: 'Project Description', fieldName: 'ProjectDescription__c', type: 'text'}
			, {label: 'WBS', fieldName: 'WBS__c', type: 'text'}
			, {label: 'WBS Description', fieldName: 'WBSDescription__c', type: 'text'}
			, {label: 'To-Be Service Sales Dept', fieldName: 'Svc_SalesDept_ToBe__c', type: 'text'}
			, {label: 'To-Be Service Delivery Dept', fieldName: 'Svc_DeliveryDept_ToBe__c', type: 'text'}
			, {label: 'Item Number', fieldName: 'ItemNumber__c', type: 'text'}
			, {label: 'Service', fieldName: 'Service__c', type: 'text'}
			, {label: 'Solution', fieldName: 'Solution__c', type: 'text'}
			, {label: 'BizAttribute Code', fieldName: 'BizAttributeCode__c', type: 'text'}
		]);

		helper.doInit(component, event);
	},

	start : function(component, event, helper) {
		window.console.log('Controller start');

		helper.batchStart(component, event);
	},

	refresh : function(component, event, helper) {
		window.console.log('Controller refresh');

		$A.get('e.force:refreshView').fire();
	}
})