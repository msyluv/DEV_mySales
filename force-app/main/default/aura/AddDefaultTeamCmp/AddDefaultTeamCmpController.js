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
    onUpdate : function(component, event, helper) {
        let ErrorMessage = 'Unknowm Error Occured. Please contact system administrator.';
        let UpdationMessage = 'Adding Default Team Members.';
        component.set("v.UpdationMessage1",UpdationMessage.substring(0,UpdationMessage.indexOf('.')+1));  
        component.set("v.UpdationMessage2",UpdationMessage.substring(UpdationMessage.indexOf('.')+1));  
        let params = new URLSearchParams(document.location.search);
		let salesLeadId = params.get("c__id"); 
        
        var action = component.get("c.AddDefaultTeam");        
        action.setParams({"salesLeadId":salesLeadId});
        action.setCallback(this, function (response) { 
            var state = response.getState();
            if (state === 'SUCCESS') {
                var res = response.getReturnValue(); 
                if(res=='SUCCESS'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success",
                        "message": $A.get("$Label.c.SalesLeadSuccess"),
                        "type":"success"
                    });
                    toastEvent.fire();
                }
                else if(res=='NORECORD'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Warning",
                        "message": $A.get("$Label.c.NoDefaultSalesLeadTeam"),
                        "type":"warning"
                    });
                    toastEvent.fire();
                }
                else if(res=='NOACCESS'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message":  $A.get("$Label.c.SalesLeadError"),
                        "type":"error"
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
            setTimeout(() => {window.location.replace('/lightning/r/Sales_Lead__c/'+salesLeadId+'/related/Sales_Lead_Team__r/view');
							}, "3000");
        });
        $A.enqueueAction(action); 
	},
	onCancel : function(component, event, helper) {
        let oppId = component.get("v.OpportunityId");
        window.location.replace('/lightning/r/Opportunity/'+ oppId+'/related/TXP_manpower_input_information__r/view');
		//window.history.back();
	}
})