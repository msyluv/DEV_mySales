({
    getInit : function(component ,event, helper) {
        var self = this;
        
        self.apex(component, 'getDate', {
            'recordId' : component.get('v.recordId')
        })
        .then(function(result){
            console.log(result);
            component.set('v.approvalHTML', result);
        })
        .catch(function(errors){
                console.log(errors);
                self.errorHander(errors);
        }).finally(function(){
            
        });
    },    

    /**
     * Common Functions
     */

    showtoast : function(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : type,
            "title": title,
            "duration": 10000,
            "message": message
        });
        toastEvent.fire();
    },

    apex : function(component, apexAction, params) {
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

    errorHander : function(errors){
        var self = this;
        if(Array.isArray(errors)){
            errors.forEach(function(err){
                self.showtoast('error', '', err.exceptionType + " : " + err.message);
            });
        } else {
            console.log(errors);
            self.showtoast('error', '', 'Unknown error in javascript controller/helper.')
        }
    }
})