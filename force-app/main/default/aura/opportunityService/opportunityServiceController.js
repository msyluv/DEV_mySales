/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2022-01-17
 * @last modified by  : seonju.jin@dkbmc.com
 * 
**/
({
	init : function(component, event, helper) {
		helper.initService(component);
	},

	rowSelect: function(component, event, helper){
		var itemId = event.currentTarget.getAttribute("data-itemId"); 
		component.set('v.currIndex',itemId.replace('svc_',''));
		helper.rowSelect(component);
	},

	setIndex:function(component, event){
		var itemId = event.currentTarget.getAttribute("data-itemId"); 
		component.set('v.currIndex',itemId.replace('svc_',''));
	},

	onTechynChange: function(component, event, helper){
		helper.onTechynChange(component, event);
	},

	/* forceChangeTA: function(component, event, helper){
		helper.forceChangeTA(component, event);
	}, */

	addRow: function(component, event, helper){
		helper.addRow(component);
	},

	removeRow: function(component, event, helper){
		var itemId = event.currentTarget.getAttribute("data-itemId"); 
		var currIndex = itemId.replace('svc_','');
		if(confirm($A.get("$Label.c.SVC_DEL_MSG"))){	//Are you sure you want to delete the service?
			helper.removeRow(component, currIndex);
		}
	},

	onClickCustomlookup: function(component, event, helper){
		helper.onClickCustomlookup(component, event);
	},

	onSvcSelectChange: function(component, event, helper){
		helper.onSvcSelectChange(component, event);
	},
	
	onDeptSelectChange: function(component, event, helper){
		helper.onDeptSelectChange(component, event);
	},

	/**
	 * 현재 선택된 index 값 설정
	 */
	 onCombofocus:function(component, event, helper){
		var itemId = event.getSource().get('v.name'); 
		component.set('v.currIndex',itemId.replace('comboSvc_',''));
		helper.rowSelect(component);
	},

	handleSelect: function(component, event, helper){
		helper.handleSelect(component);
	},

	refreshSol: function(comonent, event, helper){
		helper.solRefresh(comonent);
	},
})