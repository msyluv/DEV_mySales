/**
 * @description       : 
 * @author            : akash.g@samsung.com
 * @group             : 
 * @last modified on  : 2024-05-09
 * @last modified by  : akash.g@samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2024-05-09   akash.g@samsung.com              Initial Version(MYSALES -499)
**/
({
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
        var action = component.get("c.getListViews");
        action.setCallback(this, function(response){
            
            var state = response.getState();
            if(state === "SUCCESS"){
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "OpportunityReviewSession__c"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
    },
    redirectToViewRecord :  function(component, event) {
        var sessionRecordId = component.get("v.sessionRecordId");
        var navEvent = $A.get("e.force:navigateToSObject");
        navEvent.setParams({
            "recordId": sessionRecordId,
            "slideDevName": "detail"
        });
        navEvent.fire();
    },
    onSave :  function(component, event){
        var self = this;
        var targetBoList = [];
        var selectedopp = component.get("v.targetOpportunity");
        for(var i=0 ; i <selectedopp.length; i++){
            targetBoList.push({BoId : selectedopp[i].Id,Checked : selectedopp[i].Checked});
        }
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
                if(state == "SUCCESS"){
                    component.set("v.sessionRecordId", response.getReturnValue());
                    this.showMyToast('SUCCESS',  $A.get("$Label.c.Record_Success_Message"));
                    this.redirectToViewRecord(component, event);
                }
                else{
                    this.showMyToast('error', 'Error');
                }
            });
            $A.enqueueAction(action);
            
        }
        else{
            this.showMyToast('error', $A.get("$Label.c.Required_Message_Review_session"));
        }
    },
})