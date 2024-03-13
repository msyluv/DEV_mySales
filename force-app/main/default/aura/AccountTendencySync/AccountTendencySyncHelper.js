/**
 * @description       : 
 * @author            : minhye.park@dkbmc.com
 * @group             : 
 * @last modified on  : 2022-05-27
 * @last modified by  : younghoon.kim@dkbmc.com
**/

({
    helperInit : function(component, event) {
        var self = this;
		self.apex(component, 'AccountTendencySync', {

        })
		.then((result) => {
			if(result.Result == 'S'){
                self.showMyToast('success', result.Message);
			}else{
                self.showMyToast('error', result.Message);
            }
		})
		.catch((errors) => {
			self.errorHander(errors);
		})
		.finally(() => {
		});
        $A.get("e.force:closeQuickAction").fire();
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