/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2024-01-24
 * @last modified by  : vikrant.ks@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-02-05   younghoon.kim@dkbmc.com   Initial Version
 * 1.1   2024-01-16   vikrant.ks@samsung.com    Added Team Role and some validation(MySales-389)
**/
({
	getTeamMember : function(component, event) {
		var self = this;

		self.apex(component, 'defaultSetting', { }
		).then(function(result){
			if(JSON.parse(result.LIST).length > 0){
				component.set('v.sltmList', JSON.parse(result.LIST));
			}else{
				self.addRow(component, event);
			}
			component.set('v.ListViewId', result.URL);
		}).catch(function(errors){
			self.errorHandler(errors);
		}).finally(function(){
		});
	},

	addRow : function(component,event) {
        var sltmList = component.get('v.sltmList');
        sltmList.push({
            'TeamRole': '',//V1.1
            'User': {},
            'AccessLevel': ''
        });
        component.set("v.sltmList", sltmList);
	},
	
	saveSLTM : function(component,event) {
		var self = this;

		var sltmList = component.get('v.sltmList');
        const UserSet = new Set();
		if(sltmList.length > 0){
			for(var i = 0; i < sltmList.length; i++){
				if(sltmList[i].User.Id == undefined || sltmList[i].AccessLevel == '' || sltmList[i].TeamRole == ''){//V1.1
					self.showMyToast('error', 'sticky', $A.get( "$Label.c.SLTM_MSG_0002")); // Please enter a value
					return;
				}
                else{//V1.1 Strat
                    if(UserSet.has(sltmList[i].User.Id)){
                        self.showMyToast('error', 'sticky',$A.get( "$Label.c.SLTM_DuplicateUserError"));
                        return;
                    }else{
                        UserSet.add(sltmList[i].User.Id);
                    }
                }//V1.1 End
			}
		}

		self.apex(component, 'save', { 
			'jsonData' : JSON.stringify(sltmList)
		}).then(function(result){
			if(result.RESULT == 'E'){
				self.showMyToast('error', 'sticky', result.MSG);
			}else{
				self.showMyToast('success', 'dismissible', result.MSG);
				//self.goToListView(component, event);
			    window.history.go(-1);
			}
		}).catch(function(errors){
			self.errorHandler(errors);
		}).finally(function(){
		});
	},

	goToListView : function(component,event) {
		var navEvent = $A.get("e.force:navigateToList");
		navEvent.setParams({
			"listViewId": component.get('v.ListViewId'),
			"listViewName": null,
			"scope": "Sales_Lead__c"
		});
		navEvent.fire();
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
	
    showMyToast : function(type, mode, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type : type,
            duration : 5000,
            mode : mode,
            message : msg
        });
        toastEvent.fire();
	},

	errorHandler : function(errors){
		var self = this;
		if(Array.isArray(errors)){
			errors.forEach(function(err){
				self.showMyToast('error', 'dismissible', err.exceptionType + " : " + err.message);
			});
		} else {
			self.showMyToast('error', 'dismissible', 'Unknown error in javascript controller/helper.')
		}
	}
})