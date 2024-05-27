/**
 * @description       : 
 * @author            : akash.g@samsung.com
 * @group             : 
 * @last modified on  : 2024-05-09
 * @last modified by  : akash.g@samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2024-05-09   akash.g@samsung.com              Initial Version(MYSALES -499)
**/
({
    doInit: function(component, event, helper) {
        component.set('v.selectedValue', {
			'BOName' : '',
			'Status' : '',
			'Owner' : {},
			'OpptyCode' : '',
			'SalesDept' : {},
			'PrimarySalesDept' : {}
		});
        var opMap = new Map(component.get("v.SelectedOpportunityMap"));
        component.set('v.TempOpportunityMap', opMap);
        helper.doInit(component, event);
    },
    search: function(component, event, helper) {
        //var pageNumber = component.get("v.PageNumber"); 
        var pageSize = 20; 
        var selectedValue = component.get("v.selectedValue");  
        helper.getOpportunityList(component, 1, pageSize,selectedValue);
    },
     
    handleNext: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = 20;
        pageNumber++;
        var selectedValue = component.get("v.selectedValue"); 
        helper.getOpportunityList(component, pageNumber, pageSize,selectedValue);
    },
     
    handlePrev: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = 20;
        pageNumber--;
        var selectedValue = component.get("v.selectedValue"); 
        helper.getOpportunityList(component, pageNumber, pageSize,selectedValue);
    },
     
    onSelectChange: function(component, event, helper) {
        var page = 1
        var pageSize = 20;
        var selectedValue = component.get("v.selectedValue"); 
        helper.getOpportunityList(component, page, pageSize,selectedValue);
    },
    setBoxes: function(component,event){
        var oppMap = component.get("v.OpportunityMap");
        var selectedopp = component.get("v.SelectedOpportunityMap");
        if(selectedopp.has(event.target.name)){
            selectedopp.delete(event.target.name);
        }else{
            selectedopp.set(event.target.name,oppMap.get(event.target.name));
        }
        component.set("v.SelectedOpportunityMap",selectedopp);
    },
    clickSelect: function(component,event){
		component.find('overlayLib').notifyClose();
    },
    clickCancel: function(component,event){
        var temp = component.get("v.TempOpportunityMap");
        component.set('v.SelectedOpportunityMap', temp);
		component.find('overlayLib').notifyClose();
    }
})