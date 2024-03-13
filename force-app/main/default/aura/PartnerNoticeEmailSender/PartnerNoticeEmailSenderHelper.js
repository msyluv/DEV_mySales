/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 08-05-2022
 * @last modified by  : ukhyeon.lee@samsung.com
**/
({
	helperinit : function(component, event) {
        var self = this;        
        self.getEmailInfo(component);
	}, 
	
    getEmailInfo: function(component){
        var self = this;
        self.apex(component, 'getEmailInfo', {recordId: component.get('v.recordId')}
        ).then(function(result){
            if(result.RESULT == 'S'){
                component.set('v.Email_Send_Subject__c', result.Email_Send_Subject__c);
                component.set('v.Email_Send_Count__c', result.Email_Send_Count__c);
                component.set('v.Active_InActive__c', result.Active_InActive__c);
                component.set('v.Last_Email_Sent_Date__c', result.Last_Email_Sent_Date__c);
                component.set('v.Email_Sender', result.Email_Sender);

                if (!result.Active_InActive__c){ 
                    self.showToast('error', $A.get('$Label.c.PARTNER_NOTICE_EMAIL_ERROR_INACTIVE'));
                    return;
                }

                component.set('v.isInputDisabled', false); 

                if(result.Email_Send_Subject__c==null){                    
                    return;
                }                

                component.set('v.isSendDisabled', false);
            }else{
                self.showToast('error', result.MESSAGE);
			}            
        }).catch(function(errors){
            self.errorHandler(errors);
        }).finally(function(){
            component.set('v.showSpinner', false);
        });
	},      

    emailSend : function(component, event){
        component.set('v.showSpinner', true);        
        var self = this;
        var close = $A.get("e.force:closeQuickAction");
        var refresh = $A.get('e.force:refreshView');

        self.apex(component, 'sendEmailAndUpdateCount', {
            recordId : component.get('v.recordId'),
            emailSendSubject : component.get('v.Email_Send_Subject__c'),
        }).then(function(result){
            if(result.RESULT == 'S'){
                self.showToast('success', result.MESSAGE);
                self.getEmailInfo(component);             
            }else{
                self.showToast('error', result.MESSAGE);
            }
        }).catch(function(errors){
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
                    if(apexAction=='sendEmailAndUpdateCount'){
                        window.setTimeout(
                            $A.getCallback(function() {
                                $A.get("e.force:closeQuickAction").fire();
                            }), 5000
                        );
                    } else if(apexAction=='getEmailInfo'){
                        window.setTimeout(
                            $A.getCallback(function() {
                                component.find("Email_Send_Subject__c").focus();                
                            }), 500
                        );
                    }
                    
                }
                if(callbackResult.getState()=='ERROR') {
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
				self.showToast('error', 'ERROR', err.exceptionType + " : " + err.message);
			});
		} else {
			console.log(errors);
			self.showToast('error', 'ERROR' ,'errors:'+ errors.message);
		}
	},

    showToast : function(type, msg) {
		var mode = 'sticky';
		if(type.toLowerCase() == 'success') mode = 'pester';
		
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 3000,
            mode: mode,
            message: msg
        });
        toastEvent.fire();
	},
})