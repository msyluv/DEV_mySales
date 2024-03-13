/**
 * @author            : vikrant.ks@samsung.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2024-01-24
 * @last modified by  : vikrant.ks@samsung.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2024-01-16   vikrant.ks@samsung.com   Initial Version(MySales-389)
**/
({
	onRender : function(component, event, helper) {
		let SalesLeadId = component.get('v.recordId');
        
        var action = component.get('c.OwnerChangeAlertMsg');
        action.setParams({'SalesLeadId' : SalesLeadId});
        action.setCallback( this, function(callbackResult) {
            if(callbackResult.getState()=='SUCCESS') {
                if(callbackResult.getReturnValue() == 'NoOwnerChange'){}
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Warning',
                        type : 'warning',
                        message : callbackResult.getReturnValue()
                    });
                    toastEvent.fire();
                }
            }
            if(callbackResult.getState()=='ERROR') {
                console.log('ERROR', callbackResult.getError()); 
            }
            
        });
        $A.enqueueAction( action );
        
	},
    onInit : function(component, event, helper) {
		
	}
})