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
    init : function(component, event, helper) {

        var objectName = component.get("v.sObjectName");
        var recordId = component.get("v.recordId");
        console.log(recordId);

        if(objectName == "SCP_Account__c") {
            component.set("v.SCP_AccountForm", true);
            component.set("v.MSP_ProjectForm", false);
            if(!recordId) {
                component.set("v.formLabel", "New SCP Account");
            }
            else {
                component.set("v.formLabel", "Edit SCP Account");
            }
        }
        else if(objectName == "MSP_Project__c") {
            component.set("v.MSP_ProjectForm", true);
            component.set("v.SCP_AccountForm", false);
            if(!recordId) {
                component.set("v.formLabel", "New SCP Project");
            }
            else {
                component.set("v.formLabel", "Edit SCP Project");
            }
        }
        
        var pageReference = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: objectName,
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }
        };
        helper.checkApprovalStatus(component);
        helper.getProfileInfo(component);
        component.set("v.pageReference", pageReference);
    },

    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false
        var currentUrl = window.location.href;
        var recordId = component.get("v.recordId");
        var objectName = component.get("v.sObjectName");
        if(currentUrl.includes(recordId)) {
            component.set("v.isModalOpen", false);
            var navService = component.find("navService");   
            var pageReference = {
                "type": 'standard__recordPage',         
                "attributes": {              
                    "recordId": recordId,
                    "actionName": "view",               
                    "objectApiName": objectName       
                }        
            };
                    
            component.set("v.pageReference", pageReference);
                
            var pageReference = component.get("v.pageReference");
            navService.navigate(pageReference);
        }
        else if(currentUrl.includes("relatedlist")) {
            var pathname = new URL(currentUrl).pathname.split('/');
            var id = pathname[pathname.length - 2];

            component.set("v.isModalOpen", false);
            component.set("v.isRelatedList", false);
            
            var navService = component.find("navService");
            var pageReference = {
                "type": "standard__recordRelationshipPage",         
                "attributes": {
                    "recordId": id,
                    "relationshipApiName": 'MSP_Projects__r',
                    "actionName": "view"        
                }        
            };

            component.set("v.pageReference", pageReference);
                
            var pageReference = component.get("v.pageReference");
            navService.navigate(pageReference);
        }
        else {
            component.set("v.isModalOpen", false);
            var navService = component.find("navService");
            // Uses the pageReference definition in the init handler
            var pageReference = component.get("v.pageReference");
            event.preventDefault();
            navService.navigate(pageReference);
        }
    },

    handleLoad: function (component, event, helper) {
        var recUi = event.getParam("recordUi");
        var objectName = component.get("v.sObjectName");
        var currentUrl = window.location.href;
        var pathname = new URL(currentUrl).pathname.split('/');
        var relatedFieldName = pathname[pathname.length - 1];
        if(objectName == "SCP_Account__c") {
            var SDS_PDM_value = recUi.record.fields["SDS_PDM__c"].value;
            component.set("v.SDS_PDM", SDS_PDM_value);
        }
        else if(relatedFieldName.includes("MSP_Projects__r")) {
            var id = pathname[pathname.length - 2];
            component.set("v.isRelatedList", true);
            helper.handleRelatedFields(component, event, id);
        }
    },

    handleSubmit: function(component, event, helper) {
        event.preventDefault();
        var isRecordLocked = component.get("v.isRecordLocked");
        var objectName = component.get("v.sObjectName");
        var profileName = component.get("v.profileName");

        if(isRecordLocked && objectName == "MSP_Project__c" && 
            (profileName == "Partner Community Login Manager" || profileName == "Partner Community Member")) {
            let errorMessage = component.find("messages");
            errorMessage.setError("Record is locked, cannot make changes!");
        }
        else {
            var fields = event.getParam('fields');
            let inputField = component.find("Partner");
            let errorMessage = component.find("messages");
            var isPartner = component.get("v.checkPartner");
            if(objectName == "SCP_Account__c") {
                if(isPartner == false) {
                    errorMessage.setError($A.get("$Label.c.PARTNER_COM_ERROR_003"));
                    $A.util.addClass(inputField, "error-message");
                }
                else {
                    component.find('SCP_AccountEditForm').submit(fields);
                }
            }
            else if(objectName == "MSP_Project__c") {
                component.find('MSP_ProjectEditForm').submit(fields);
            }
        }
    },
    
    handleSuccess: function(component, event, helper) {
        var record = event.getParams().response;
        var objectName = component.get("v.sObjectName");
        console.log(record.id);

        var navService = component.find("navService");        
        var pageReference = {
            "type": 'standard__recordPage',         
            "attributes": {
                "recordId": record.id,
                "actionName": "view",
                "objectApiName": objectName         
            }        
        };
                        
        component.set("v.pageReference", pageReference);
                    
        var pageReference = component.get("v.pageReference");
        window.setTimeout(
            $A.getCallback(function() {
                navService.navigate(pageReference);
            }), 600
        );
    },

    handleAutoFill: function(component, event, helper) {
        helper.handleAutoFill(component, event);
    }
})