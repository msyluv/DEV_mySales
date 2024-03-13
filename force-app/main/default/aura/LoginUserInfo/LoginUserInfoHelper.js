/**
 * @description       : 
 * @author            : jiiiiii.park@partner.samsung.com.sds.dev
 * @group             : 
 * @last modified on  : 2021-04-02
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   2020-11-05   jiiiiii.park@partner.samsung.com.sds.dev   Initial Version
**/

({
	helperInit : function(component, event) {
        var action = component.get("c.getLoginUserInfo");
        action.setCallback(this,function(response) { 
            var state = response.getState();            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                window.console.log('result : ', result);
                component.set('v.userInfo', result);
                component.set('v.lastLogin', result.lastLoginDate);
            }
        });
        $A.enqueueAction(action);
    }
})