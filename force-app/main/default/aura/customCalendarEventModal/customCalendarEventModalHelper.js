/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 11-03-2020
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   11-03-2020   woomg@dkbmc.com   Initial Version
**/
({
    gotoEvent: function(component, event) {
        var evid = component.get("v.event.id");
		var navEvt = $A.get("e.force:navigateToSObject");
		navEvt.setParams({
			"recordId": evid,
		});
		navEvt.fire();
    }
})