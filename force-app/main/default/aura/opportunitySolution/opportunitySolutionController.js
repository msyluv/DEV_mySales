/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2022-01-24
 * @last modified by  : seonju.jin@dkbmc.com
**/
({
	init : function(component, event, helper) {
		helper.getSolutions(component);
		helper.getSalesTypeInfo(component);	

		try{
			var solList = component.get('v.solList');
			var solCnt = 0;
			for(var i = 0; i < solList.length; i++){
				var obj = solList[i].solution;
				if(obj.isDeleted) continue;
				solCnt++;
			}
	
			if(solCnt == 0 ) helper.addRow(component);
		}catch(e){
			console.log(e);
		}
		
	},

	//솔루션 추가
	addRow: function(component, event, helper){
		var itemId = event.currentTarget.getAttribute("data-itemId"); 
		var currIndex = itemId.replace('sol_','');
		component.set('v.currIndex',currIndex);

		helper.addRow(component);
	},

	//솔루션 삭제
	removeRow: function(component, event, helper){
		var itemId = event.currentTarget.getAttribute("data-itemId"); 
		var currIndex = itemId.replace('sol_','');
		component.set('v.currIndex',currIndex);
		helper.removeRow(component);
	},

	//솔루션 행 선택
	rowSelect: function(component, event, helper){
		helper.rowSelect(component, event);
	},

	onSolSelectChange:function(component, event, helper){
		helper.onSolSelectChange(component, event);
	},
	
	onAttrSelectChange:function(component, event, helper){
		helper.onAttrSelectChange(component, event);
	},

	onSalesTypeSelectChange:function(component, event, helper){
		helper.onSalesTypeSelectChange(component,event);
	},

	refreshCmp: function(component){
		component.set('v.refresh',false);
		component.set('v.refresh',true);
	},
})