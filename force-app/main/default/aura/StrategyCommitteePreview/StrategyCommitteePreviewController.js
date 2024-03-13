({
    init : function(component, event, helper) {
        console.log(':::::QuestionPresenterView init:::::');
        var colunms = [
            {label: 'Classification 1', fieldName: 'Category1__c', type: 'text', initialWidth: 140, sortable: false, hideDefaultActions: true},
            {label: 'Classification 2', fieldName: 'Category2__c', type: 'text', sortable: false, hideDefaultActions: true},
            {label: 'Evaluation Department', fieldName: 'ReviewDivision__c', type: 'text', sortable: false, hideDefaultActions: true},
            {label: 'Score', fieldName: 'TotalScore__c', type: 'text', initialWidth: 80, sortable: false, hideDefaultActions: true},
            {label: 'Inspection result', fieldName: '', sortable: false, hideDefaultActions: true},
        ];
        component.set('v.columns',colunms);
        helper.getInit(component, event, helper);
    },

    reInit : function(component, event, helper) {
        console.log(':::::QuestionPresenterView reInit:::::');
        
        var init = component.get('c.init');
        $A.enqueueAction(init);
    }
})