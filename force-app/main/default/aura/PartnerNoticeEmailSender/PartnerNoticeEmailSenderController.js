/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 08-02-2022
 * @last modified by  : ukhyeon.lee@samsung.com
**/
({
	init : function(component, event, helper) {
        helper.helperinit(component, event);
	},
  
	cancel : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    
    onRefresh: function(Component, event, helper){
        helper.helperinit(Component, event);
    },
    
    onChange: function(component, event, helper) {
        var emailSendSubject= component.get("v.Email_Send_Subject__c");
        if(!$A.util.isUndefinedOrNull(emailSendSubject) && emailSendSubject.length>0){
            component.set('v.isSendDisabled', false);
        } else{
            component.set('v.isSendDisabled', true);
        }
    },

    emailSend : function(component, event, helper) {
        helper.emailSend(component, event);
    },
})