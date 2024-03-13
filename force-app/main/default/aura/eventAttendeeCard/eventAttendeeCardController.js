/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 01-18-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   01-18-2021   woomg@dkbmc.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        if(device != "DESKTOP"){
            component.set('v.isMobile',true);
        }
        //helper.doInit(component, event);
    },

    selectMenu: function (component, event, helper) {
        // This will contain the string of the "value" attribute of the selected
        // lightning:menuItem
        var selectedMenuItemValue = event.getParam("value");
        switch (selectedMenuItemValue){
            case 'Delete':
                helper.deleteEvent(component);
                break;
            default:
                helper.showMyToast('error', 'Unknown submenu item!!!');
        }
    },
})