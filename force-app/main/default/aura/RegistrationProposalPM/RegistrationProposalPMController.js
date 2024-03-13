/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2022-01-04
 * @last modified by  : divyam.gupta@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-05-13   younghoon.kim@dkbmc.com   Initial Versio
 * 1.1   2022-09-14   divyam.gupta@samsung.com   Add new functionality to check whether profile is servide desk angency or not.
**/
({
    doInit : function(component, event, helper){
        close =  $A.get("e.force:closeQuickAction");
        helper.apex(component, 'profilecheck',{})
        .then(function(result){
            window.console.log('result : ',result );
            /**START-> V1.1 : Add new functionality to check whether profile is servide desk angency or not**/
            
            if(result == 'service_desk'){
                close.fire();
                helper.showMyToast('Error', $A.get("$Label.c.OpportunityRegisError"));         
            }
            /**END --> V1.1 **/
            else{
                helper.helperInit(component, event);
            }
        })
        .catch(function(errors){
            helper.errorHandler(errors);
        }).finally(function(){
            component.set('v.showSpinner', false);
        });
    },
    cancel : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    save : function(component, event, helper){
        var opptyId = component.get('v.recordId'),
            pmCheck = component.get('v.pmCheck');
        
        var selectedEmp = component.get('v.selectedEmp');
        if(selectedEmp.Id == undefined){
            helper.showMyToast('Error', $A.get("$Label.c.PPM_MSG_0001")); // Please select Proposal PM.
        }else{
            if(pmCheck){
                if(confirm($A.get("$Label.c.PPM_MSG_0002"))) helper.pmSave(component, event); // There is a Proposal PM already registered. Would you like to change it?
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