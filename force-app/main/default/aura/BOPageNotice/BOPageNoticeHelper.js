({
	doInit : function(component, event) {
		var self = this;
		var message = '';
		var apexAction = 'getCMEnterAlertMsg',
			apexParams = {
				'BOId' : component.get('v.recordId')
			};
		self.apex(component, apexAction, apexParams)
		.then((result) => {
			if(result.CMEnterAlertMsg != ''){
            console.log('-------- [try] CMEnterAlertMsg.try' + result.CMEnterAlertMsg );
				self.showToast(component, 'WARNING', 'sticky', null,result.CMEnterAlertMsg, 10000);
			} 
               
		})
		.catch((errors) => {
			self.errorHander(errors);
		})
		.finally(() => {
			console.log('-------- [E] CMEnterAlertMsg.finally' );
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
	
	/**
	 * 
	 * @param {*} component 
	 * @param {*} type 		'error', 'warning', 'success', 'info'
	 * @param {*} mode 		'pester', 'sticky', 'dismissible'
	 * @param {*} title 
	 * @param {*} message 
	 * @param {*} duration 
	 */
    showToast : function(component, type, mode, title, message, duration) {
        switch (type.toLowerCase()) {
            case 'error':
                mode = 'sticky';
                break;
            case 'warning':
                mode = 'sticky';
                break;
            case 'success':
                mode = 'dismissible';
                duration = 5000;
                break;
		}
		
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type : type,
            mode : mode,
            title: title,
            message : message,
            duration : duration
        });
        toastEvent.fire();
    }
})