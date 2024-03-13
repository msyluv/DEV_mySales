/**
 * @author            : akash.g@samsung.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2022-06-13
 * @last modified by  : akash.g@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2022-06-13   akash.g@samsung.com   Initial Version
 * 1.1   2022-06-16   akash.g@samsung.com   Add functionality to check whether opportunity is won or not.
**/
({
    helperInit : function(component, event) {
        var opptyId = component.get('v.recordId');
        close =  $A.get("e.force:closeQuickAction");
        var self = this;
        self.apex(component, 'init', {
            'opptyId' : opptyId
        })
        .then(function(result){
            /**1.1 : Add functionality to check whether opportunity is won or not**/
            if(result.StageName == 'Z05'){
                close.fire();
                self.showMyToast('error', $A.get("$Label.c.RPM_MSG_0005"));
            }else{
                if(result.RepresentativePM__c != null){
                    component.set('v.pmCheck', true);
                } else{
                    component.set('v.pmCheck', false);
                }
                component.set('v.opportunity', result);
            }
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
        self.apex(component, 'representativePMSave', {
            'opptyId' : opptyId, 
            'empId' : selectedEmp.Id
        })
        .then(function(result){
            self.showMyToast('Success', $A.get("$Label.c.RPM_MSG_0003")); // Save Representative PM
            close.fire();
            refresh.fire();
        })
        .catch(function(errors){
            self.errorHandler(errors);
        }).finally(function(){
            component.set('v.showSpinner', false);
        });
    },
    handleOpenLink  : function(component, event) {
		var urlValue = event.getSource().get('v.value');
        var buttonId = event.getSource().getLocalId();
		var oppty = component.get('v.opportunity');

        switch (buttonId) {
            case 'REQ_REGISTRATION_PM': // 제안PM요청
				urlValue = urlValue.replace('{0}', oppty.OpportunityCode__c);
				break;
        }
        console.log(' # URL : ', urlValue);
        window.open(urlValue, '_blank');
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
    }
})