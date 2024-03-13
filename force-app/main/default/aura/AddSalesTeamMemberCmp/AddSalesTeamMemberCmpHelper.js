/**
 * @author            : vikrant.ks@samsung.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2024-01-24
 * @last modified by  : vikrant.ks@samsung.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2024-01-16   vikrant.ks@samsung.com   Initial Version(MySales-389)
**/
({
	checkOwner : function(component,event) {
        let salesLeadId = component.get('v.SalesLeadId');
        
        var action = component.get('c.CheckOwner');
        action.setParams({'salesLeadId' : salesLeadId});
        action.setCallback( this, function(callbackResult) {
            if(callbackResult.getState()=='SUCCESS') {
                
                if(callbackResult.getReturnValue() == 'PASS'){}
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error',
                        type : 'error',
                        message : callbackResult.getReturnValue()
                    });
                    toastEvent.fire();
                    setTimeout(() => {window.location.replace('/lightning/r/Sales_Lead__c/'+salesLeadId+'/related/Sales_Lead_Team__r/view');
                                }, "1500");
            		return;
                }
            }
            if(callbackResult.getState()=='ERROR') {
                setTimeout(() => {window.location.replace('/lightning/r/Sales_Lead__c/'+salesLeadId+'/related/Sales_Lead_Team__r/view');
                                }, "1500");
            	return;
            }
            
        });
        $A.enqueueAction( action );
        
	},
    
	addRow : function(component,event) {
        var sltmList = component.get('v.sltmList');
        sltmList.push({
            'TeamRole': '',
            'User': {},
            'AccessLevel': 'Read'
        });
        component.set("v.sltmList", sltmList);
	},
	
	saveSLTM : function(component,event) {
		var self = this;
        
        var newsltmList = [];
		var sltmList = component.get('v.sltmList');
		const UserSet = new Set();
        if(sltmList.length > 0){
			for(var i = 0; i < sltmList.length; i++){
				if(sltmList[i].User.Id != undefined && sltmList[i].AccessLevel != '' && sltmList[i].TeamRole != ''){
					if(UserSet.has(sltmList[i].User.Id)){
                        self.showMyToast('error', 'Error',$A.get( "$Label.c.SLTM_DuplicateUserError"));
                        return; 
                    }else{
                        UserSet.add(sltmList[i].User.Id);
                        newsltmList.push(sltmList[i]);
                    }
				}
			}
		}
      	let salesLeadId = component.get('v.SalesLeadId');
        if(newsltmList.length == 0){
            window.location.replace('/lightning/r/Sales_Lead__c/'+salesLeadId+'/related/Sales_Lead_Team__r/view');
        }else{
            self.apex(component, 'save', { 
                'jsonData' : JSON.stringify(newsltmList),
                'salesLeadId' : salesLeadId
            }).then(function(result){
                if(result.RESULT == 'E'){
                    self.showMyToast('error', 'Error', result.MSG);
                }else{
                    self.showMyToast('success', 'Success', result.MSG);             
                }
                setTimeout(() => {window.location.replace('/lightning/r/Sales_Lead__c/'+salesLeadId+'/related/Sales_Lead_Team__r/view');
                                }, "3000");
            }).catch(function(errors){
                self.errorHandler(errors);
                
            }).finally(function(){
            });
         }
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
	
    showMyToast : function(type, title, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            type : type,
            message : msg
        });
        toastEvent.fire();
	},

	errorHandler : function(errors){
		var self = this;
		if(Array.isArray(errors)){
			errors.forEach(function(err){
				self.showMyToast('error', 'Error', err.exceptionType + " : " + err.message);
			});
		} else {
			self.showMyToast('error', 'Error', 'Unknown error in javascript controller/helper.')
		}
        setTimeout(() => {window.history.back();}, "3000");
	}
})