/**
 * @description       : 
 * @author            : akash.g@samsung.com
 * @group             : 
 * @last modified on  : 2024-05-09
 * @last modified by  : akash.g@samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2024-05-09   akash.g@samsung.com              Initial Version(MYSALES -499)
**/
({
    doInit: function(component, event, helper) {
        var opMap = new Map();
        var opList = [];
        component.set('v.SelectedOpportunityMap', opMap);
        component.set("v.targetOpportunity", opList);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set("v.todayDate", today);
    },
    clickSave : function(component, event, helper) {
        helper.onSave(component, event);
    },
    clickTargetBOPopUp: function(component, attributeParams) {  
        var attributeParams = {'SelectedOpportunityMap' : component.getReference('v.SelectedOpportunityMap')};
        var cssClass = 'slds-modal_large';
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
                                           var selectedopp = component.get("v.targetOpportunity");
                                           selectedopp = [...valueFromChild.values()];
                                           for(var i=0 ; i <selectedopp.length; i++){
                                               selectedopp[i].Amount = selectedopp[i].Amount.toLocaleString(undefined, {minimumFractionDigits: 2});
                                           }
                                           component.set("v.targetOpportunity", selectedopp);
                                       }
                                   })
                               } else if (status === "ERROR") {
                                   console.log("Error: " + errorMessage);
                               }
                           });
    },
    clickCancel:  function(component, event, helper) {
        helper.redirectToList(component, event);
    },
    setBoxes: function(component,event){
        var selectedopp = component.get("v.targetOpportunity");
        for(var i=0 ; i <selectedopp.length; i++){
            if(selectedopp[i].Id == event.target.name){
                selectedopp[i].Checked = !selectedopp[i].Checked;
            }
        }
        component.set("v.targetOpportunity", selectedopp);
    },
    clickRemove : function(component, event, helper) {
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