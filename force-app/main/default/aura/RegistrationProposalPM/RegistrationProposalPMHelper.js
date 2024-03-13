/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2022-01-04
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-05-13   younghoon.kim@dkbmc.com   Initial Version
**/
({
	helperInit : function(component, event) {
		var opptyId = component.get('v.recordId');

		var self = this;
        self.apex(component, 'init', {
            'opptyId' : opptyId
        })
        .then(function(result){
			if(result.ProposalPM__c != null){
                component.set('v.pmCheck', true);
            } else{
                component.set('v.pmCheck', false);
            }
            component.set('v.opportunity', result);
        })
        .catch(function(errors){
            self.errorHandler(errors);
        }).finally(function(){
			component.set('v.showSpinner', false);
        });
	},
	pmSave : function(component, event) {
		component.set('v.showSpinner', true);

		var selectedEmp = component.get('v.selectedEmp'),
			opptyId = component.get('v.recordId'),
			close =  $A.get("e.force:closeQuickAction"),
			refresh =  $A.get('e.force:refreshView');

		var self = this;
        self.apex(component, 'proposalPMSave', {
            'opptyId' : opptyId, 
			'empId' : selectedEmp.Id
        })
        .then(function(result){
			self.showMyToast('Success', $A.get("$Label.c.PPM_MSG_0003")); // Save Proposal PM
			close.fire();
			refresh.fire();
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
    handleOpenLink  : function(component, event) {
		var urlValue = event.getSource().get('v.value');
        console.log('Akash2' + urlValue);
        var buttonId = event.getSource().getLocalId();
		var oppty = component.get('v.opportunity');

        switch (buttonId) {
            case 'REQ_PROPOSAL_PM': // 제안PM요청
				urlValue = urlValue.replace('{0}', oppty.OpportunityCode__c);
				break;
        }
        console.log(' # URL : ', urlValue);
        window.open(urlValue, '_blank');
    }
})