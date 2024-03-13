/**
 * @description       : 
 * @author            : gitesh.s@samsung.com
 * @group             : 
 * @last modified on  : 10-03-2023
 * @last modified by  : gitesh.s@samsung.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   10-03-2023   gitesh.s@samsung.com   Initial Version
**/
({
    init: function (component, event, helper) {
        var weeklyReportContent = $A.get("$Label.c.WEEKLY_ISSUE_REPORT_CONTENT");
        var issueDescription = $A.get("$Label.c.WEEKLY_REPORT_ISSUE_DESCRIPTION");
        component.set("v.options", [
            {'label': weeklyReportContent, 'value': 'weekly-report-content'},
            {'label': issueDescription, 'value': 'issue-description'}
            ]);
    },

    loadPreview : function (component, event, helper) {
        helper.loadPreview(component, event, helper);
    },

    getSelectedValue : function (component, event) {
        var selectedValue = event.getParam("value");
        component.set("v.selectedValue", selectedValue);
    },

    handleCancel : function(component, event, helper) {
        //closes the modal or popover from the component
        component.find("overlayLib").notifyClose();
    },

    clickSendEmail : function(component, event, helper) {
        console.log('### send from footer');
        var previewBody = component.get("v.previewBody");
        previewBody.clickSend();
    }
})