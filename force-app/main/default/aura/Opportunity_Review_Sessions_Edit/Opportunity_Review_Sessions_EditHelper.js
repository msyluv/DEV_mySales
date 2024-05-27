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
    init : function(component, event) {
        var x = component.get("v.recordId");
        var action = component.get('c.getExistingReviewSession');
        action.setParams({
            'recordId': x //component.get("v.targetOpportunity")
        });
        var resultValue;
        action.setCallback(this, function(response){
            var state = response.getState();   
            if(state == "SUCCESS"){
                var listviews = response.getReturnValue();
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
        var x = component.get("v.recordId");
        var targetBoList = [];
        var selectedopp = component.get("v.targetOpportunity");
        for(var i=0 ; i <selectedopp.length; i++){
            targetBoList.push({BoId : selectedopp[i].Id,Checked : selectedopp[i].Checked});
        }
        if(component.find('selectName').get('v.value') && component.find('selectDate').get('v.value')){
            var action = component.get('c.updateOpportunityReviewSessionRecord');
            action.setParams({
                'sessionName': component.find('selectName').get('v.value'),
                'sessionDate' : component.find('selectDate').get('v.value'),
                'Note' : component.find('getNote').get('v.value'),
                'sessionResult' : component.find('getSessionResult').get('v.value'),
                'BotargetList': JSON.stringify(targetBoList),
                'recordId': x
            });
            var resultValue;
            action.setCallback(this, function(response){
                var state = response.getState();   
                if(state == "SUCCESS"){
                    this.showMyToast('SUCCESS',$A.get("$Label.c.Updated_Message_Reciew_Session"));
                    this.redirectToList(component, event);
                }
                else{
                    this.showMyToast('error', 'Error');
                }
            });
            $A.enqueueAction(action);
            
        }else{
            this.showMyToast('error', $A.get("$Label.c.Required_Message_Review_session"));
        }
        
    },
    redirectToList :  function(component, event) {
        var sessionRecordId = component.get("v.recordId");
        var navEvent = $A.get("e.force:navigateToSObject");
        navEvent.setParams({
            "recordId": sessionRecordId,
            "slideDevName": "detail"
        });
        navEvent.fire();
    },
    getReviewSession: function(component, event, helper){
        var opid = component.get('v.recordId');
        var action =  component.get('c.getExistingReviewSession');
        action.setParams({recordId : opid});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
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
            if(state == "SUCCESS"){
                var resultData = response.getReturnValue();
                let oppMap = new Map();
                for(var i=0 ; i <resultData.opportunityList.length; i++){
                    resultData.opportunityList[i].Permission = resultData.opptyPermissionMap[resultData.opportunityList[i].Id];
                    resultData.opportunityList[i].Checked = resultData.opptyCheckedMap[resultData.opportunityList[i].Id];
                    resultData.opportunityList[i].Amount = resultData.opportunityList[i].Amount.toLocaleString(undefined, {minimumFractionDigits: 2});
                    oppMap.set(resultData.opportunityList[i].Id,resultData.opportunityList[i]);
                }
                component.set("v.SelectedOpportunityMap", oppMap);
                var Selectopp = resultData.opportunityList;
                Selectopp.sort((x,y)=> y.Checked - x.Checked);
                component.set("v.targetOpportunity", resultData.opportunityList);
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
    
})