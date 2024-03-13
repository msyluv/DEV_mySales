({
    doInit : function(component, event, helper) {
        component.set('v.startDate', '2020-01-01 00:00:00');
        var today = $A.localizationService.formatDate(new Date(), "yyyy-MM-dd 23:59:59");
    	component.set('v.endDate', today);
    },
	export : function(component, event, helper) {		
		helper.export(component, event);
    },
    onChange: function(component, event, helper) {
        component.set('v.isModified',event.getSource().get('v.checked'));      
    }
})