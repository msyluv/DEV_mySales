/**
 * @description       : 
 * @author            : wonjune.oh@partner.samsung.com
 * @group             : 
 * @last modified on  : 2020-12-18
 * @last modified by  : hj.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-26   wonjune.oh@partner.samsung.com   Initial Version
**/
({
    cancel : function(component, event, helper) {
        helper.close(component, event);
    },

    closeModal : function(component, event, helper) {
        component.set("v.isShowMobileDetail", false);
    },
    
})