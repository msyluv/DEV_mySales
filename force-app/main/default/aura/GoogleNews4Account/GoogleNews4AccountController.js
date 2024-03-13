/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 11-13-2020
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

    scrollLeft : function(component, event, helper) {
        var contentBox = component.find("scroller-content");
        console.log('scrollBox', contentBox);
    },

    scrollLeft : function(component, event, helper) {
        var contentBox = component.find("scroller-wrapper");
        contentBox.set("v.scrollLeft", 0);
        console.log('scrollBox', contentBox.getElement());
    },

    scrollRight : function(component, event, helper) {
        var contentBox = component.find("scroller-wrapper");
        contentBox.set("v.scrollLeft", 100);
        console.log('scrollBox', contentBox.getElement());
    },

})