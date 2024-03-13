({
    init : function(component, event, helper) {
        var action = component.get("c.initFunction");
        var recordId = component.get('v.recordId');
        console.log('Akash1' + recordId);
        action.setParams({ theId : recordId });
        action.setCallback(this, function(response){
            var state = response.getState();
            var isAccountChange = response.getReturnValue();
            console.log('Akash2' + isAccountChange);
            if(state == 'SUCCESS' && isAccountChange == true) {
                console.log('Akash3');
                alert('Akash3');
                
            }
        });
        $A.enqueueAction(action);
    },
    
})