/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-01-29
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-01-28   younghoon.kim@dkbmc.com   Initial Version
**/
({
	doInit : function(component, event, helper) {
		window.console.log('controller doInit');

		component.set('v.columns', [
			{label: $A.get( "$Label.c.EXINFO_LAB_INFOSOURCE"), fieldName: 'InfoSource', type: 'text'}, // Information source
			{label: $A.get( "$Label.c.EXINFO_LAB_KRNAME"), fieldName: 'NameKR', type: 'text'}, // Name(KR)
			{label: $A.get( "$Label.c.EXINFO_LAB_ENNAME"), fieldName: 'NameEN', type: 'text'}, // Name(EN)
			{label: $A.get( "$Label.c.EXINFO_LAB_CEONAME"), fieldName: 'CeoName', type: 'text'}, // CEOName
			{label: $A.get( "$Label.c.EXINFO_LAB_ADDRESS"), fieldName: 'Address', type: 'text'}, // Address
			// {label: $A.get( "$Label.c.EXINFO_LAB_PHONE"), fieldName: 'Phone', type: 'phone'}, // Phone
			{label: $A.get( "$Label.c.EXINFO_LAB_PHONE"), fieldName: 'Phone', type: 'text'}, // Phone
			// {label: $A.get( "$Label.c.EXINFO_LAB_FAX"), fieldName: 'Fax', type: 'phone'}, // Fax
			{label: $A.get( "$Label.c.EXINFO_LAB_FAX"), fieldName: 'Fax', type: 'text'}, // Fax
			// {label: $A.get( "$Label.c.EXINFO_LAB_WEBSITE"), fieldName: 'Website', type: 'url'} // Website
			{label: $A.get( "$Label.c.EXINFO_LAB_WEBSITE"), fieldName: 'Website', type: 'text'} // Website
		]);

		helper.helperInit(component, event);
	},

	columnSelect : function(component, event, helper) {
		var selectedRow = event.getParam('selectedRows');
		window.console.log('selectedRow : ', selectedRow);
		component.set('v.selectedColumn', selectedRow[0]);
	},

	cancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

	save : function(component, event, helper) {
		window.console.log('controller save');

		window.console.log('selectedColumn', component.get('v.selectedColumn').InfoSource);

		if(component.get('v.selectedColumn').InfoSource == undefined){
			helper.showMyToast('error', $A.get( "$Label.c.EXINFO_MSG_0001")); // Please select a column.
		}else{
			helper.saveExInfo(component, event);
		}
	}
})