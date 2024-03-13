/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 12-18-2020
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   11-13-2020   woomg@dkbmc.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        if(device != "DESKTOP"){
            component.set('v.isMobile',true);
        }

        helper.doInit(component, event);
    },

    callSetup : function(component, event, helper) {
        helper.callSetup(component, event);
    },

    submitFromChild : function(component, event){
        console.log('submit from footer');
        var childBody = component.get("v.modalbody");
        childBody.clickSave();
    }
})