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
	init : function(component, event, helper) {
        let params = new URLSearchParams(document.location.search);
        let salesLeadId = params.get("c__id");
        component.set('v.SalesLeadId', salesLeadId);
        
        helper.checkOwner(component, event);
		var AccessLevel = component.get('v.AccessLevel');
		AccessLevel.push({ 'label' : $A.get( "$Label.c.SLTM_LAB_READ"), 'value' : 'Read' });
		AccessLevel.push({ 'label' : $A.get( "$Label.c.SLTM_LAB_READWRITE"), 'value' : 'Edit' });
        
        var TeamRole = component.get('v.TeamRole');
        TeamRole.push({ 'label' : 'Proposal PM', 'value' : 'Proposal PM' });
        TeamRole.push({ 'label' : 'Sales Rep', 'value' : 'Sales Rep' });
        TeamRole.push({ 'label' : 'Sales Manager', 'value' : 'Sales Manager' });
        TeamRole.push({ 'label' : 'Account Manager', 'value' : 'Account Manager' });
        TeamRole.push({ 'label' : 'Channel Manager', 'value' : 'Channel Manager' });
        TeamRole.push({ 'label' : 'Executive Sponsor', 'value' : 'Executive Sponsor' });
		TeamRole.push({ 'label' : 'Lead Qualifier', 'value' : 'Lead Qualifier' });
		TeamRole.push({ 'label' : 'Pre-Sales Consultant', 'value' : 'Pre-Sales Consultant' });
		TeamRole.push({ 'label' : 'Strategy Committee Officer', 'value' : 'Strategy Committee Officer' });
		TeamRole.push({ 'label' : 'Strategy Committee Member', 'value' : 'Strategy Committee Member' });
        
        var sltmList = component.get('v.sltmList');
        sltmList.push({'TeamRole': '','User': {},'AccessLevel': 'Read'},
                      {'TeamRole': '','User': {},'AccessLevel': 'Read'},
                      {'TeamRole': '','User': {},'AccessLevel': 'Read'});
        component.set("v.sltmList", sltmList);
		
	},

	add : function(component, event, helper) {
		helper.addRow(component, event);
	},

	remove : function(component, event, helper) {
        var target = event.target;
		var rowIndex = target.getAttribute("data-idx");

        var sltmList = component.get("v.sltmList");
        // setTimeout(() => {
            sltmList.splice(rowIndex, 1);
            component.set("v.sltmList", sltmList);
        // }, 10); 
	},
	
	saveTM : function(component, event, helper) {
		helper.saveSLTM(component, event);
        window.location.replace('/lightning/r/Sales_Lead__c/'+salesLeadId+'/related/Sales_Lead_Team__r/view');
	},

	cancel : function(component, event, helper) {
		//window.location.replace('/lightning/r/Sales_Lead__c/'+salesLeadId+'/related/Sales_Lead_Team__r/view');
        //setTimeout(() => {window.history.back();}, "1000");
        //window.location.reload();
        //window.history.back();
        window.history.go(-1);
    },
})