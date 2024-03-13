({
	initCompoent : function(component, event){
		component.set('v.showSpinner', true);

		var self = this;
        var record = component.get("v.record");	    
		var recordId = record.Id;
		var toastTitle,
			toastMsg,
			toastType = 'error';
		var closeQuickModalEvt = $A.get("e.force:closeQuickAction");

		var action = component.get("c.initComponent");      
		action.setParams({
			'recordId' : recordId
		});
		self.directApex(action)
			.then((result) => {		
				if(result.RESULT){
					component.set('v.canGetStatus', true);

				}else{
					component.set('v.canGetStatus', false);
					toastType = 'error';
					toastTitle = $A.get('$Label.c.COMM_LAB_ERROR');
					toastMsg = result.MSG;

					component.set('v.toastType', toastType);
					component.set('v.toastMessage', toastMsg);

					self.showToast(component, 'ERROR', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), result.MSG); 
					closeQuickModalEvt.fire();
				}  
				
			})
			.catch((errors) => {
				self.errorHander(errors);
			})
			.finally(() => {
				component.set('v.showSpinner', false);
			});
	},

    callKnoxApprovalStatus : function(component, event){
		component.set('v.showSpinner', true);

		var self = this;
        var record = component.get("v.record");	    
		var approvalObj = {
			'KnoxApproval' : {
                "Id": record.Id,
                "Status__c" : record.Status__c,
				"MISID__c": record.MISID__c
			}
		};

		var toastTitle,
			toastMsg,
			toastType = 'error';
		
		var closeQuickModalEvt = $A.get("e.force:closeQuickAction");
		var refreshViewEvt = $A.get('e.force:refreshView');

        var action = component.get("c.getKnoxApprovalStatus");      
		action.setParams({
			'jsonParam' : JSON.stringify(approvalObj)
		});
		self.directApex(action)
			.then((result) => {		
				console.log('# Result', JSON.stringify(result));	
				if(result.RESULT == 'success'){
                    toastType = 'success';
					toastTitle = $A.get('$Label.c.COMM_LAB_SUCCESS');
					toastMsg = $A.get('$Label.c.SAPP_MSG_0001');	// 결재 상태가 업데이트 되었습니다.
					
					closeQuickModalEvt.fire();
				}else{
                    toastType = 'error';
					toastTitle = $A.get('$Label.c.COMM_LAB_ERROR') 
					toastMsg = result.Message;
				}  

				self.showToast(component, toastType , 'sticky', toastTitle, toastMsg); 
			})
			.catch((errors) => {
				self.errorHander(errors);
			})
			.finally(() => {
				component.set('v.showSpinner', false);
				component.set('v.isRefreshed', true);
				refreshViewEvt.fire();
			});
	},

	apex : function(component, apexAction, params){
        return new Promise( $A.getCallback( function( resolve, reject ) {
			var action = component.get("c."+apexAction+"");
			action.setParams( params );
			
			console.log('@ apex.action ', apexAction);
			console.log('@ apex.params ', params);

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
	
	directApex : function(action){
		console.log('directApex');

        return new Promise( $A.getCallback( function( resolve, reject ) {
            action.setCallback( this, function(callbackResult) {
				console.log('callbackResult.getState()', callbackResult.getState());
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
		var toastType,toastMsg;
        if(Array.isArray(errors)){
            errors.forEach(function(err){
				toastType = 'error';
				toastMsg = err.message;	
            });
        } else {
			console.log(errors);
			toastType = 'error';
			toastMsg = errors;
        }
		self.showToast(null, 'ERROR', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR') , 'Unknown error in javascript controller/helper. ' + toastMsg);
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