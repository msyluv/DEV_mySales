/**
@author            : divyam.gupta@samsung.com
  @description       : Warning if Close Date is later than Contract Start Date. 
  @last modified on  : 09-18-2023
  @last modified by  : divyam.gupta@samsung.com
  Modifications Log 
  Ver   Date         Author                   	Modification
  1.0   2023-09-18   Divyam.gupta@samsung.com       Initial Version
 **/
({
	 getCloseDatevaluecheck: function(component,event){
        var self = this;
        var oppid = component.get("v.recordId");
         console.log('oppid',oppid);
        self.apex(component, 'getCloseDatevaluecheck', {oppid: oppid}).then(function(result){
            window.console.log('result : ', result);
            console.log('activity status Test@@ : ', result);  
            if(result == 'CheckCloseDate')
            {
                //component.set("v.CheckcloseDate",result.Check_Close_Date__c);
                
                     //self.showMyToast('error','Please change close date');        
                     self.showMyToast('Warning',$A.get("$Label.c.Opp_Close_Date_Warning_Msg"));
                
            }
            
        }).catch(function(errors){
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
            self.showMyToast('error', 'Unknown error in javascript controller/helper.')
        }
    },
    showMyToast : function(type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 10000,
            mode: 'dismissible',
            message: msg
        });
        toastEvent.fire();
    }
})