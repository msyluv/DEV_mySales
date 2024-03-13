/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2022-08-09
 * @last modified by  : akash.g@samsung.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   30-09-2021   younghoon.kim@dkbmc.com   Initial Version
 * 1.1   2022-08-09   akash.g@samsung.com     Add new condition when converting sales lead to opportunity in case of lead channel is demand i.e. can convert when Sales Lead Type is  System Enhancement, New System ,Solution/Service, Consulting.
**/
({
    convertCheck : function(component, event){
        var close =  $A.get("e.force:closeQuickAction");
        var self = this;
        self.apex(component, 'isConverted', {
            recordId : component.get('v.recordId')
        })
        .then(function(result){
            var message = '';
            if(result.check_Convert) message += $A.get("$Label.c.CONVERT_LAB_MSG05") + '\n'; // Sales Lead has already been converted.
            if(result.check_Warm) message += $A.get("$Label.c.CONVERT_LAB_MSG06") + '\n'; // The stage of the sales lead is not Hot. Check the BANT information (can be converted if more than 2 items are checked.)
            if(result.check_Account) message += $A.get("$Label.c.CONVERT_LAB_MSG10") + '\n'; // Account field is empty.
            if(result.check_MDG) message += $A.get("$Label.c.CONVERT_LAB_MSG12") + '\n'; // This Account is Not MDG
            if(result.check_Amount) message += $A.get("$Label.c.CONVERT_LAB_MSG02") + '\n'; // Amount field is empty.
            if(result.check_CloseDate) message += $A.get("$Label.c.CONVERT_LAB_MSG01") + '\n'; // Expected Contract Date field is empty.
            // if(result.check_RevenueStartDate) message += $A.get("$Label.c.CONVERT_LAB_MSG14") + '\n'; // Contract Start Date field is empty.
            // f(result.check_RevenueEndDate) message += $A.get("$Label.c.CONVERT_LAB_MSG13") + '\n'; // Contract End Date End Date field is empty.
            // if(result.check_Type) message += $A.get("$Label.c.CONVERT_LAB_MSG15") + '\n'; // Sales Lead Type field is empty.
            if(result.check_SalesDepartment) message += $A.get("$Label.c.CONVERT_LAB_MSG16") + '\n'; // Sales Dept. (Lv.3) field is empty.
            // if(result.check_SalesOrganization) message += $A.get("$Label.c.CONVERT_LAB_MSG17") + '\n'; // Sales Dept. (Lv.2) field is empty.
            if(result.check_LeadType) message += $A.get("$Label.c.CONVERT_LAB_MSG19") + '\n'; // If channel type is not Demand then you can convert to Opportunity only if your Sales Lead Type is Business or Technology.
            //V1.1 ->  Add new condition when converting sales lead to opportunity in case of lead channel is demand
            if(result.check_LeadTypeDemand) message += $A.get("$Label.c.CONVERT_LAB_MSG29") + '\n'; //If channel type is Demand then you can convert to Opportunity only if your Sales Lead Type is System Enhancement ,New System , Solution/Service or Consulting.
            if(result.check_Close) message += $A.get("$Label.c.CONVERT_LAB_MSG23") + '\n'; // Closed sales leads cannot be converted.
            if(result.check_Contact) message += $A.get("$Label.c.CONVERT_LAB_MSG26") + '\n'; // Please enter your Customer Contact Date. You cannot enter a date later than the current one.
            
            if(message != ''){
                self.showMyToast('warning', message);
                close.fire();
            }else{
                self.doinit(component, event, helper);
            }
        })
        .catch(function(errors){
            self.errorHandler(errors);
        }).finally(function(){
            
        });
    },

    doinit : function(component, event, helper) {
        var close =  $A.get("e.force:closeQuickAction");
        var self = this;
        self.apex(component, 'getOppLabel', {
            recordId : component.get('v.recordId')
        })
        .then(function(result){
            var sflist = result.sflist;
            var rtlist = result.rtlist;
            
            for(var i = 0; i < sflist.length; i++){
                if(sflist[i].disabled == 'false'){
                    sflist[i].disabled = false
                } else if (sflist[i].disabled == 'true'){
                    sflist[i].disabled = true
                }
                
                if(sflist[i].sfApi == 'Name' || sflist[i].sfApi == 'Amount__c' || sflist[i].sfApi == 'CloseDate__c'){
                    sflist[i].sfRequired = true;
                } else {
                    sflist[i].sfRequired = false;
                }
            }
            
            var RecordTypeList = [];
            for(var i = 0; i < rtlist.length; i++){
                RecordTypeList.push({
                    label : rtlist[i].Name,
                    value : rtlist[i].Id
                })
                if(rtlist[i].DeveloperName == 'HQ') component.set('v.HQ', rtlist[i].Id);
            }
            component.set('v.SelectRT', rtlist[0].Id);
            component.set('v.RTList', RecordTypeList);
            component.set('v.SalesLeadList', sflist);
            component.set('v.showSpinner', false);
        })
        .catch(function(errors){
            self.errorHandler(errors);
        }).finally(function(){
            
        });
    },

    convert : function(component, event, oppList){
        component.set('v.showSpinner', true);
		var close =  $A.get("e.force:closeQuickAction");
        var self = this;
        self.apex(component, 'convertOpp', {
            recordId : component.get('v.recordId'),
            opplist : oppList
        })
        .then(function(result){
            if(result.isSuccess == "SUCCESS"){
                //alert('123');
                self.showMyToast('success',$A.get("$Label.c.CONVERT_LAB_MSG04")); //
                var url = '/'+ result.oppId;
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": url
                });
                urlEvent.fire();
            }else if(result.isSuccess == "ERROR"){
                self.showMyToast('error', result.errorMsg);
                close.fire();
            } else if (result.isSuccess == "WARNNING"){
                self.showMyToast('warning', result.errorMsg);
                close.fire();
            }
        })
        .catch(function(errors){
            self.errorHandler(errors);
        }).finally(function(){
            component.set('v.showSpinner', false);
        });
    },

    getRecordType : function(component, event, helper, ProfileId, OwnerId){
        var self = this;
        self.apex(component, 'getRecordType', {
            profileId : ProfileId,
            ownerId : OwnerId
        })
        .then(function(result){
            component.set('v.SelectRT', result.recordTypeId);
            var sflist = component.get('v.SalesLeadList');

            for(var i=0; i<sflist.length; i++){
                if(sflist[i].oppApi == 'SalesDivision__c'){
                    sflist[i].oppValue = result.Division;
                }
                if(sflist[i].oppApi == 'SalesTeam__c'){
                    sflist[i].oppValue = result.Title;
                }
            }
            component.set('v.SalesLeadList', sflist);
        })
        .catch(function(errors){
            self.errorHandler(errors);
        }).finally(function(){
            
        });
    },

    showtoast : function(type, title, message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : type,
            "title": title,
            "mode" : 'sticky',
            "duration": 5000,
            "message": message
        });
        toastEvent.fire();
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
		} else {
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