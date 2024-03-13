/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2022-02-21
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-01-25   younghoon.kim@dkbmc.com   Initial Version
**/
({
	weeklyReportSend : function(component, event) {
		var close = $A.get("e.force:closeQuickAction");
		var self = this;
        self.apex(component, 'sendWeeklyReport', {
            rcdId : component.get('v.recordId')
        }).then(function(result){
			close.fire();
            if(result.RESULT == 'S'){
            	self.showMyToast('success', result.MSG);
            }else if(result.RESULT == 'W'){
                self.showMyToast('warning', result.MSG);
            }else{
                self.showMyToast('error', result.MSG);
            }			
        }).catch(function(errors){
            self.errorHandler(errors);
        }).finally(function(){
			component.set('v.showSpinner', false);
        });
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
				self.showMyToast('error', err.exceptionType + " : " + err.message);
			});
		} else {
			console.log(errors);
			self.showMyToast('error', 'Unknown error in javascript controller/helper.');
		}
	},

    showMyToast : function(type, msg) {
        var mode = 'sticky';
        if(type.toLowerCase() == 'success') mode = 'dismissible';

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 5000,
            mode: mode,
            message: msg
        });
        toastEvent.fire();
	}
})