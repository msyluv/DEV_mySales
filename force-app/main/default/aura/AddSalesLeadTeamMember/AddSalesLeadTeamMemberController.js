/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2024-01-24
 * @last modified by  : vikrant.ks@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-02-05   younghoon.kim@dkbmc.com   Initial Version
 * 1.1   2024-01-16   vikrant.ks@samsung.com    Added Team Role(MySales-389)
**/
({
	init : function(component, event, helper) {
		var AccessLevel = component.get('v.AccessLevel');
		AccessLevel.push({ 'label' : $A.get( "$Label.c.SLTM_LAB_READ"), 'value' : 'Read' });
		AccessLevel.push({ 'label' : $A.get( "$Label.c.SLTM_LAB_READWRITE"), 'value' : 'Edit' });
        
        //V1.1 Start
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
		//V1.1 End
		
		helper.getTeamMember(component, event);
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
	},

	cancel : function(component, event, helper) {
		//helper.goToListView(component, event);
		window.history.go(-1);
    },
})