/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 11-20-2020
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   11-20-2020   woomg@dkbmc.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        if(device != "DESKTOP"){
            component.set('v.isMobile',true);
        }

        var recordId = component.get('v.recordId');
        console.log('recordId', recordId);
        
        helper.doInit(component, event);
    },

    clickMaximize : function(component, event, helper){
        var maximize = component.get("v.maximize");
        component.set("v.maximize", maximize ? false : true);
    },

    

})