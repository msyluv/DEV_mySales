/**
 * @description       : 
 * @author            : gitesh.s@samsung.com
 * @group             : 
 * @last modified on  : 15-03-2023
 * @last modified by  : gitesh.s@samsung.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   15-03-2023   gitesh.s@samsung.com   Initial Version
**/
({
    getRelatedWeeklyReports : function(component) {
        var recordId = component.get("v.id"),
            action = component.get("c.getRelatedWeeklyReports");
        action.setParams({ recordId : recordId });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                result.forEach(function(result){
                    result.linkName = '/'+result.Id;
                });
                component.set("v.weeklyReports", result);
                component.set("v.count", result.length);
            }
        });
        $A.enqueueAction(action);
    },

    getAccountName : function(component) {
        var recordId = component.get("v.id"),
            action = component.get("c.getAccountName");
        action.setParams({ recordId : recordId });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.accountName", result[0].Name);
            }
        });
        $A.enqueueAction(action);
    },

    onPageRefChange : function(component, event) {
        var self = this,
            weeklyReportPageRef = component.get("v.pageReference"),
            weeklyReportIds = weeklyReportPageRef.state.c__listofWeeklyReports,
            recordId = weeklyReportPageRef.state.c__id;
            
        component.set("v.id", recordId);
        if(weeklyReportIds != '' && weeklyReportIds != undefined) {
            component.set("v.hasRecordIds", true);
            var action = component.get("c.getWeeklyIssueReports");
            action.setParams({            
                weeklyReportIds : weeklyReportIds
            });
            action.setCallback(this,function(e) {
                if(e.getState()=='SUCCESS'){
                    var result=e.getReturnValue();
                    if(result!=null && result.length>0){
                        component.set("v.weeklyReportList", result);
                    }
                }
            });
            $A.enqueueAction(action);
        }
        else if(weeklyReportIds == '') {
            component.set("v.hasRecordIds", false);
            var msg = $A.get("$Label.c.WEEKLYREPORT_MSG_0004");
            self.showMyToast('warning', msg);
            setTimeout(() => {
                //window.history.back();
                var relatedListEvent = $A.get("e.force:navigateToRelatedList");
                relatedListEvent.setParams({
                    "relatedListId": "AccountWeeklyReports__r",
                    "parentRecordId": component.get("v.id")
                });
                relatedListEvent.fire();
            }, 5000);
        }
    },

    loadPreview : function(component, event) {
        var self = this,
            radioValue = component.get("v.selectedValue");

        if(radioValue == "weekly-report-content") {
            self.callPreviewModal(component, event, "weeklyReportPreviewBody", "weeklyReportPreviewFooter");
        }
        else if(radioValue == "issue-description") {
            self.callPreviewModal(component, event, "weeklyIssueReportPreviewBody", "weeklyIssueReportPreviewFooter");
        }
    },

    callPreviewModal : function(component, event, previewBody, previewFooter, helper){
        var self = this,
            records = component.get("v.weeklyReportList"),
            modalBody,
            modalFooter;

        $A.createComponents([
            ["c:"+previewBody+"", { reports : records }],
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
                        // window.history.back();
                        self.handleCancel(component, event);
                    }
                })
            }
        });
    },

    handleCancel : function(component, event) {
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
            relatedListEvent.setParams({
                "relatedListId": "AccountWeeklyReports__r",
                "parentRecordId": component.get("v.id")
            });
        relatedListEvent.fire();
    },

    showMyToast : function(type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 3000,
            mode: 'dismissible',
            message: msg
        });
        toastEvent.fire();
	}
 })