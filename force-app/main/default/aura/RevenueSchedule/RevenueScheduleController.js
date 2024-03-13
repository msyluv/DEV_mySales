/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 03-18-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   11-23-2020   woomg@dkbmc.com   Initial Version
 * 1.1   07-27-2023   aditya.r2@samsung.com		Rounded the Gap
**/
({
    doInit : function(component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        if(device != "DESKTOP"){
            component.set('v.isMobile', true);
        }

        helper.doInit(component, event);
    },
    clickCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    clickSave : function(component, event, helper) {
        helper.clickSave(component, event);
    },
    clickReset : function(component, event, helper) {
        helper.clickReset(component, event);
    },
    changeRevenue : function(component, event, helper) {
        //console.log(component.get("v.revenueSchedules"));
        helper.resetNull(event);

        helper.calcSummary(component);
    },
    completeChange : function(component, event, helper) {
        helper.resetNull(event);
        
        var amount = component.get("v.amount"),
            summary = component.get("v.summary"),
            gap = amount - summary;
        
        gap = (Number(Math.round(gap*100)/100));	// v1.1 MySales-262
        
        if(amount != summary){
            var msg = $A.get("$Label.c.REVENUE_SCHEDULE_COMP_ERROR_DIFFERENCE");
            helper.showMyToast("error", msg + " (" + helper.numberWithComma(gap) + ")");    
        }
    },
})