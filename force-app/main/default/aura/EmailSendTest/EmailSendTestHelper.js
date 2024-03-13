({

    SearchHelper : function(component, event, helper) {
        var action = component.get('c.fetchReport');
         action.setParams({ searchKey : component.get("v.searchKeyword"),
                          });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var allValues = response.getReturnValue();
                console.log("allValues--->>> " + JSON.stringify(allValues));
                //component.set('v.activeSections', allValues.Name);
                component.set('v.accList', allValues);
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Error Message: " + errors[0].message);
                    }
                }
                else{
                    console.log("Unknown Error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    fetchUserList : function(component, event, helper) {        
        var action = component.get("c.getUserList");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.userList", response.getReturnValue());
            } else {
                
                console.error("Error fetching user list: " + state);
            }
        });
        $A.enqueueAction(action);
    }
})