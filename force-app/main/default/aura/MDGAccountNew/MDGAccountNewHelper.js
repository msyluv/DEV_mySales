/**
 * @description       : 
 * @author            : jiiiiii.park@partner.samsung.com.sds.dev
 * @group             : 
 * @last modified on  : 2021-03-05
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   2020-11-30   jiiiiii.park@partner.samsung.com.sds.dev   Initial Version
**/
({
    helperInit : function(component, event) {
        // var close =  $A.get("e.force:closeQuickAction");
        var refresh = $A.get('e.force:refreshView');
        var device = $A.get( "$Browser.formFactor");
        var self = this;
        self.apex(component, 'getAccountInfo',{
            recordId : component.get("v.recordId")
        })
        .then(function(result){
            if( device === "PHONE" || device === "IPHONE"){
                component.set('v.isMobile', true);
                $A.get("e.force:closeQuickAction").fire();
                self.showMyToast('error', 'This feature does not support the mobile environment.');
            }else{
                window.console.log('result : ', result);
                if(result.Country == 'KR') component.set('v.isKorea', true);
                if(result.Valid == 'true'){
                    self.showMyToast('success', $A.get( "$Label.c.MDG_MSG_0002")); // MDG call success
                    $A.get('e.force:refreshView').fire();
                    refresh.fire();
                }else{
                    self.showMyToast('error',result.Msg);
                }
            }
        })
        .then(function(result){
            component.set('v.showSpinner', false);
        })
        .catch(function(errors){
            self.errorHandler(errors);
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