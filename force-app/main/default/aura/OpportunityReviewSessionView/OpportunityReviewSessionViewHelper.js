({
    getReviewSession: function(component, event, helper){
    var opid = component.get('v.recordId');
        var action =  component.get('c.getExistingReviewSession');
        action.setParams({recordId : opid});
        action.setCallback(this, function(response){
           var state = response.getState();
            if(state === "SUCCESS"){
            //    alert('SUCCESS'+response.getReturnValue());
            //    alert('SUCCESS'+response.getReturnValue().Name);
                component.set("v.reivewSession",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
	},
	getReviewTargetList: function(component, event, helper){
    var opid = component.get('v.recordId');
        var action =  component.get('c.getOpportunityReviewTarget');
        action.setParams({recordId : opid});
        action.setCallback(this, function(response){
           var state = response.getState();
            if(state === "SUCCESS"){
            //    alert('SUCCESS'+response.getReturnValue());
            //    alert('SUCCESS'+response.getReturnValue().Today_Review_Target__c);
                component.set("v.reviewTarget",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
	},
	showMyToast : function(type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 3000,
            mode: 'dismissible',
            message: msg
        });
        toastEvent.fire();
    },
    redirectToList :  function(component, event) {
        console.log('Akash test 1');
        var action = component.get("c.getListViews");
        action.setCallback(this, function(response){
                          
        var state = response.getState();
            console.log('State='+ state);
        if(state === "SUCCESS"){
            console.log('Akash test 2');
            var listviews = response.getReturnValue();
            var navEvent = $A.get("e.force:navigateToList");
            navEvent.setParams({
                "listViewId": listviews.Id,
                "listViewName": null,
                "scope": "OpportunityReviewSession__c"
            });
            console.log('Akash test 3');
            navEvent.fire();
            console.log('Akash test 4');
        }
    });
    $A.enqueueAction(action);
        
    },
    onSave :  function(component, event){
        console.log('hello');
        var self = this;
        var targetBoList = [];
        var selectedopp = component.get("v.targetOpportunity");
        for(var i=0 ; i <selectedopp.length; i++){
            targetBoList.push({BoId : selectedopp[i].Id,Checked : selectedopp[i].Checked});
        }
        console.log('akash 00' + JSON.stringify(targetBoList));
        if(component.find('selectName').get('v.value') && component.find('selectDate').get('v.value')){
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
            
        }
        else{
            this.showMyToast('error', 'Please Fill all the required fields.');
        }
    },
})