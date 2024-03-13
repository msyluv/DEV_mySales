/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-07-28
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-06-15   younghoon.kim@dkbmc.com   Initial Version
**/
({
	doInit : function(component, event) {
		window.console.log('Helper doInit');

		var self = this;
        self.apex(component, 'defaultCheck', {

        })
        .then(function(result){
			window.console.log('result : ', result);
			if(!result.isMigUser){ // Migration User가 아닌 경우
				self.showMyToast('warning', '법인통합은 Migration User만 사용 가능합니다.');
				component.set('v.migUser', true);
			}

			if(result.isProceeding){ // 법인통합이 진행중인 경우
				self.showMyToast('warning', '법인통합이 진행중입니다.');
				component.set('v.batchSize', result.batchSize);
				component.set('v.message', '진행중인 법인통합이 있습니다. ' + result.batchSize + '%');
			}else{ // 법인통합이 진행중이지 않은 경우
				component.set('v.proceeding', false);
				component.set('v.message', '진행중인 법인통합이 없습니다.');
				component.set('v.ccmList', result.targetList);
			}
        })
        .catch(function(errors){
            self.errorHandler(errors);
        }).finally(function(){
            component.set('v.showSpinner', false);
        });
	},

	batchStart : function(component, event) {
		window.console.log('Helper batchStart');

		var self = this;
		var refresh =  $A.get('e.force:refreshView');

		if(component.get('v.ccmList').length > 0){
			self.apex(component, 'batchStart', {

			})
			.then(function(result){
				window.console.log('result : ', result);
			})
			.catch(function(errors){
				self.errorHandler(errors);
			}).finally(function(){
				component.set('v.showSpinner', false);
				refresh.fire();
			});
		}else{
			self.showMyToast('Error', '등록된 법인통합 데이터가 없습니다. CostCenterMerge__c 오브젝트에 데이터를 입력해주세요.');
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