/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2023-08-30
 * @last modified by  : atul.k1@samsung.com
**/
({
	init : function(component, event) {
		var self = this;
        self.apex(component, 'urlSetting', {
            
        })
        .then(function(result){
             console.log('Result==>' + result);
            for (var i = 0; i < result.length; i++) {
                console.log('Object ' + (i+1) + ':', result[i]);
                if(result[i].Order == '' || result[i].Order == null){
                    result[i].Order = 0;
                }
              }
              
            result.sort(function(a, b) {
                
                return a.Order - b.Order;
              });
             console.log('ResultLength==>' + result.length);
              for (var i = 0; i < result.length; i++) {
                console.log('Object ' + (i+1) + ':', result[i]);
              }
              component.set('v.urlList', result);
        })
        .catch(function(errors){
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