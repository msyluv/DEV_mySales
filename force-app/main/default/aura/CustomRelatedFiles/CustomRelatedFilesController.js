/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 12-02-2020
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   09-22-2020   woomg@dkbmc.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        if(device != "DESKTOP"){
            component.set('v.isMobile', true);
        }
        helper.doInit(component);
        
    },

    clickAdd : function(component, event, helper){
        var fileInput = window.document.getElementById("file-upload");
        fileInput.click();
    },

    handle4LightningFiles : function(component, event, helper){
        var self = this;
        //helper.showMyToast("warning", "Under development, will added at Sprint 2!!");
        helper.handle4LightningFiles(component, event);
    },

    handle4PlainFiles:function(component, event, helper) {
        var self = this;
        //helper.showMyToast("warning", "Under development, will added at Sprint 2!!");
        helper.handle4PlainFiles(component, event);
    },

    resetInput:function(component, event, helper) {
        event.target.value = null;
    },
    
    childDeleted : function(component, event, helper){
        var self = this;
        helper.doInit(component);
    },

})