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
    getReviewSession: function(component, event, helper){
        var opid = component.get('v.recordId');
        var action =  component.get('c.getExistingReviewSession');
        action.setParams({recordId : opid});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.reivewSession",response.getReturnValue());
                component.set("v.userTimeZone", $A.get("$Locale.timezone"));
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
                
                var resultData = response.getReturnValue();
                let oppMap = new Map();
                for(var i=0 ; i <resultData.opportunityList.length; i++){
                    resultData.opportunityList[i].Permission = resultData.opptyPermissionMap[resultData.opportunityList[i].Id];
                    resultData.opportunityList[i].Checked = resultData.opptyCheckedMap[resultData.opportunityList[i].Id];
                    resultData.opportunityList[i].Amount = resultData.opportunityList[i].Amount.toLocaleString(undefined, {minimumFractionDigits: 2});
                    oppMap.set(resultData.opportunityList[i].Id,resultData.opportunityList[i]);
                }
                var Selectopp = resultData.opportunityList;
                Selectopp.sort((x,y)=> y.Checked - x.Checked);
                component.set("v.SelectedOpportunityMap", oppMap);
                component.set("v.targetOpportunity", resultData.opportunityList);
            }
        });
        $A.enqueueAction(action);
        
    },
})