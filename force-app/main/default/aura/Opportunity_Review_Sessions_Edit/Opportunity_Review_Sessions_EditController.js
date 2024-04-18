({
    doInit: function(component, event, helper) {
       helper.init(component, event);
    },
    clickSave : function(component, event, helper) {
        helper.onSave(component, event);
    },
    clickTargetBOPopUp: function(component, attributeParams) {  
        var attributeParams = {'SelectedOpportunityMap' : component.getReference('v.SelectedOpportunityMap')};
        var cssClass = 'slds-modal_large';
        console.log('SelectedOpportunityMap1: '+component.get('v.SelectedOpportunityMap'));
        $A.createComponent('c:TargetOpportunitySearch'
                           , attributeParams
                           , function(content, status, errorMessage) {
                               if (status === "SUCCESS") {
                                   component.find('overlayLib').showCustomModal({
                                       body: content,
                                       showCloseButton: false,
                                       cssClass: cssClass,
                                       closeCallback: function(){
                                           var valueFromChild = component.get('v.SelectedOpportunityMap');
                                           console.log('Map: '+valueFromChild.size); 
                                           var selectedopp = component.get("v.targetOpportunity");
                                           console.log(typeof selectedopp);
                                           selectedopp = [...valueFromChild.values()];
                                           component.set("v.targetOpportunity", selectedopp);
                                           console.log('targetOpportunity: '+component.get('v.targetOpportunity'));
                                           
                                       }
                                   })
                               } else if (status === "ERROR") {
                                   console.log("Error: " + errorMessage);
                               }
                           });
        //component.set('v.showSpinner',false);
    },
    handleComponentEvent: function(component, event, helper) {
        console.log('Inside handleComponentEvent');
        
    },
    clickCancel:  function(component, event, helper) {
        helper.redirectToList(component, event);
    },
    setBoxes: function(component,event){
        console.log(event.target.name);
        var selectedopp = component.get("v.targetOpportunity");
        for(var i=0 ; i <selectedopp.length; i++){
            if(selectedopp[i].Id == event.target.name){
                selectedopp[i].Checked = !selectedopp[i].Checked;
                console.log('selectedopp: '+JSON.stringify(selectedopp[i]));
            }
        }
        component.set("v.targetOpportunity", selectedopp);
        console.log('targetOpportunity: '+JSON.stringify(component.get('v.targetOpportunity')));
    } 
})