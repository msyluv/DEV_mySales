({
	init : function(component, event) {
		console.warn('{ knoxActNew.init }');
		console.log('=== recordId', component.get('v.recordId'));
		// console.log('=== opptyId', component.get('v.opptyId'));
		console.log('=== transactionName', component.get('v.transactionName'));

		var self = this,
			apexAction = 'initComponent',
			params = { 
				'recordId' : component.get('v.recordId'),
				'transactionName' : component.get('v.transactionName')
			};

		self.apex(component, apexAction, params)
			.then((result) => {
				component.set('v.opptyId', result.opptyId);
				component.set('v.opptyActId', result.opptyActId);
				component.set('v.isPendingKnoxApproval', result.isPendingKnoxApproval);

				component.set('v.activeStep', result.isPendingKnoxApproval ? '3_3' : '3_1');

				console.log('=== opptyId', component.get('v.opptyId'));
				console.log('=== opptyActId', component.get('v.opptyActId'));
				console.log('=== isPendingKnoxApproval', component.get('v.isPendingKnoxApproval'));

				// 결재선 가져오기
				// console.log('💥 getApprovalLine');
				// component.set('v.isCompletedGetApproval', true);
				
				// var approvalLineGetEvent = component.get("e.c:approvalLineGetEvent");
				// approvalLineGetEvent.fire();
				
			})
			.catch((errors) => {
				console.log('errors', errors);
			})
			.finally(() => {
				
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
    }
})