/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 02-04-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            		Modification
 * 1.0   01-04-2021   woomg@dkbmc.com   		Initial Version
 * 1.1   2024-03-26   aditya.r2@samsung.com		Added new Editor field Issue_Description_Check__c
**/
({
    doInit : function(component, event) {
        var self = this,
            recordId = component.get("v.recordId");
        //console.log('recordId', recordId);
        component.set("v.showSpinner", true);
        self.apex(component, 'getIssueReport', { recordId : recordId})
            .then(function(result){
                //console.log('getWeeklyReport -> ', result);
                component.set("v.report", result);
                //v1.1
                component.set("v.content", result.IssueDescription__c);
                component.set("v.contentNew", result.Issue_Description_Check__c);
                if(result.DisplayOrder__c != undefined && result.DisplayOrder__c != null){
                    component.set("v.order", result.DisplayOrder__c);
                }
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.set("v.showSpinner", false);
            });
    },

    saveContent : function(component) {
        var self = this,
            recordId = component.get("v.recordId"),
            content = component.get("v.content"),
            contentNew = component.get("v.contentNew"),
            vfValue = component.get("v.vfValue"),
            pressMe = component.get("v.pressMe"),
            order = component.get("v.order");

        //v1.1
        if(vfValue!= contentNew && pressMe == "1")
            contentNew = vfValue;
        
        component.set("v.showSpinner", true);
        //v1.1
        self.apex(component, 'saveIssuesContent', { recordId : recordId, content : content, order : order, contentNew : contentNew  })
            .then(function(result){
                //console.log('saveContent -> ', result);
                component.set("v.showSpinner", false);
                self.showMyToast("success", "Issue content saved!");
                component.find("overlayLib").notifyClose();
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.set("v.showSpinner", false);
                component.find("overlayLib").notifyClose();
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