({
	doInit : function(component, event, helper) {
		var action = component.get('c.ReportController');
        action.setParams({});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS' || state ==='DRAFT'){
                document.getElementById('report').innerHTML = response.getReturnValue();
                                
            }else{
                console.log("Failed to fetch data from Apex.")
            }
        });
    	$A.enqueueAction(action);
	}
    
})