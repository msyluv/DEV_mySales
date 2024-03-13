({
	helperInit : function(component, event, helper) {
		console.log('KnoxApprovalHTML controller helperInit start');
        console.log('record : ', component.get('v.recordId'));
		
		var action = component.get("c.getKnoxAppInfo");
			
		action.setParams({
			recordId : component.get('v.recordId')
		})
	
		action.setCallback(this,function(response){
			var state = response.getState();
			
			if(state === "SUCCESS"){
				var data = response.getReturnValue();	
				console.log(data);
				component.set("v.data", data[0].HTML__c);
			}  	
			else if (state === "INCOMPLETE") {

			}
			else if (state === "ERROR") {
                var errors = response.getError();
                console.log(errors);
			}			 
		});

		$A.enqueueAction(action);

    }
})