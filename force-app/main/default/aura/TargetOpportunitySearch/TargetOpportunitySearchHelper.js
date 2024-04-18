({
    doInit: function(component,event) {
        var action = component.get("c.defaultSetting");
        action.setParams({});
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set("v.status", resultData);
                component.set('v.selectedValue.Status', resultData[0].value);
            }
        });
        $A.enqueueAction(action);
    },
    
    getOpportunityList: function(component, pageNumber, pageSize,selectedValue) {
        if(selectedValue.BOName != '' || selectedValue.Status != '' || selectedValue.OpptyCode != '' || Object.keys(selectedValue.SalesDept).length != 0 || Object.keys(selectedValue.SalesDept).length != 0 || Object.keys(selectedValue.PrimarySalesDept).length != 0 ){
            component.set("v.showSpinner", true);
            var selectedopp = component.get("v.SelectedOpportunityMap");
            var action = component.get("c.getOpportunityData");
            action.setParams({
                "SelectedValue":JSON.stringify(selectedValue),
                "pageNumber": pageNumber,
                "pageSize": pageSize
                
            });
            action.setCallback(this, function(result) {
                var state = result.getState();
                if (component.isValid() && state === "SUCCESS"){
                    var resultData = result.getReturnValue();
                    
                    let oppMap = new Map();
                    for(var i=0 ; i <resultData.opportunityList.length; i++){
                        resultData.opportunityList[i].Permission = resultData.opptyPermissionMap[resultData.opportunityList[i].Id];
                        oppMap.set(resultData.opportunityList[i].Id,resultData.opportunityList[i]);
                        if(selectedopp.has(resultData.opportunityList[i].Id)){
                            resultData.opportunityList[i].Checked = true;
                        }else{
                            resultData.opportunityList[i].Checked = false;
                        }
                    }
                    component.set("v.OpportunityMap", oppMap);
                    component.set("v.OpportunityList", resultData.opportunityList);
                    component.set("v.PageNumber", resultData.pageNumber);
                    component.set("v.TotalRecords", resultData.totalRecords);
                    component.set("v.RecordStart", resultData.recordStart);
                    component.set("v.RecordEnd", resultData.recordEnd);
                    if(resultData.totalRecords != 0){
                        component.set("v.TotalPages", Math.ceil(resultData.totalRecords / pageSize));
                    }
                    if(resultData.totalRecords > 10){
                        component.set("v.showPageNumber", true);
                    }else{
                        component.set("v.showPageNumber", false);
                    }
                    component.set("v.showSpinner", false);
                }
            });
            $A.enqueueAction(action);
            
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type" : 'error',
                "message": $A.get( "$Label.c.TARGET_BOSEARCH_ERROR"),
                "duration": 2000
            });
            toastEvent.fire();
        }
        //var spinner = component.get("v.showSpinner");
        //if(spinner == true){component.set("v.showSpinner", false);}
    }
})