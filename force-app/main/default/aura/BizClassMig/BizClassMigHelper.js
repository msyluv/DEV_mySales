({
	export : function(component, event) {
		var that = this; 
        var action = component.get("c.executeBatch");
        
        //console.log('startDate = ' + component.get('v.startDate'));
        console.log('isModified = ' + component.get('v.isModified'));
                
        action.setParams({
            strOppIdSet : component.get('v.setOppId'),            
            strStartDate : component.get('v.startDate'),
            strEndDate : component.get('v.endDate'),
            isModified : component.get('v.isModified')
        })
        
        action.setCallback(that, function(result) { 
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "###",
                "message": "Please check the export file."
            });
            toastEvent.fire();
        }); 
        $A.enqueueAction(action);
		
	}
})