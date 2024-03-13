({
	save : function(component, event){
		var self = this;

		var fileCmpCount = component.find('fileCmp').get('v.count');
		var fileCmpRecordId = component.find('fileCmp').get('v.recordId');
		console.log('fileCmpRecordId', fileCmpRecordId);
		if(fileCmpCount == 0) {
			self.showToast(null, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.FILE_MSG_0005'));
		}else {
			var opportunityActivityUpdateEvent = component.getEvent("opportunityActivityUpdateEvent");
			opportunityActivityUpdateEvent.setParams({status: 'Completed'});
			opportunityActivityUpdateEvent.fire();
			
			// self.close(component, event);
			self.showToast(null, 'SUCCESS', 'dismissible', $A.get('$Label.c.COMM_LAB_SUCCESS'), $A.get('$Label.c.COMM_MSG_0002'));
		}
	},

    close : function(component, event) {
		component.find('overlayLib').notifyClose();
	},

	apex : function(component, apexAction, params){
        return new Promise( $A.getCallback( function( resolve, reject ) {
			var action = component.get("c."+apexAction+"");
			action.setParams( params );
			

			console.log('call apex : action ', apexAction);
			console.log('call apex : params ', params);

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
				self.showToast(null, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR') , err.message);
            });
        } else {
            console.log(errors);
			self.showToast(null, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR') , 'Unknown error in javascript controller/helper.');
        }
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