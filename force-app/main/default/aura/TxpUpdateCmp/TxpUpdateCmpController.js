({
    onUpdate : function(component, event, helper) {
        let ErrorMessage = $A.get("$Label.c.TxpErrorMessage");
        let UpdationMessage = $A.get("$Label.c.TxpUpdationMessage");
        component.set("v.UpdationMessage1",UpdationMessage.substring(0,UpdationMessage.indexOf('.')+1));  
        component.set("v.UpdationMessage2",UpdationMessage.substring(UpdationMessage.indexOf('.')+1));  
        let params = new URLSearchParams(document.location.search);
		let oppId = params.get("c__id");
        console.log('recordId: '+oppId);
        component.set("v.OpportunityId",oppId);  
        
        var action = component.get("c.UpdateTXPManpowerInfo");        
        action.setParams({"oppId":oppId});
        action.setCallback(this, function (response) { 
            var state = response.getState();
            if (state === 'SUCCESS') {
                var res = response.getReturnValue(); 
                if(res=='SUCCESS'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "The record has been updated successfully.",
                        "type":"success"
                    });
                    toastEvent.fire();
                }
                else{    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": ErrorMessage,
                        "type":"error"
                    });
                    toastEvent.fire();
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
            setTimeout(() => {window.location.replace('/lightning/r/Opportunity/'+ oppId+'/related/TXP_manpower_input_information__r/view');
							}, "10000");
        });
        $A.enqueueAction(action); 
	},
	onCancel : function(component, event, helper) {
        let oppId = component.get("v.OpportunityId");
        window.location.replace('/lightning/r/Opportunity/'+ oppId+'/related/TXP_manpower_input_information__r/view');
		//window.history.back();
	}
})