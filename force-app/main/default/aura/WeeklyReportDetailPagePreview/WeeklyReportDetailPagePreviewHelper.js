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
    loadPreview : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        console.log(recordId);
        var radioValue = component.get("v.selectedValue");

        if(radioValue == "weekly-report-content") {
            var action = component.get("c.getWeeklyReport");
            action.setParams({ recordId : recordId });
            action.setCallback(this, function(e) {
                if(e.getState() == 'SUCCESS'){
                    var result = e.getReturnValue();
                    console.log(result);
                    if(result!=null){
                        component.set("v.reports", result);
                        setTimeout($A.getCallback(helper.callPreviewModal.bind(this, component, "weeklyReportPreviewBody", "weeklyReportPreviewFooter")),0);
                    }
                }
            });
            $A.enqueueAction(action);
        }
        else if(radioValue == "issue-description") {
            var action = component.get("c.getIssueReport");
            action.setParams({ recordId : recordId });
            action.setCallback(this, function(e) {
                if(e.getState() == 'SUCCESS'){
                    var result = e.getReturnValue();
                    console.log(result);
                    if(result!=null){
                        component.set("v.reports", result);
                        setTimeout($A.getCallback(helper.callPreviewModal.bind(this, component, "weeklyIssueReportPreviewBody", "weeklyIssueReportPreviewFooter")),0);
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },

    callPreviewModal : function(component, previewBody, previewFooter){
        var self = this,
            records = component.get("v.reports"),
            modalBody,
            modalFooter;
        var recordId = component.get("v.recordId");
		console.log('before callPreviewModal');
        $A.createComponents([
            ["c:"+previewBody+"", { reports : records, recordId: recordId }],
            ["c:"+previewFooter+"", { onsubmit : component.getReference("c.clickSendEmail") }]
        ],
        function(components, status){
            console.log("### callPreviewModal, status : ", status);
            console.log("### callPreviewModal, components 0 : ", components[0]);
            console.log("### callPreviewModal, components 1 : ", components[1]);
            if(status === "SUCCESS"){
                modalBody = components[0];
                modalFooter = components[1];
                component.set("v.previewBody", modalBody);
                component.find('overlayLib').showCustomModal({
                    header : $A.get('$Label.c.WEEKLY_ISSUE_REPORT_PREVIEW'), // 'Preview',
                    body : modalBody,
                    footer : modalFooter,
                    showCloseButton : true,
                    cssClass : "preview-modal slds-modal_large",
                    closeCallback : function(){
                        component.find("overlayLib").notifyClose();
                    }
                })
            }
        });
    },
})