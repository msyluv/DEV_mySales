/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2020-08-24
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-08-24   younghoon.kim@dkbmc.com   Initial Version
**/
({
	init : function(component, event, helper) {
        component.set('v.loading', true);
    },

    send : function(component, event, helper) {
        var action = component.get("c.sendToSap");
        action.setParams({
            prodCode : component.get('v.productCode')
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result != 'ERROR'){
                    component.set('v.response', result);
                    component.set('v.loading', true);
                }
            }
        });
        $A.enqueueAction(action);
        component.set('v.loading', false);
    },
})