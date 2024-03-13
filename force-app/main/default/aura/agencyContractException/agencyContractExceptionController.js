/**
 * @description       : 
 * @author            : wonjune.oh@partner.samsung.com
 * @group             : 
 * @last modified on  : 2020-12-22
 * @last modified by  : hj.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-30   wonjune.oh@partner.samsung.com   Initial Version
**/
({

    handleSubmit: function(component, event, helper) {
        event.preventDefault();       // stop the form from submitting
        helper.submit(component,event);
    },

    handleSuccess : function(component, event, helper) {
        component.set('v.showSpinner', false);
        
        var record = event.getParam("response");
        helper.log('[#] SUCCESS record', record);

        component.set('v.recordId', record.id);

         // Update OpportunityActivity Event
         var opportunityActivityUpdateEvent = component.getEvent("opportunityActivityUpdateEvent");
         opportunityActivityUpdateEvent.setParams({});
         opportunityActivityUpdateEvent.fire();
         
        helper.showToast(component, 'success', 'dismissible', 'SUCCESS', '성공적으로 저장되었습니다.'); 
        // helper.close(component, event);
    },

    handleError : function(component, event, helper) {
        component.set('v.showSpinner', false);
        
        var evtParams = event.getParams();
        helper.log('[#] ERROR evtParams', evtParams);

        var error = event.getParam('error');
        helper.log('[#] ERROR error', error);

        var errorMessage = event.getParam("message");
        helper.showToast(component, 'error', 'dismissible', 'ERROR', errorMessage); 
    },

    cancel : function(component, event, helper) {
        helper.close(component, event);
    }
})