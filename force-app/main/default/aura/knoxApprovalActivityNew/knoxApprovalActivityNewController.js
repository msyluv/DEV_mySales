({
	init : function(component, event, helper) {
		helper.init(component, event);
	}, 

	selectPreviewTab : function(component, event, helper) {
		console.log('selectPreviewTab' );
		$A.get('e.c:knoxApprovalPreviewReplaceEvent').fire();
	},

	selectApprovalTab : function(component, event, helper) {
		component.set('v.isSelectedApprovalTab', true);
	}
})