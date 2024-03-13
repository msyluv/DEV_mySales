/**
 * @author            : akash.g@samsung.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2022-06-16
 * @last modified by  : divyam.gupta@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2022-06-13   akash.g@samsung.com   Initial Version
 * 1.1   2022-06-16   akash.g@samsung.com   Add new functionality of validating project code exist or not.
 * 1.2   2022-09-14   divyam.gupta@samsung.com   Add new functionality to check whether profile is servide desk angency or not.

**/
({
    doInit : function(component, event, helper){
        /**START-> V1.1 : Add new functionality of validating project code exist or not**/
        var oppId = component.get('v.recordId');
        var action = component.get("c.representativePMCheckProjectCode");
        close =  $A.get("e.force:closeQuickAction");
        action.setParams({ opptyId : oppId});
        action.setCallback(this, function(response) {
            console.log(response.getReturnValue());
            var result = response.getReturnValue();
            /**START-> V1.2 : Add new functionality to check whether profile is servide desk angency or not**/
            
            if(result == 'Service_desk'){
                close.fire();
                helper.showMyToast('error',$A.get("$Label.c.OpportunityRegisError"));   
            }
            /**END--> V1.2 **/
            else if(result == 'true'){
                helper.helperInit(component, event);
            }else{
                close.fire();
                helper.showMyToast('error',$A.get("$Label.c.RPM_MSG_0004"));
            }
        });
        $A.enqueueAction(action);
        /**END-> V1.1 **/
    },
    cancel : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    save : function(component, event, helper){
        var opptyId = component.get('v.recordId'),
            pmCheck = component.get('v.pmCheck');
        
        var selectedEmp = component.get('v.selectedEmp');
        if(selectedEmp.Id == undefined){
            helper.showMyToast('Error', $A.get("$Label.c.RPM_MSG_0001")); // Please select Representative PM.
        }else{
            if(pmCheck){
                if(confirm($A.get("$Label.c.RPM_MSG_0002"))) helper.pmSave(component, event); // There is a Representative PM already registered. Would you like to change it?
                else $A.get("e.force:closeQuickAction").fire();
            }else{
                helper.pmSave(component, event);
            }
        }
    },
    handleOpenLink : function(component, event, helper) {
        helper.handleOpenLink(component, event);
    },
    
})