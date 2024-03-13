({
    init : function(component, event, helper) {
        
		let oppId = component.get('v.recordId');
        console.log('oppId: '+oppId);
        var action = component.get("c.DeliveryProbabilityList");        
        action.setParams({"oppId":oppId});
        action.setCallback(this, function (response) { 
            var state = response.getState();
            if (state === 'SUCCESS') {
                var res = response.getReturnValue();
                console.log('res: '+res);
                if(res == ''){
                    component.set("v.DeliveryProbability",$A.get("$Label.c.DeliveryProbabilityDefault"));
                }
                else{
                	component.set("v.DeliveryProbability",res);
                }
            } 
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": ErrorMessage,
                    "type":"error"
                });
                toastEvent.fire();
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                        console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action); 
	},
    View : function(component, event, helper){
        var value = 'True';
        component.set("v.ViewAll",value);
    }
})