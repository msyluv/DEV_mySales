/**
 * @description       : 
 * @author            : jiiiiii.park@partner.samsung.com.sds.dev
 * @group             : 
 * @last modified on  : 2021-03-02
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   2020-11-25   jiiiiii.park@partner.samsung.com.sds.dev   Initial Version
**/
({
    helperInit : function(component, event) {
        var close =  $A.get("e.force:closeQuickAction");
        var self = this;
        self.apex(component, 'collaborationCheck', {
            recordId : component.get('v.recordId')
        })
        .then(function(result){
            if(result.STATUS == 'ERROR'){
                self.showMyToast('error', result.MESSAGE);
                close.fire();
            }
        })
        .catch(function(errors){
            self.errorHandler(errors);
        }).finally(function(){
            component.set('v.showSpinner', false);
        });
    },

    helperSave : function(component, event) {
        component.set('v.showSpinner', true);

        var self = this;
        var refresh =  $A.get('e.force:refreshView'),
            close =  $A.get("e.force:closeQuickAction");

        var opptyId = component.get('v.recordId'),
            selectedUserId = component.get('v.selectedUser').Id;

        if(selectedUserId != undefined){
            self.apex(component, 'saveCollaboration', {
                opptyId : opptyId,
                userId : selectedUserId
            })
            .then(function(result){
                if(result == 'SUCCESS'){
                    close.fire();
                    refresh.fire();
                    self.showMyToast('success', $A.get( "$Label.c.COLLABO_MSG_0001")); // Collaboration save success.
                }
            })
            .catch(function(errors){
                self.errorHandler(errors);
            }).finally(function(){
                component.set('v.showSpinner', false);
            });
        }else{
            component.set('v.showSpinner', false);
            self.showMyToast('error', $A.get( "$Label.c.COLLABO_MSG_0002")); // Please enter User and Account.
        }
    },

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
				self.showMyToast('error', err.message);
			});
		} else {
			console.log(errors);
			self.showMyToast('error', 'Unknown error in javascript controller/helper.');
		}
	},

    showMyToast : function(type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 10000,
            mode: 'sticky',
            message: msg
        });
        toastEvent.fire();
	},
})