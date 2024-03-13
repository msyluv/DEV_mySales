/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-03-22
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-01-28   younghoon.kim@dkbmc.com   Initial Version
**/
({
	helperInit : function(component, event) {
		var close = $A.get("e.force:closeQuickAction");
		var self = this;
		self.apex(component, 'accountInfoCheck', {
			recordId : component.get('v.recordId')
		}).then(function(result){
			if(result == ''){
				close.fire();
				self.showMyToast('error', $A.get( "$Label.c.EXINFO_MSG_0002")); // Please enter your business registration number.
			}else{
				self.getExInfo(component, event, result);
			}
		}).catch(function(errors){
			self.errorHandler(errors);
		});
	},

	getExInfo : function(component, event, corpNum) {
		var close = $A.get("e.force:closeQuickAction");
		var self = this;
		self.apex(component, 'getExternalInformation', {
			corpNum : corpNum
		}).then(function(result){

			if(result.RESULT == 'S'){
				var exInfoList = [];
				var returnList = JSON.parse(result.DATA);
				var financeList = JSON.parse(result.FINANCE);
				var historyList = JSON.parse(result.HISTORY);
				var managerList = JSON.parse(result.MANAGER);

				if(returnList.length > 0){
					for(var i = 0; i < returnList.length; i++){
						var exInfo = {
							'InfoSource' : returnList[i].DATA_SOURCE,
							'NameKR' : returnList[i].CUST_KNAME,
							'NameEN' : returnList[i].CUST_ENAME,
							'CeoName' : returnList[i].CEO_NAME,
							'Address' : returnList[i].ADRESS ,
							'Phone' : returnList[i].PHONE_NO,
							'Fax' : returnList[i].FAX_NO,
							'Website' : returnList[i].HOMEPAGE,
							'CustRegNo' : returnList[i].CUST_REGNO,
							'JurirNo' : returnList[i].JURIR_NO,
							'EstDate' : returnList[i].EST_DATE,
							'IndustryCode' : returnList[i].INDUSTRY_CODE,
							'UpdateDate' : returnList[i].UPDATE_DATE
						};
						exInfoList.push(exInfo);
					}
					component.set('v.exInfoList', exInfoList);
				}

				component.set('v.financeList', financeList);
				component.set('v.historyList', historyList);
				component.set('v.managerList', managerList);

				
				window.console.log('financeList : ', component.get('v.financeList'));
				window.console.log('historyList : ', component.get('v.historyList'));
				window.console.log('managerList : ', component.get('v.managerList'));
			}else{
				close.fire()
				self.showMyToast('error', result.MESSAGE);
			}
		}).catch(function(errors){
			self.errorHandler(errors);
		}).finally(function(){
			component.set('v.showSpinner', false);
		});
	},

	saveExInfo : function(component, event) {
		var close = $A.get("e.force:closeQuickAction");
		var refresh = $A.get('e.force:refreshView');

		var selectedData = component.get('v.selectedColumn');

		window.console.log('financeList : ', component.get('v.financeList'));
		window.console.log('historyList : ', component.get('v.historyList'));
		window.console.log('managerList : ', component.get('v.managerList'));

		var self = this;
		self.apex(component, 'accInfoSave', {
			recordId : component.get('v.recordId'),
			exInfoData : JSON.stringify(selectedData),
			financeList : JSON.stringify(component.get('v.financeList')),
			historyList : JSON.stringify(component.get('v.historyList')),
			managerList : JSON.stringify(component.get('v.managerList'))
		}).then(function(result){
			if(result.RESULT == 'S'){
				close.fire();
				refresh.fire();
				self.showMyToast('success', result.MESSAGE);
			}else{
				self.showMyToast('error', result.MESSAGE);
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
			self.showMyToast('error', 'Unknown error in javascript controller/helper.');
		}
	},

    showMyToast : function(type, msg) {
		var mode = 'sticky';
		if(type.toLowerCase() == 'success') mode = 'dismissible';
		
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 5000,
            mode: mode,
            message: msg
        });
        toastEvent.fire();
	},

	refresh : function(){
		$A.get('e.force:refreshView').fire();
	},

	closeModal : function(){
		$A.get("e.force:closeQuickAction").fire();
	}
})