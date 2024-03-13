({
    init : function(component, event, helper) {
        console.log(':::::QuestionOwnerView init:::::');
        component.set('v.isLoading', true);
        helper.doInit(component, event, helper);
    },
    
    reInit : function(component, event, helper) {
        console.log(':::::QuestionOwnerView reInit:::::');
        var init = component.get('c.init');
        $A.enqueueAction(init);
    }
 })