/**
 * @description       : 
 * @author            : jiiiiii.park@partner.samsung.com.sds.dev
 * @group             : 
 * @last modified on  : 2020-12-21
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   2020-11-30   jiiiiii.park@partner.samsung.com.sds.dev   Initial Version
**/
({
    doInit : function(component, event, helper) {
        var device = $A.get( "$Browser.formFactor");
        if( device === "PHONE" || device === "IPHONE") component.set('v.isMobile', true);
        
        helper.helperInit(component, event);
    },

    cancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})