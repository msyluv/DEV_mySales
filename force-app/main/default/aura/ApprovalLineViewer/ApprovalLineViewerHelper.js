/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-05-14
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-05-13   younghoon.kim@dkbmc.com   Initial Version
**/
({
	helperInit : function(component, event) {
		var self = this;
		self.apex(component, 'defaultSetting', { })
		.then(function(result){
			component.set('v.approvalType', result);
		}).catch(function(result){
			self.showMyToast('ERROR',  result.Error.message);
		}).finally(function(){
			component.set('v.showSpinner', false);
        });
	},

	knoxSearch : function(component, event) {
		var self = this;
		var apprList = [];

		var selectedValue = component.get('v.searchValue');

		if(selectedValue.OpportunityCode == '') self.showToast('error', $A.get( "$Label.c.APPRVIEWER_MSG_0001")); // Please enter opportunity code
		if(selectedValue.ApprovalType == '') self.showToast('error', $A.get( "$Label.c.APPRVIEWER_MSG_0002")); // Please select approval type

		if(selectedValue.OpportunityCode != '' && selectedValue.ApprovalType != ''){
			component.set('v.showSpinner', true);
			self.apex(component, 'getKnoxApproval', { 
				'opptyCode' : selectedValue.OpportunityCode,
				'pickValue' : selectedValue.ApprovalType
			}).then(function(result){
				if(result.Result == 'F'){
					self.showMyToast('ERROR', result.Message);
				}else{
					if(result.ApprovalLine != ''){
						var resultList = JSON.parse(result.ApprovalLine)

						for(var i = 0; i < resultList.length; i++){
							var type = '';
							if(resultList[i].ApproverType__c == '1') type = 'Appr';
							else if(resultList[i].ApproverType__c == '2') type = 'Cons';
							else if(resultList[i].ApproverType__c == '9') type = 'Noti';

							var appr = {
								'Name' 				: resultList[i].Name + ' - ' + resultList[i].EvEName__c,
								'Dept'				: (result.Language).includes('ko') ? resultList[i].EvSdeptNM__c : resultList[i].EvSdeptENM__c,
								'EvMailAddr__c' 	: resultList[i].EvMailAddr__c,
								'Type'				: type
							}
							apprList.push(appr);
						}
						component.set('v.approvalLine', apprList); 
					} 
					if(result.HTML != ''){
						component.set('v.approvalHTML', result.HTML);
					} 
				}
			}).catch(function(errors){
                self.errorHandler(errors);
			}).finally(function(){
				component.set('v.showSpinner', false);
			});
		}
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