/**
 * @description       : Custom Related List Component (SCP Account)
 * @author            : gitesh.s@samsung.com
 * @group             : 
 * @last modified on  : 20-12-2022
 * @last modified by  : gitesh.s@smsung.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   20-12-2022   gitesh.s@samsung.com   Initial Version
**/
({
    init : function(component, event, helper) {
        var recordId = component.get("v.recordId");
       
        var getObject = component.get("c.getObjectName");
        getObject.setParams({ recordId : recordId });
        getObject.setCallback(this, function(response){
            var state = response.getState();   
            if(state == "SUCCESS"){
                var result = response.getReturnValue();
                console.log(result);

                // Check Object Name
                if(result == "SCP_Account__c") {
                    component.set("v.isRender", true);
                }
                else {
                    component.set("v.isRender", false);
                }
            }
        });
        $A.enqueueAction(getObject);

        console.log(recordId);
        component.set("v.SCP_Account_ID", recordId);

        var action = component.get("c.getCurrentRecord");
        action.setParams({ recordId : recordId });
        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue()[0];
            if(state == "SUCCESS" && result != null) {
                console.log(result);
                component.set("v.Customer", result.Customer__c);
                component.set("v.Contract_Start_Date", result.Contract_Start_Date__c);
                component.set("v.SDS_AM_MSP", result.SDS_AM__c);
                component.set("v.SCP_Account_Name", result.Name);
                component.set("v.Partner", result.Partner__c);
                component.set("v.Incentive", result.Incentive__c);
                component.set("v.SDS_PDM_MSP", result.SDS_PDM__c);
            }
        });
        $A.enqueueAction(action);

        var actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ]

        component.set('v.columns', [
            { label: 'Project ID', fieldName: 'linkName',  type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'} },
            { label: 'Project Name', fieldName: 'Project_Name__c', type: 'text'},
            { label: 'Estimated Monthly Fee', fieldName: 'Estimated_Monthly_Fee_Won__c', type: 'currency', cellAttributes: { alignment: 'left' }},
            { label: 'New Business', fieldName: 'New_Business__c', type: 'text'},
            { label: 'Approve', fieldName: 'Approve__c', type: 'text'},
            { type: 'action', typeAttributes: { rowActions: actions } }
        ]);

        helper.getRecords(component);
        helper.getProfileInfo(component);
    },

    createRelatedRecord : function(component, event, helper) {
        component.set("v.isModalOpen", true);
        component.set("v.formLabel", "New SCP Project");
        component.set("v.currentRecord", "");
        component.set("v.Project_ID", "");
        component.set("v.Project_Name", "");
        component.set("v.Project_Summary", "");
        component.set("v.Monthly_Fee", "");
        component.set("v.New_Business", "N/A");
        component.set("v.Partner_AM", "");
        component.set("v.Partner_PM", "");
    },
    
    closeModel: function(component, event, helper) {
        component.set("v.isRecordLocked", false);
        component.set("v.isModalOpen", false);
    },

    closeConfirmationModal: function(component, event, helper) {
        component.set("v.confirmationModal", false);
        component.set("v.rowId", '');
        component.set("v.rowIndex", '');
    },

    navigateToRelatedList: function(component, event, helper) {
        var recordId = component.get("v.recordId");

        var navService = component.find("navService");        
        var pageReference = {
            "type": "standard__recordRelationshipPage",         
            "attributes": {              
                "recordId": recordId,
                "relationshipApiName": "MSP_Projects__r",
                "actionName": "view"        
            }        
        };
                
        component.set("v.pageReference", pageReference);
            
        var pageReference = component.get("v.pageReference");
        navService.navigate(pageReference);
    },

    handleSubmit: function(component, event, helper) {
        event.preventDefault();
        var isRecordLocked = component.get("v.isRecordLocked");
        var profileName = component.get("v.profileName");

        if(isRecordLocked && (profileName == "Partner Community Login Manager" || profileName == "Partner Community Member")) {
            let errorMessage = component.find("messages");
            errorMessage.setError("Record is locked, cannot make changes!");
        }
        else {
            var fields = event.getParam('fields');
            console.log(fields);
            component.find('MSP_ProjectEditForm').submit(fields);
        }
    },
    
    handleSuccess: function(component, event, helper) {
        var record = event.getParams().response;
        console.log(record.id);

        var navService = component.find("navService");        
        var pageReference = {
            "type": 'standard__recordPage',         
            "attributes": {              
                "recordId": record.id,
                "actionName": "view",               
                "objectApiName": "MSP_Project__c"         
            }        
        };
                
        component.set("v.pageReference", pageReference);
            
        var pageReference = component.get("v.pageReference");
        navService.navigate(pageReference);
    },

    handleRowAction: function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        var id = row.Id;

        switch (action.name) {
            case 'edit':
                helper.editRecord(component, id);
                break;
            case 'delete':
                helper.showDeleteModal(component, row);
                break;
        }
    },

    removeRecord: function(component, event, helper) {
        helper.removeRecord(component);
    }
})