({
    doInit : function(component, event, helper) {
        var action = component.get('c.getStageVal');
        
        action.setParams({
            recordId : component.get('v.recordId')
        })

        action.setCallback(this, function(response){
            var state = response.getState();
            var data = response.getReturnValue();
            console.log(state);
            console.log(data);
            if (state === "SUCCESS") {
                component.set('v.stageName', data.picVal);
                var currentStage = data.SalesLead[0].LeadStage__c;
                console.log(currentStage);
                var noneConvert = component.find('noneConvert');
                var Convert = component.find('Convert');
                if(currentStage == 'Converted'){
                    $A.util.addClass(noneConvert, 'nonedisplay');

                    $A.util.removeClass(Convert, 'nonedisplay');
                } else {
                    $A.util.removeClass(noneConvert, 'nonedisplay');

                    $A.util.addClass(Convert, 'nonedisplay');
                }
            } else if (state === "INCOMPLETE") {

            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log(errors);
            }
        });
        $A.enqueueAction(action);
    }
})