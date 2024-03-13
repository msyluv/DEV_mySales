/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-07-15
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-11-02   younghoon.kim@dkbmc.com   Initial Version
 * 1.1   2023--02-10  anish.jain@partner.samsung.com Modification for 'TA' checkbox (My Sales -125)
 * 1.2   2023-02-22   anish.jain@partner.samsung.com   Changes Added for new Search box 'Intensive BO' regarding (My Sales - 141)
**/
({
	getOppList : function(component, event, rcdId, searchType) {

        var self = this;
        var recordId = component.get('v.recordId');
        console.log("Inside Helper Opp Id: "+recordId);
        
		self.apex(component, 'getOpptyList', {
			pageSize : '21', 
			rcdId : rcdId, 
			searchType : searchType, 
            recordId : recordId
			}).then(function(result){
            	var opptyList = JSON.parse(result.LIST);
				if(searchType == 'Prev') opptyList = JSON.parse(result.LIST).reverse();

				component.set('v.OpptyList', opptyList);
            	component.set('v.Service', result.Service);
            	component.set('v.Solution', result.Solution);
            	component.set('v.Type1', result.Type1);
            	component.set('v.Type2', result.Type2);
            	component.set('v.BizLevel', result.BizLevel);

				if(searchType == ''){
					component.set('v.totalCount', result.TOTALCOUNT);
					component.set('v.totalPage', JSON.parse(result.COUNT)*1);
				}

			}).catch(function(errors){
				self.errorHandler(errors);
			}).finally(function(){
				component.set('v.loading', false);
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

	showToast : function(type, message){
		console.log('message:' + message);
		var toastEvent = $A.get("e.force:showToast");
		var mode = (type == 'success') ? 'pester' : 'sticky';
        toastEvent.setParams({
            "type" : type,
			"message": message,
			"mode": mode,
			"duration": 5000
        });
        toastEvent.fire();
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
	}
})