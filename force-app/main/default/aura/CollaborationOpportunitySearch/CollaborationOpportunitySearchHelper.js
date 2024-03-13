/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2024-02-02
 * @last modified by  : sarthak.j1@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-11-26   younghoon.kim@dkbmc.com   Initial Version
 * 1.1   2024-02-02   sarthak.j1@samsung.com    MYSALES-443
**/
({
	helperInit : function(component, event) {
		var self = this;
		self.apex(component, 'init', {  }
			).then(function(result){
				component.set('v.stage', result);
				component.set('v.selectedStage', result[0].value);
			}).catch(function(errors){
				self.errorHandler(errors);
			}).finally(function(){
				self.getOpptyList(component, event, 'INIT');
			});
	},

	getOpptyList  : function(component, event, type) {
		var limits = component.get('v.initialRows'),
			offsets = component.get('v.rowNumberOffset'),
			stage = component.get('v.selectedStage'),
			oppcode = component.get('v.opportunityCode'),
			oppname = component.get('v.opportunityName'),
			opptyList = [];

		if(type == 'MORE'){
			opptyList = component.get('v.opptyList');
			offsets = opptyList.length;
		}

		//component.set('v.opptyList', opptyList); //Commented out as part of v-1.1 [MYSALES-443]

		var self = this;
		self.apex(component, 'getCollaboOpptyInfo', { limits : limits, offsets : offsets, stage : stage , oppcode : oppcode , oppname : oppname}
			).then(function(result){
				var resultList = JSON.parse(result.LIST);

				if(type == 'INIT'){
					var count = result.TOTAL * 1;
					component.set('v.totalNumberOfRows', count);
				}

				component.set('v.rowNumberOffset', offsets + resultList.length);
				let hostname = window.location.hostname;
				for(var i = 0; i < resultList.length; i++){ 
					var iconName = resultList[i].CollaborationInOut__c == 'IN' ? 'utility:back' : 'utility:forward';
					var oppty = {
						'Id' 				: resultList[i].Id,
						'Name' 				: resultList[i].Name,
						'AccName' 			: resultList[i].Account == null ? '' : resultList[i].Account.Name,
						'CloseDate' 		: resultList[i].CloseDate,
						'Amount' 			: resultList[i].Amount == null ? 0 : resultList[i].Amount,
						'Currency'			: resultList[i].CurrencyIsoCode,
						'StageName' 		: resultList[i].StageName,
						'OpptyCode' 		: 'https://' + hostname + '/' + resultList[i].Id,
						'opportunityCode'	: resultList[i].OpportunityCode__c,
                        'CompanyCode' 		: resultList[i].CompanyCode__c,
						'CompanyName'		: resultList[i].CompanyName__c,
						'displayIconName' 	: iconName,
						'CollaborationId' 	: resultList[i].CollaborationBOId__c,
						'InOut'				: resultList[i].CollaborationInOut__c,
						'Status'			: resultList[i].IsClosed==false ? 'In Progress' : resultList[i].IsWon ? 'Won' : 'Lost & Drop'
					}
					opptyList.push(oppty);
				}
				component.set('v.opptyList', opptyList);
				
				if(type == 'INIT'){
					if(count <= 50){
						component.set('v.enableInfiniteLoading', false);
					}
				}else if(type == 'MORE'){
					if(opptyList.length >= component.get('v.totalNumberOfRows')){
						component.set('v.enableInfiniteLoading', false);
					}
				}
			}).catch(function(errors){
				self.errorHandler(errors);
			}).finally(function(){
				// spinner stop
				component.set("v.showSpinner", false);
				component.set("v.myOpptySpinner", false);
				component.set("v.collaboOpptySpinner", false);

				// Infinite loading stop
				event.getSource().set("v.isLoading", false);
				component.set('v.loadMoreStatus', '');
			});
	},
	
	getOpptyInfo  : function(component, event, selectedId) {
		var self = this;
		self.apex(component, 'getSelectedOppty', {
			selectedId : selectedId
			}).then(function(result){
				if(result.length > 0) component.set("v.collaboOppty", result[0].Id);
			}).catch(function(errors){
				self.errorHandler(errors);
			}).finally(function(){
                window.setTimeout(function(e){
                    // component.set("v.showSpinner", false);
                    component.set("v.myOpptySpinner", false);
                    component.set("v.collaboOpptySpinner", false);
                }, 500);
                
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

    showToast : function(type, title, message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
	},
})