/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 01-05-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   01-04-2021   woomg@dkbmc.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        if(device != "DESKTOP"){
            component.set('v.isMobile',true);
        }

        helper.doInit(component, event);
    },

    selectDate : function(component, event, helper){
        var reportDate = event.getSource().get("v.value");
        component.set("v.reportDate", reportDate);
        helper.getContents(component);
    },

    clickReport : function(component, event, helper) {
        var recordId = event.currentTarget.id;
        console.log('click!', recordId);
        helper.callEditModal(component, recordId);
    },

    clickPreview : function(component, event, helper) {
        helper.callPreviewModal(component);
    },

    clickSendEmail : function(component, event, helper) {
        console.log('send from footer');
        var previewBody = component.get("v.previewBody");
        previewBody.clickSend();
    },

    saveFromChild : function(component, event){
        console.log('save from footer');
        var editBody = component.get("v.editBody");
        editBody.clickSave();
    }

})