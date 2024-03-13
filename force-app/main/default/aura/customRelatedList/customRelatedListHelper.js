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
    getRecords : function(component) {
        var recordId = component.get("v.recordId");
        console.log("Related Record ID: "+recordId);
        var action = component.get("c.getRelatedRecords");
        action.setParams({ recordId : recordId });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                result.forEach(function(result){
                    result.linkName = '/'+result.Id;
                });
                component.set("v.relatedRecords", result);
                if(result.length > 0) {
                    component.set("v.isRelatedRecords", true);
                }
                else {
                    component.set("v.isRelatedRecords", false);
                }
            }
        });
        $A.enqueueAction(action);
    },

    removeRecord: function(component) {
        var rows = component.get("v.relatedRecords");
        var rowId = component.get("v.rowId");
        var rowIndex = component.get("v.rowIndex");

        var action = component.get("c.deleteMSPRecord");
        action.setParams({ recordId : rowId });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
            }
        });
        $A.enqueueAction(action);

        rows.splice(rowIndex, 1);
        if(rows.length == 0) {
            component.set("v.isRelatedRecords", false);
        }
        component.set("v.relatedRecords", rows);
        component.set("v.confirmationModal", false);
    },

    editRecord: function(component, id) {
        var action = component.get("c.checkApprovalStatus");
        action.setParams({ recordId : id });
        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            console.log("Record is locked: "+response.getReturnValue());
            if(state == "SUCCESS" && result) {
                component.set("v.isRecordLocked", result);
            }
        });
        $A.enqueueAction(action);
        var action = component.get("c.getMSPRecord");
        action.setParams({ recordId : id });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state == "SUCCESS") {
                var result = response.getReturnValue()[0];
                console.log(result);
                component.set("v.isModalOpen", true);
                component.set("v.formLabel", "Edit SCP Project");
                component.set("v.currentRecord", id);
                component.set("v.Project_ID", result.Name);
                component.set("v.Project_Name", result.Project_Name__c);
                component.set("v.Project_Summary", result.Project_Summary__c);
                component.set("v.Monthly_Fee", result.Estimated_Monthly_Fee_Won__c);
                component.set("v.New_Business", result.New_Business__c);
                component.set("v.Partner_AM", result.Partner_AM__c);
                component.set("v.Partner_PM", result.Partner_PM__c);
            }
        });
        $A.enqueueAction(action);
    },

    showDeleteModal: function(component, row) {
        component.set("v.confirmationModal", true);

        component.set("v.rowId", row.Id);

        var rows = component.get("v.relatedRecords");
        var rowIndex = rows.indexOf(row);
        component.set("v.rowIndex", rowIndex);
        console.log(rowIndex);
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