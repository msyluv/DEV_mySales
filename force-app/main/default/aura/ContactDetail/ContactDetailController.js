/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 05-03-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   02-16-2021   woomg@dkbmc.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");

        console.log('call contact');
        component.set("v.showSpinner", true);
		helper.apex(component, 'checkContactOwner', { recordId : recordId })
            .then(function(result){
                console.log('checkContactOwner');
                if(result == false){
                    console.log('checkContactOwner');
                    var msg = $A.get("$Label.c.CONTACT_OWNER_ONLY");
                    helper.showMyToast("error", msg);
                    window.history.back();
                }
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                helper.errorHander(errors);
                component.set("v.showSpinner", false);
            });
    }
})