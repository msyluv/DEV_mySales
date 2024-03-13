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
	doInit : function(component, event) {
		var self = this;

		self.apex(component, 'defaultSetting', { 
			}).then(function(result){
				// window.console.log('result : ', result);
				var status = result.Status,
					rcdType = result.RecordType,
					service = result.Service,
					solution = result.Solution,
					collaboration = result.Collaboration,
					internalBiz = result.InternalBiz;

				component.set('v.status', status);
				component.set('v.selectedValue.Status', status[0].value);
				component.set('v.rcdType', rcdType);
				component.set('v.selectedValue.RecordType', rcdType[0].value);
				component.set('v.service', service);
				component.set('v.selectedValue.Service', service[0].value);
				component.set('v.solution', solution);
				component.set('v.selectedValue.Solution', solution[0].value);
				component.set('v.collaboration', collaboration);
				component.set('v.selectedValue.Collaboration', collaboration[0].value);
				component.set('v.internalBiz', internalBiz);
				component.set('v.selectedValue.GroupInternal', internalBiz[0].value);
                component.set('v.selectedValue.StrategicAccount', 'All'); // Added by Anish - v 1.2
			}).catch(function(errors){
				self.errorHandler(errors);
			}).finally(function(){
				self.getOppList(component, event, '', '');
			});

	},

	getOppList : function(component, event, rcdId, searchType) {
		var selectedValue = component.get('v.selectedValue');
		
		var self = this;

		if(selectedValue.StartDate != null && selectedValue.EndDate == null){
			self.showMyToast('error', $A.get( "$Label.c.BOSEARCH_MSG_0001")); // Please select CloseDate(End)
			component.set('v.loading', false);
			return;
		}
		
		if(selectedValue.EndDate != null && selectedValue.StartDate == null){
			self.showMyToast('error', $A.get( "$Label.c.BOSEARCH_MSG_0002")); // Please select CloseDate(Start)
			component.set('v.loading', false);
			return;
		}

		self.apex(component, 'getOpptyList', {
			pageSize : '20', 
			rcdId : rcdId, 
			searchType : searchType, 
			selectedValue : JSON.stringify(selectedValue)
			}).then(function(result){
            	var opptyList = JSON.parse(result.LIST);
				if(searchType == 'Prev') opptyList = JSON.parse(result.LIST).reverse();

				component.set('v.OpptyList', opptyList);

				if(searchType == ''){
					component.set('v.totalCount', result.TOTALCOUNT);
					component.set('v.totalPage', JSON.parse(result.COUNT)*1);
				}

				component.set('v.selectedCurrValue',selectedValue);
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