/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-05-13
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-05-13   younghoon.kim@dkbmc.com   Initial Version
**/
({
	init : function(component, event, helper) {
		var searchValue = {
			'OpportunityCode' : '',
			'ApprovalType' : ''
		};
		component.set('v.searchValue', searchValue);

		component.set('v.columns', [ 
			{label: $A.get( "$Label.c.APPRVIEWER_LAB_TYPE"), fieldName: 'Type', type: 'text'},
            {label: $A.get( "$Label.c.APPRVIEWER_LAB_NAME"), fieldName: 'Name', type: 'text'},
            {label: $A.get( "$Label.c.APPRVIEWER_LAB_DEPARTMENT"), fieldName: 'Dept', type: 'text'},
			{label: $A.get( "$Label.c.APPRVIEWER_LAB_EMAIL"), fieldName: 'EvMailAddr__c', type: 'text'}
        ]);
		
		helper.helperInit(component, event);
	},

	search : function(component, event, helper) {
		component.set('v.approvalHTML', '');
		component.set('v.approvalLine', []);
		helper.knoxSearch(component, event);
	}
})