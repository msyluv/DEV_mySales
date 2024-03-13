/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 2022-04-28
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   02-04-2021   woomg@dkbmc.com   Initial Version
**/
({
    doInit : function(component, event) {
        var self = this,
            today = new Date();

        component.set("v.reportDate", today.toISOString().substring(0,10));
        window.addEventListener('resize', function(){
            self.setWindowSize(component);
        });
        self.getContents(component);
        //console.log(window.innerHeight);
    },

    setWindowSize : function(component){
        var bodyHeight = component.get("v.bodyHeight"),
            gridHeight = component.get("v.gridHeight"),
            contentBody = component.find("contentBody").getElement(),
            tableBody = component.find("tableBody").getElement();
        contentBody.style.height = bodyHeight + 'px';
        contentBody.style.maxHeight = bodyHeight + 'px';
        tableBody.style.height = gridHeight + 'px';
        tableBody.style.maxHeight = gridHeight + 'px';    
    },

    getContents : function(component){
        //console.log('Query Weekly Reports');
        var self = this,
            reportDate = component.get("v.reportDate");

        component.set("v.showSpinner", true);
        self.apex(component, 'getWeeklyReports', { reportDate : reportDate})
            .then(function(result){
                console.log('getWeeklyReports -> ', result);
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
            ["c:weeklyReportEditBody", { recordId : recordId }],
            ["c:weeklyReportEditFooter", { onsubmit : component.getReference("c.saveFromChild") }]
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
            // records = component.get("v.weeklyReports"),
            records = component.get("v.selectedReports"),
            modalBody,
            modalFooter;

        $A.createComponents([
            ["c:weeklyReportPreviewBody", { reports : records }],
            ["c:weeklyReportPreviewFooter", { onsubmit : component.getReference("c.clickSendEmail") }]
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
                        //self.showMyToast("info", "Sent a Issue Report");
                    }
                })
            }
        });
    },

    handleChange : function(component, event){
        window.console.log('Helper handleChange');
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
                    console.log('### weeklyReportBodyHelper, apex ERROR : ', callbackResult.getError() ); 
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