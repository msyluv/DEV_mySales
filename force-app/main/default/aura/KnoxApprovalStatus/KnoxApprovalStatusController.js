({
    init : function(component, event, helper) {
        var isRefreshed = component.get('v.isRefreshed');
        console.log('isRefreshed', isRefreshed);
        if(isRefreshed == false) {
            helper.initCompoent(component, event);
        }
    },

    callKnoxApprovalStatus : function(component, event, helper) {
        helper.callKnoxApprovalStatus(component, event);        
    }
})