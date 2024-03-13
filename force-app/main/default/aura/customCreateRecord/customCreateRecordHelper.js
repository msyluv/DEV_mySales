/**
 * @description       : Create Custom Record (For SCP Account and MSP Project)
 * @author            : gitesh.s@samsung.com
 * @group             : 
 * @last modified on  : 18-11-2022
 * @last modified by  : gitesh.s@smsung.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   18-11-2022   gitesh.s@samsung.com   Initial Version
**/
({
    handleAutoFill : function(component, event) {
        let inputField = component.find("Partner");
        let value = event.getSource().get("v.value");
        var objectName = component.get("v.sObjectName");
        let errorMessage = component.find("messages");
        var spinner_SCP_Account = component.find("spinner_SCP_Account");
        var spinner_MSP_Project = component.find("spinner_MSP_Project");
        
        if(objectName == "SCP_Account__c") {
            var partner_check = component.get("c.getPartnerAccount");
            $A.util.removeClass(spinner_SCP_Account, "slds-hide");
            partner_check.setCallback(this, function(response){
                var state = response.getState();
                var result = response.getReturnValue();
                console.log(response.getReturnValue());
                if(state == "SUCCESS") {
                    component.set("v.checkPartner", result);
                    $A.util.addClass(spinner_SCP_Account, "slds-hide");
                }
            });
            $A.enqueueAction(partner_check);
            
            var action = component.get("c.getPartnershipInfo");
            if(value != '') {
                action.setParams({ recordId : value });
                partner_check.setParams({ recordId : value });
                action.setCallback(this, function(response){
                    $A.util.removeClass(spinner_SCP_Account, "slds-hide");
                    var isPartner = component.get("v.checkPartner");
                    var state = response.getState();
                    var result = response.getReturnValue();
                    if(state == "SUCCESS" && result != '' && isPartner == true) {
                        console.log(isPartner);
                        console.log(result);
                        component.set("v.SDS_PDM", result);
                        $A.util.removeClass(inputField, "error-message");
                        errorMessage.setError('');
                    }
                    else if(result == null && isPartner == true) {
                        $A.util.addClass(inputField, "error-message");
                        component.set("v.SDS_PDM", []);
                        errorMessage.setError($A.get("$Label.c.PARTNER_COM_ERROR_001"));
                    }
                    else if(isPartner == false) {
                        $A.util.addClass(inputField, "error-message");
                        component.set("v.SDS_PDM", []);
                        errorMessage.setError($A.get("$Label.c.PARTNER_COM_ERROR_002"));
                    }
                    $A.util.addClass(spinner_SCP_Account, "slds-hide");
                });
                $A.enqueueAction(action);
            }
            else {
                component.set("v.SDS_PDM", []);
                errorMessage.setError('');
                $A.util.addClass(spinner_SCP_Account, "slds-hide");
            }
        }
    },

    handleRelatedFields: function(component, event, id) {
        var spinner_MSP_Project = component.find("spinner_MSP_Project");

        var action = component.get("c.getSCPAccountInfo");
        $A.util.removeClass(spinner_MSP_Project, "slds-hide");
        action.setParams({ recordId : id });
        action.setCallback(this, function(response){
            var state = response.getState();   
            if(state == "SUCCESS"){
                var result = response.getReturnValue()[0];
                console.log(result);
                component.set("v.SCP_Account_ID", result.Id);
                component.set("v.Customer", result.Customer__c);
                component.set("v.Contract_Start_Date", result.Contract_Start_Date__c);
                component.set("v.SDS_AM_MSP", result.SDS_AM__c);
                component.set("v.SCP_Account_Name", result.Name);
                component.set("v.Partner", result.Partner__c);
                component.set("v.Incentive", result.Incentive__c);
                component.set("v.SDS_PDM_MSP", result.SDS_PDM__c);
                $A.util.addClass(spinner_MSP_Project, "slds-hide");
            }
        });
        $A.enqueueAction(action);
    },

    checkApprovalStatus: function(component, event) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.checkApprovalStatus");
        action.setParams({ recordId : recordId });
        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            console.log("Record is locked: "+response.getReturnValue());
            if(state == "SUCCESS" && result) {
                component.set("v.isRecordLocked", result);
            }
        });
        $A.enqueueAction(action);
    },

    getProfileInfo: function(component) {
        var action = component.get("c.getProfileInfo");
        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue().Name;
            console.log(result);
            if(state == "SUCCESS") {
                component.set("v.profileName", result);
            }
        });
        $A.enqueueAction(action);
    }
})