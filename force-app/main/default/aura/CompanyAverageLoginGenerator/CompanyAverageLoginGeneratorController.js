/**
 * @description       : Company Average Login Generator
 * @author            : vikrant.ks@samsung.com
 * @group             : 
 * @last modified on  : 2023-09-22
 * @last modified by  : vikrant.ks@samsung.com 
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2023-09-22   vikrant.ks@samsung.com   Initial Version(MySales 303)
**/
({
    onRender : function(component, event, helper) {
		var dorender = component.get("v.doRender");
        if(dorender){
            component.set("v.doRender",false);
            var date = new Date();
            const monthArray = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
            document.getElementById('select-month').value=monthArray[date.getMonth()];
            document.getElementById('select-year').value = date.getFullYear();
        }
	},
     executeBatch : function (cmp){
        const monthArray = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        var options = document.getElementById('select-company').selectedOptions; 
        var companys = Array.from(options).map(({ value}) => value); 
        options = document.getElementById('select-profile').selectedOptions; 
        var profiles = Array.from(options).map(({ value}) => value);
                                                 
        var action = cmp.get("c.executeBatchJob");
        action.setParams({
                  "month"	  : monthArray.indexOf(document.getElementById('select-month').value)+1,
                  "year" 	  : document.getElementById('select-year').value,
                  "recordType": document.getElementById('select-userType').value,
                  "company"	  : companys,
                  "profile"	  : profiles                                 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success!",
                    "message": "The Job has been successfully initiated."
                });
                toastEvent.fire();

                if (state === "SUCCESS"){
                    var interval = setInterval($A.getCallback(function () {
                        var jobStatus = cmp.get("c.getBatchJobStatus");
                        if(jobStatus != null){
                            jobStatus.setParams({ jobID : response.getReturnValue()});
                            jobStatus.setCallback(this, function(jobStatusResponse){
                                var state = jobStatus.getState();
                                if (state === "SUCCESS"){
                                    var job = jobStatusResponse.getReturnValue();
                                    cmp.set('v.apexJob',job);
                                    var processedPercent = 0;
                                    if(job.JobItemsProcessed != 0){
                                        processedPercent = ((job.JobItemsProcessed / job.TotalJobItems) * 100).toFixed(2);
                                        console.log('batchprocessedstatus',processedPercent);
                                    }
                                    var progress = cmp.get('v.progress');
                                    if(progress == 100){
                                        var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            "type": "success",
                                            "title": "Success!",
                                            "message": "The Batch has been Executed successfully."
                                        });
                                        toastEvent.fire();
                                    }
                                    cmp.set('v.progress', progress == 100 ? clearInterval(interval) :  processedPercent);
                                    console.log('progressval',cmp.get('v.progress'));
                                }
                            });
                            $A.enqueueAction(jobStatus);
                        }
                    }), 500);
                }
            }
            else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": "An Error has occured. Please try again or contact System Administrator."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})