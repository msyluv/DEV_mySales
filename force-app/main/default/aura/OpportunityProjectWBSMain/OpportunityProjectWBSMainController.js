/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2020-12-22
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2020-12-07   seonju.jin@dkbmc.com   Initial Version
**/
({
	init : function(component, event, helper) {
		console.log('OpportunityProjrctWBSMainController init Start');
        
        //Id, Name, ProjectCode__c, ProjectType__c, Description__c, Opportunity__c
		component.set('v.project_columns', [
            {label: 'Name'			, fieldName: 'Name'				, type: 'text'},
			{label: 'Code'			, fieldName: 'ProjectCode__c'	, type: 'text'},
			{label: 'Type'			, fieldName: 'ProjectType__c'	, type: 'text'},
			{label: 'Description'	, fieldName: 'Description__c'	, type: 'text'}
		]);
         
        //Id, Name, OpportunityID__c, ItemNumber__c, ProjectCodeOutput__c, ProjectCode__c, ServiceCode__c, SolutionCode__c, WBSCode__c 
        component.set('v.wbs_columns', [
			{label: 'Name'				, fieldName: 'Name'					, type: 'text' },
            {label: 'ItemNumber'		, fieldName: 'ItemNumber__c'		, type: 'text' },
            {label: 'ProjectCode'		, fieldName: 'ProjectCode__c'		, type: 'text' },
            {label: 'ProjectCodeOutput'	, fieldName: 'ProjectCodeOutput__c'	, type: 'text' },
            {label: 'ServiceCode'		, fieldName: 'ServiceCode__c'		, type: 'text' },
            {label: 'SolutionCode'		, fieldName: 'SolutionCode__c'		, type: 'text' }
        ]);
		helper.helperinit(component, event);
	},
    
    onRowSelect: function(component, event, helper){
        helper.onRowSelect(component, event);
    },
    
    handleTreeSelect: function(component, event, helper){
        event.preventDefault();
        var name = event.getParam('name');
        var mappingItem = component.get('v.mappingItem')[name];
        if(mappingItem != null && mappingItem != undefined){
        	component.set('v.selectedRows',mappingItem.Id);
        	helper.getWBS(component, mappingItem.Id);    
        }
		
    },

	cancel : function(component, event, helper){
		component.find("overlayLib").notifyClose();
    },
    
    onRefresh: function(Component, event, helper){
        helper.helperinit(Component, event);
    }
})