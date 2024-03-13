/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 12-09-2020
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   11-09-2020   woomg@dkbmc.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        console.log('dummy ABC');
        var device = $A.get("$Browser.formFactor");
        if(device != "DESKTOP"){
            component.set('v.isMobile',true);
        }
        helper.doInit(component, event);
    },

    clickFile : function(component, event, helper) {
        console.log('dummy ABC');
        var name = event.currentTarget.dataset.name,
            id = event.currentTarget.dataset.id,
            isMobile = component.get("v.isMobile");

        if(isMobile){
            var device = $A.get("$Browser");
            helper.queryFile(component, id, device);    
        }
    },

    clickTemp : function(component, event, helper) {
        var url = component.get("v.mobileUrl");
        window.open(url, "_blank");
    },

    handleSelect: function (component, event, helper) {
        // This will contain the string of the "value" attribute of the selected
        // lightning:menuItem
        var selectedMenuItemValue = event.getParam("value");
        switch (selectedMenuItemValue){
            case 'Download':
                helper.downloadFile(component);
                break;
            case 'Delete':
                helper.deleteFile(component);
                break;
            default:
                helper.showMyToast('error', 'Unknown submenu item!!!');
        }
        //helper.showMyToast('warning', "Menu item selected with value: " + selectedMenuItemValue);
        //helper.downloadFile(component);
    }
})