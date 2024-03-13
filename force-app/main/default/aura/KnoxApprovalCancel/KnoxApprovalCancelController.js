({
    init : function(component, event, helper) {
		helper.doInit(component, event);
    },
    handleCancel : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
	},

	cancelSubmission : function(component, event, helper){
		var comments = component.get("v.CancelComment");
		console.log(' comments blank? ', helper.isStringBlank(comments));
		if(!helper.isStringBlank(comments)){
			console.log('[S] cancelApproval');
            helper.cancelApproval(component, event);
        } 
	},

	refreshView : function(component,event,helper) {
		console.log('refreshView');
		$A.get('e.force:refreshView').fire();
	}
})