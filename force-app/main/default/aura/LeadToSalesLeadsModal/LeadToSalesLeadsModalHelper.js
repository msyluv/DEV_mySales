/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-10-18
 * @last modified by  : younghoon.kim@dkbmc.com
**/
({
    convertCheck : function(component, event){
        var close =  $A.get("e.force:closeQuickAction");
        var self = this;
        self.apex(component, 'leadCheck', {
            recordId : component.get('v.recordId')
        })
        .then(function(result){
            component.set('v.isAdmin', result.isAdmin);
            if(result.isConverted){
                self.showMyToast('warning', $A.get("$Label.c.CONVERT_LAB_MSG05")); // Sales Leads have already been created.
                close.fire();
            }else if(result.isClosed){
                self.showMyToast('warning', $A.get("$Label.c.CONVERT_LAB_MSG20")); // Closed marketing leads cannot be converted.
                close.fire();
            }else if(!result.isConvertTarget){
                self.showMyToast('warning', $A.get("$Label.c.CONVERT_LAB_MSG18")); // You can convert to Sales Lead only if your Lead Type is Business or Technical Support.
                close.fire();
            }else{
                self.getData(component, event);
            }
        })
        .catch(function(errors){
            self.errorHandler(errors);
            close.fire();
        }).finally(function(){
            
        });
    },

    getData : function(component, event){
        var self = this;
        self.apex(component, 'getFieldLabel', {
            recordId : component.get('v.recordId')
        })
        .then(function(result){
            window.console.log('result : ', result);
            window.console.log('result.Lead : ', JSON.parse(result.Lead));
            window.console.log('result.SalesLead : ', JSON.parse(result.SalesLead));
            var lList = [],
                slList = [];
            var lead = JSON.parse(result.Lead),
                salesLead = JSON.parse(result.SalesLead);

            for(var l in lead){
                lList.push({value:lead[l], key:l});
            }
            component.set('v.lList', lList.reverse());

            for(var sl in salesLead){
                slList.push({value:salesLead[sl], key:sl});
            }
            component.set('v.slList', slList.reverse());

            component.set('v.showSpinner', false);
        })
        .catch(function(errors){
            self.errorHandler(errors);
        }).finally(function(){
            
        });
    },

    /*
    getData : function(component, event){
        var self = this;
        self.apex(component, 'getFieldLabel', {
            recordId : component.get('v.recordId')
        })
        .then(function(result){
            component.set('v.LeadList', result.lflist);
            component.set('v.showSpinner', false);
        })
        .catch(function(errors){
            self.errorHandler(errors);
        }).finally(function(){
            
        });
    },
    */

    convert : function(component, event){
        component.set('v.showSpinner', true);
        var self = this;
        self.apex(component, 'convertLead', {
            LeadId : component.get('v.recordId'),
            OwnerId : component.get('v.selectedOwner')
        })
        .then(function(result){
            if(result != ''){
                self.showMyToast('Success', $A.get("$Label.c.CONVERT_LAB_MSG09"));
                var url = '/'+ result;
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": url
                });
                urlEvent.fire();
            } else {
                self.showMyToast('Warning', $A.get("$Label.c.CONVERT_LAB_MSG08"));
            }
        })
        .catch(function(errors){
            self.errorHandler(errors);
        }).finally(function(){
            // component.set('v.showSpinner', false);
        });
    },
    
    getRecordType : function(component, event, ProfileId){
        var self = this;
        self.apex(component, 'getRecordType', {
            profileId : ProfileId
        })
        .then(function(result){
            component.set('v.recordType', result);
        })
        .catch(function(errors){
            self.errorHandler(errors);
        }).finally(function(){
            
        });
    },

    apex : function(component, apexAction, params){
        return new Promise($A.getCallback(function(resolve, reject){
            var action = component.get("c."+apexAction+"");
            action.setParams(params);
            action.setCallback(this, function(callbackResult){
                if(callbackResult.getState()=='SUCCESS'){
                    resolve(callbackResult.getReturnValue());
                }
                if(callbackResult.getState()=='ERROR'){
                    console.log('ERROR', callbackResult.getError()); 
                    reject(callbackResult.getError());
                }
            });
            $A.enqueueAction(action);
        }));
    },

	errorHandler : function(errors){
		var self = this;
		if(Array.isArray(errors)){
			errors.forEach(function(err){
				self.showMyToast('error', err.message);
			});
		}else{
			self.showMyToast('error', 'Unknown error in javascript controller/helper.');
		}
	},

    showMyToast : function(type, msg){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type : type,
            duration : 10000,
            mode : 'sticky',
            message : msg
        });
        toastEvent.fire();
	},
})