({
    doInitHelper : function(component, event, helper) {
        
        // To make step 1 Active
		var circle = component.find('circle1');
        var label = component.find('label1');
        $A.util.toggleClass(circle, 'activeStep');
        $A.util.toggleClass(circle, 'activeBackground');
        $A.util.toggleClass(label, 'activeLabel');		
	},
    
	updateCss : function(component, event, helper) {
        
        // To toggle the CSS to make step Active/Deactive
        var intCurrentStep = component.get('v.intCurrentStep');
		var circle = component.find('circle' +intCurrentStep);
        var label = component.find('label' +intCurrentStep);
        var line = component.find('line' +(intCurrentStep-1));
        var check = component.find('check' +intCurrentStep);
        $A.util.toggleClass(circle, 'activeStep');
        $A.util.toggleClass(circle, 'activeBackground');
        $A.util.toggleClass(label, 'activeLabel');
        $A.util.toggleClass(line, 'activeBackground');
        $A.util.toggleClass(check, 'activeBackground');
        $A.util.toggleClass(check, 'activeStep');
	}
})