({
    send : function(component, event, helper){
        var selectedContacts = [];
        var checkvalue = component.find("checkContact");
        
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                selectedContacts.push(checkvalue.get("v.text"));
            }
        }else{
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    selectedContacts.push(checkvalue[i].get("v.text"));
                }
            }
        }
        component.set("v.selectedUsersList",selectedContacts);
        console.log('selectedContacts____________' + selectedContacts);
        console.log('selectedUsersList___________ '+ component.get("v.selectedUsersList"));
        var action = component.get("c.ReportData");
        console.log('Clicked');
        //console.log('distance ' + component.find("distance").get("v.value"));
        var selectedReport = component.get("v.selectedReport");
        action.setParams({ 
            "repId" : component.get("v.selectedReport"),
            "usersEmail" : component.get("v.selectedUsersList")
        });
        console.log('Selected report : '+ component.get("v.selectedReport") );
        console.log('selectedUsersList___________ '+ component.get("v.selectedUsersList"));
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('SUCCESS');
                
                //alert("From server: " + response.getReturnValue());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The mail has been sent successfully."
                });
                toastEvent.fire();
                
            }
            else if (state === "INCOMPLETE") {
                console.log('INCOMPLETE');
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        
        $A.enqueueAction(action);
    },
    onChange1: function (component, evt, helper) {
        var selectedLimit = component.find('searchField').get('v.value');
        
        component.set('v.searchKeyword', selectedLimit);
        helper.SearchHelper(component, event);
    },
    onSelect: function (component, event, helper) {
        var selectedReport = event.currentTarget.dataset.value;
        component.set("v.selectedReport",selectedReport);
        console.log('selected Report : '+ selectedReport);
        console.log('1' + event.getSource().get('v.title'));
        console.log('2'+ event.target.getAttribute("title"));
        console.log('3'+ event.getSource().getLocalId());
    },
    //get Contact List from apex controller
    doInit : function(component, event, helper) {
        var action = component.get("c.getuserList");
        action.setParams({
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                component.set("v.contactList",result.getReturnValue());   
            }
        });
        $A.enqueueAction(action);
    },
    
    //Select all contacts
    handleSelectAllContact: function(component, event, helper) {
        var getID = component.get("v.contactList");
        var checkvalue = component.find("selectAll").get("v.value");        
        var checkContact = component.find("checkContact"); 
        if(checkvalue == true){
            for(var i=0; i<checkContact.length; i++){
                checkContact[i].set("v.value",true);
            }
        }
        else{ 
            for(var i=0; i<checkContact.length; i++){
                checkContact[i].set("v.value",false);
            }
        }
    },
    
    //Process the selected contacts
    handleSelectedContacts: function(component, event, helper) {
        var selectedContacts = [];
        var checkvalue = component.find("checkContact");
        
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                selectedContacts.push(checkvalue.get("v.text"));
            }
        }else{
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    selectedContacts.push(checkvalue[i].get("v.text"));
                }
            }
        }
        console.log('selectedContacts-' + selectedContacts);
    }
})