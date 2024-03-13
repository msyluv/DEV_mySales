/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-01-28
 * @last modified by  : hj.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   11-20-2020   woomg@dkbmc.com   Initial Version
**/
({
    DEBUG : true,

    doInit : function(component, event) {
        console.log("do Init");
        var device = $A.get("$Browser.formFactor");
        var self = this;
        var action = component.get("c.initComponent");

        action.setParams({
            'recordId': component.get('v.recordId'),
            'isDelTempAct' : true
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {    
                
                var result = response.getReturnValue(); 
                self.log('result', result);
                
                component.set('v.activityItemList',result['1']);
                component.set('v.activityItemListDetail',result['2']);

            }
        });
        $A.enqueueAction(action);

    },
    revers : function(targetlist){
        var templist =[]
        for(var i=targetlist.length-1;i>=0;i--){
            templist[targetlist.length-1-i] = targetlist[i];
        }
        return templist;
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

    errorHander : function(errors){
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
            duration: 3000,
            mode: 'dismissible',
            message: msg
        });
        toastEvent.fire();
    },
    

    log : function(msg, object) {
        var objectToJSONObject = object ? JSON.parse(JSON.stringify(object)) : object;
        if(this.DEBUG) console.log(msg, objectToJSONObject);
	},

})