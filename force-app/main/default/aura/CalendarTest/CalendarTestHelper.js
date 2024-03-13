/**
 * @description       : 
 * @author            : yeongju.baek@dkbmc.com
 * @group             : 
 * @last modified on  : 06-04-2021
 * @last modified by  : yeongju.baek@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   05-31-2021   yeongju.baek@dkbmc.com   Initial Version
**/
({
	/* getInputClass : function(c){
		return {

		}
	}, */
	invokeClass : function(component, apexAction, params) {
		console.log('invoketesthelper',params.userId);	
		console.log('apexaction',apexAction);	
        var p = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get("c."+apexAction+"");
            
            action.setParams( params );
            action.setCallback( this , function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
			if(callbackResult.getState()=='ERROR') {
				console.log('ERROR', callbackResult.getError() ); 
				reject( callbackResult.getError() );
			}
		});

		$A.enqueueAction( action );
		console.log('(after)invoketest');	
		
	}));    
	console.log(p);        
	return p; 
    },
	CalendarSearch : function(component, result){
		console.log('helper CalendarSearch active...')
	}
})