/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 01-18-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   01-04-2021   woomg@dkbmc.com   Initial Version
**/
({
    doInit : function(component, event) {
        var self = this,
            today = new Date();

        component.set("v.reportDate", today.toISOString().substring(0,10));
        self.doResize(component);
        window.addEventListener('resize', function(){
            self.doResize(component);
        });

        self.getContents(component);
        //console.log(window.innerHeight);
    },

    doResize : function(component){
        var headerHeight = 207,
            innerHeight = window.innerHeight,
            innerWidth = window.innerWidth;
        component.set("v.bodyHeight", innerHeight - headerHeight);
        component.set("v.gridHeight", innerHeight - (headerHeight + 20));
        component.set("v.contentsWidth", innerWidth - 400);
    },

    getContents : function(component){
        //console.log('Query Weekly Reports');
        var self = this,
            reportDate = component.get("v.reportDate");

        component.set("v.showSpinner", true);
        self.apex(component, 'getWeeklyReports', { reportDate : reportDate})
            .then(function(result){
                //console.log('getWeeklyReport -> ', result);
                if(result != null && result.length > 0) component.set("v.hasReports", true);
                component.set("v.weeklyReports", result);
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.set("v.showSpinner", false);
            });
    },

    callEditModal : function(component, recordId){
        var self = this,
            modalBody,
            modalFooter;
        $A.createComponents([
            ["c:weeklyIssueReportEditBody", { recordId : recordId }],
            ["c:weeklyIssueReportEditFooter", { onsubmit : component.getReference("c.saveFromChild") }]
        ],
        function(components, status){
            if(status === "SUCCESS"){
                modalBody = components[0];
                modalFooter = components[1];
                component.set("v.editBody", modalBody);
                component.find('overlayLib').showCustomModal({
                    header : $A.get('$Label.c.WEEKLY_ISSUE_REPORT_EDIT_ISSUE'), // 'Edit Issue',
                    body : modalBody,
                    footer : modalFooter,
                    showCloseButton : true,
                    cssClass : "edit-modal slds-modal_large",
                    closeCallback : function(){
                        self.getContents(component);
                    }
                })
            }
        });
    },

    callPreviewModal : function(component){
        var self = this,
            records = component.get("v.weeklyReports"),
            modalBody,
            modalFooter;

        $A.createComponents([
            ["c:weeklyIssueReportPreviewBody", { reports : records }],
            ["c:weeklyIssueReportPreviewFooter", { onsubmit : component.getReference("c.clickSendEmail") }]
        ],
        function(components, status){
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
                        //self.showMyToast("info", "Sent a Issue Report");
                    }
                })
            }
        });
    },

    /**
     * Common Functions
     */
    apex : function(component, apexAction, params){
        return new Promise( $A.getCallback( function( resolve, reject ) {
            var action = component.get("c."+apexAction+"");
            action.setParams( params );
            action.setCallback( this, function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));
    },

    errorHandler : function(errors){
        var self = this;
        if(Array.isArray(errors)){
            errors.forEach(function(err){
                self.showMyToast('error', err.exceptionType + " : " + err.message);
            });
        } else {
            console.log(errors);
            var msg = $A.get("$Label.c.COMM_MSG_0020");
            self.showMyToast('error', msg);
        }
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
	},
})