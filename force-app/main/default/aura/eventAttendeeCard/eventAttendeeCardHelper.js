/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 01-18-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   01-18-2021   woomg@dkbmc.com   Initial Version
**/
({
	deleteEvent : function(component){
        var recordId = component.get("v.recordId"),
            onchangeEvent = component.get("v.onchange");

        component.set("v.showSpinner", true);
		self.apex(component, 'deleteEventAttendee', { attendeeId : recordId })
            .then(function(result){
                console.log('deleteEventAttendee : ', result);
                if(onchangeEvent != null) $A.enqueueAction(onchangeEvent);
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHander(errors);
                component.set("v.showSpinner", false);
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

    errorHander : function(errors){
        var self = this;
        if(Array.isArray(errors)){
            errors.forEach(function(err){
                self.showMyToast('error', err.exceptionType + " : " + err.message);
            });
        } else {
			console.log(errors);
			var msg = $A.get("Unknown APEX Javascript Error!");
            self.showMyToast('error', msg)
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