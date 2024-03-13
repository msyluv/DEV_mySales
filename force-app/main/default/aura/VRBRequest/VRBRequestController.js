/**
 * @description       : 
 * @author            : wonjune.oh@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-03-05
 * @last modified by  : Junghwa.Kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-24   wonjune.oh@partner.samsung.com   Initial Version
 * 1.1   2021-01-28   Junghwa.Kim@dkbmc.com            helper.sendEmail 추가
 * 1.2   2021-02-22   Junghwa.Kim@dkbmc.com            handleCostplanningreadinessChange 추가
**/
({
    doInit : function(component, event, helper) {
        helper.doInit(component, event);
        helper.getLabel(component, event);
        helper.getTeamMember(component, event);
        var aa= component.get('v.opportunityBizLevel');
        console.log('asdasfsafa s: ' + aa);
    },

    handleSubmit: function(component, event, helper) {
        event.preventDefault();       // stop the form from submitting
        helper.submit(component,event);
    },

    handleSuccess : function(component, event, helper) {
        component.set('v.showSpinner', false);
        
        var record = event.getParam("response");
        helper.log('[#] SUCCESS record', record);

        component.set('v.recordId', record.id);
        
        // update change VRB Owner
        helper.changeOwner(component, event, record.id);

        // Update OpportunityActivity Event
        var opportunityActivityUpdateEvent = component.getEvent("opportunityActivityUpdateEvent");
        opportunityActivityUpdateEvent.setParams({status: 'Completed'});
        opportunityActivityUpdateEvent.fire();

        // 2021-01-28 helper.sendEmail 추가
        helper.sendEmail(component, event, helper);
        helper.showToast(component, 'success', 'dismissible', $A.get('$Label.c.COMM_LAB_SUCCESS') , $A.get('$Label.c.COMM_MSG_0002') ); // 성공적으로 저장되었습니다.
        helper.close(component, event);
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
    // 2021-02-22 추가
    handleCostplanningreadinessChange : function(component, event, helper){
        console.log('handleCostplanningreadinessChange');
        var value = event.getSource().get('v.value');
        if(value == 'Yes') component.set('v.OPVflag', true);
        else component.set('v.OPVflag', false);
    },

    nextStep : function(component, event, helper) {
        var activeStep = component.get('v.activeStep');
        component.set('v.activeStep', (Number(activeStep)+1).toString());
    },

    prevStep : function(component, event, helper) {
        var activeStep = component.get('v.activeStep');
        component.set('v.activeStep', (Number(activeStep)-1).toString());
    },

    cancel : function(component, event, helper) {
        helper.close(component, event);
    }
})