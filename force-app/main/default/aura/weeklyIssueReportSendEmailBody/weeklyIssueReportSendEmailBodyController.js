/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 01-14-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   01-05-2021   woomg@dkbmc.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        helper.doInit(component);
    },
    
    clickSend : function(component, event, helper) {
        console.log('send from child in sendmailbody');
        helper.callKnoxSendEmail(component);
    },
})