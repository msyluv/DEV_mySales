({	
    onRender : function(component, event, helper) {       
        console.log("recordId = " + component.get('v.recordId'));
        helper.doInit(component, event);
    }
})