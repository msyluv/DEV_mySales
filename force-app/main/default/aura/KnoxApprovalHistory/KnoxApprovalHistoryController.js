/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2020-12-10
 * @last modified by  : dongyoung.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-11-24   younghoon.kim@dkbmc.com   Initial Version
**/
({
	doInit : function(component, event, helper) {
        window.console.log('KnoxApprovalHistory controller doInit start');
        var device = $A.get("$Browser.formFactor");
        var div = 'W';
        if(device == "PHONE" || device == "IPHONE"){ 
        	div = 'M';    
        }
        component.set('v.isMobile', div);
		
        helper.helperInit(component, event, helper);
        window.console.log('KnoxApprovalHistory controller doInit start2');
    },
    
    clickCancel: function(component, event, helper) {
        component.find("overlayLib").notifyClose();
    }
    
    /*clickApprove: function(component, event, helper) {
        component.find("KnoxApprovalBody").Save();
        var action = component.get('c.doInit');
        $A.enqueueAction(action);
    },
    
    tempSave: function(component, event, helper) {
        component.find("KnoxApprovalBody").tempSave();  
    }

    /*getTeamMember: function(component, event, helper) {
        component.find("KnoxApprovalBody").getTeamMember();  
    }*/
})