/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 01-15-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   01-05-2021   woomg@dkbmc.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        helper.doInit(component, event);
    },

    clickSend : function(component, event, helper) {
        console.log('send from child in preview');
        var reports = component.get("v.reports"),
            ids = new Array();
        console.log(reports);
        reports.forEach((rpt) => {
            ids.push(rpt.Id);
        });
        console.log(ids);
        helper.callEmailModal(component, ids);
    },

    clickSendEmail : function(component, event, helper) {
        console.log('send from child in sendmailbody');
        var mailBody = component.get("v.emailBody");
        mailBody.clickSend();
    },
            
    handleEvent : function(component, event, helper) {
    	var data = event.getParam("passData");
        console.log("Record Id from Preview Body : ", data);
        component.set("v.recordId", data); 
        var ab = component.get("v.recordId");
        console.log("Record Id from Preview Body1 : ", ab);
    }

})