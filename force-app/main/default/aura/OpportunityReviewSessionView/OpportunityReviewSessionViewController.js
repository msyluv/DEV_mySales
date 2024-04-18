({
    doInit: function(component, event, helper) {
        helper.getReviewSession(component, event, helper);
        helper.getReviewTargetList(component, event, helper);
        /*var opMap = new Map();
        var opList = [];
        component.set('v.SelectedOpportunityMap', opMap);
        component.set("v.targetOpportunity", opList);*/
    } 
})