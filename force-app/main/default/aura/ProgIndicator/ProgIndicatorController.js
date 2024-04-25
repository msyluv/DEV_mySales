({
	doInit : function(component, event, helper) {
        helper.doInitHelper(component, event, helper);
	},
    
    handleNext : function(component, event, helper) {
        var intCurrentStep = component.get('v.intCurrentStep');
		component.set('v.intCurrentStep', intCurrentStep + 1);
        helper.updateCss(component, event, helper);
	},
    
    handleBack : function(component, event, helper) {
        helper.updateCss(component, event, helper);
		component.set('v.intCurrentStep', component.get('v.intCurrentStep') - 1);
	}
})