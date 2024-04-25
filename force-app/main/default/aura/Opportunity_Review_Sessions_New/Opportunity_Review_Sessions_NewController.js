({
    doInit: function(component, event, helper) {
        var opMap = new Map();
        var opList = [];
        component.set('v.SelectedOpportunityMap', opMap);
        component.set("v.targetOpportunity", opList);
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
                                           for(var i=0 ; i <selectedopp.length; i++){
                                               selectedopp[i].Amount = selectedopp[i].Amount.toLocaleString(undefined, {minimumFractionDigits: 2});
                                           }
                                           
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
    },
    clickRemove : function(component, event, helper) {
        console.log((123456789.54321).toLocaleString());
        var BOID = event.getSource().get("v.name");
        var selectedopp = component.get("v.targetOpportunity");
        for(var i=0 ; i <selectedopp.length; i++){
            if(selectedopp[i].Id == BOID){
                selectedopp.splice(i,1);
            }
        }
        component.set("v.targetOpportunity", selectedopp);
        var valueFromChild = component.get('v.SelectedOpportunityMap');
        valueFromChild.delete(BOID);
        component.set('v.SelectedOpportunityMap',valueFromChild);
    }
})