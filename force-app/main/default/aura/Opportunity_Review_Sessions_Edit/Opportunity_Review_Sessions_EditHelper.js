({
    init : function(component, event) {
      var x = component.get("v.recordId");
        console.log('akash0' + x);
        
        var action = component.get('c.getExistingReviewSession');
            action.setParams({
                'recordId': x //component.get("v.targetOpportunity")
            });
            var resultValue;
            action.setCallback(this, function(response){
                var state = response.getState();   
                console.log('akash testing' + state);
                if(state == "SUCCESS"){
                    var listviews = response.getReturnValue();
                    console.log('Akash2' + listviews.Name);
                   component.set('v.name',listviews.Name);
                    component.set('v.date1',listviews.Session_Date__c);
                }
                else{
                    this.showMyToast('error', 'Error');
                }
            });
            $A.enqueueAction(action);
        
    },
    onSave :  function(component, event){
        console.log('hello');
        
       var action = component.get('c.createOpportunityReviewSessionRecord');
            action.setParams({
                'sessionName': component.find('selectName').get('v.value'),
                'sessionDate' : component.find('selectDate').get('v.value'),
                'Note' : component.find('getNote').get('v.value'),
                'sessionResult' : component.find('getSessionResult').get('v.value'),
                'BotargetList': JSON.stringify(targetBoList) //component.get("v.targetOpportunity")
            });
            var resultValue;
            action.setCallback(this, function(response){
                var state = response.getState();   
                console.log('akash testing' + state);
                if(state == "SUCCESS"){
                    this.showMyToast('SUCCESS', 'Records has been created');
                    this.redirectToList(component, event);
                }
                else{
                    this.showMyToast('error', 'Error');
                }
            });
            $A.enqueueAction(action);
    },
        
})