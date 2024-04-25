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
        //var opMap = new Map();
        //component.set('v.SelectedOpportunityMap', opMap);
        helper.doInit(component, event);
    },
    search: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber"); 
        var pageSize = 10; 
        var selectedValue = component.get("v.selectedValue");  
        helper.getOpportunityList(component, pageNumber, pageSize,selectedValue);
    },
     
    handleNext: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = 10;
        pageNumber++;
        var selectedValue = component.get("v.selectedValue"); 
        helper.getOpportunityList(component, pageNumber, pageSize,selectedValue);
    },
     
    handlePrev: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = 10;
        pageNumber--;
        var selectedValue = component.get("v.selectedValue"); 
        helper.getOpportunityList(component, pageNumber, pageSize,selectedValue);
    },
     
    onSelectChange: function(component, event, helper) {
        var page = 1
        var pageSize = 10;
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
        var selectedopp = component.get("v.SelectedOpportunityMap");
        console.log(event.target.name);
    },
    clickSelect: function(component,event){
        var selectedopp = component.get("v.SelectedOpportunityMap");
        /*for(var [key,value] of selectedopp){
            console.log('Key: '+key+' and Value: '+JSON.stringify(value));
        }*/
        var cmpEvent = component.getEvent("selectedOppEvent"); 
        cmpEvent.setParams({"SelectedOpportunityMap": selectedopp}); 
        cmpEvent.fire();
		component.find('overlayLib').notifyClose();
    }
})