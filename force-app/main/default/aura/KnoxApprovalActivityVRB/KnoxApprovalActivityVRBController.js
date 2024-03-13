({
    init : function(component, event, helper) {
        console.log('레코드ID');
        console.log('recordId : ', component.get('v.recordId'));
        
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        console.log(userId);
        
        var action = component.get("c.getStrategyInfo");

        action.setParams({
			recordId : component.get('v.recordId')
        })
        
        action.setCallback(this,function(response){
			var state = response.getState();
			if(state === "SUCCESS"){
                var data = response.getReturnValue();
                if(data.length > 0){
                    
                    console.log(data[0].CreatedById != userId);
                    if(data[0].CreatedById != userId){
                        console.log('Validation : Not Strategy Committee Manager.');
                        helper.showMyToast('warning', $A.get('$Label.c.APPR_MSG_0032')); //수전위 담당자만 결제를 진행할 수 있습니다.
                        $A.get("e.force:closeQuickAction").fire();
                        return;
                    }
                    
                    if(data[0].TotalQuestionCount__c != data[0].IsPMAnswerCount__c || data[0].TotalQuestionCount__c != data[0].IsAnswerCount__c){
                        console.log('Validation : CheckList is Not Complete.');
                        helper.showMyToast('warning', $A.get('$Label.c.APPR_MSG_0024')); //아직 답변이 완료되지 않았습니다. 답변 완료 후 결제바랍니다.
                        $A.get("e.force:closeQuickAction").fire();
                        console.log('data2');
                        return;
                    }
                    if(data[0].Decision__c == null){
                        console.log('Validation : must select a decision field prior to submission.');
                        helper.showMyToast('warning', $A.get('$Label.c.APPR_MSG_0025')); //제출 전에 결정 필드를 선택해야 합니다.
                        $A.get("e.force:closeQuickAction").fire();
                        return;
                    }
                }
			}  	
			else if (state === "INCOMPLETE") {
			}
			else if (state === "ERROR") {
                var errors = response.getError();
                console.log(errors);
			}			 
        });
        $A.enqueueAction(action);

    }
})