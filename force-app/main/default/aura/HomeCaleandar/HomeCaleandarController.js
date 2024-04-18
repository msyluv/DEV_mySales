/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-02-24
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-11-09   younghoon.kim@dkbmc.com   Initial Version
 * 1.1   2021-02-05   younghoon.kim@dkbmc.com   My Team 로직 추가
**/
({
	doInit : function(component, event, helper){
		var device = $A.get( "$Browser.formFactor");
		if( device != "DESKTOP") component.set( "v.isMobile", true);

		helper.doInit(component, event);
	},

	prevMonth : function(component, event, helper){
		helper.prevMonth(component);
	},

	nextMonth : function(component, event, helper){
		helper.nextMonth(component);
	},
	
	gotoActivity : function(component, event, helper){
		helper.gotoActivity(component, event);
	},

	getMyTeam : function(component, event, helper){
		helper.getTeamActivity(component, event);
	},

	handleChange : function(component, event, helper){
		helper.queryActivity(component, event);
	}
    // Divyam knox changes
     /*
      callKnoxData : function(component, event, helper){
       // helper.callKnoxData(component,event);
        
		var action = component.get("c.getKnoxSchedules");
        action.setParams({});
        action.setCallback(this,function(response){
             var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.showSpinner",true);
                   var interval = setInterval($A.getCallback(function () {
                        var jobStatus = component.get("c.getAsnycjobStatus");
                        if(jobStatus != null){
                            jobStatus.setParams({ jobid : response.getReturnValue()});
                            jobStatus.setCallback(this, function(jobStatusResponse){
                                var state = jobStatus.getState();
                                if (state === "SUCCESS"){
                                    var job = jobStatusResponse.getReturnValue();
                                    component.set('v.apexJob',job);
                                    var processedPercent = 0;
                                    if(job.JobItemsProcessed != 0){
                                        processedPercent = ((job.JobItemsProcessed / job.TotalJobItems) * 100).toFixed(2);
                                        console.log('batchprocessedstatus',processedPercent);
                                    }
                                    var progress = component.get('v.progress');
                                    if(progress == 100){
                                        component.set("v.showSpinner",false);
                                        $A.get('e.force:refreshView').fire();
                                         helper.showMyToast('success', 'Successfully');
                                    }
                                    component.set('v.progress', progress == 100 ? clearInterval(interval) :  processedPercent);
                                    console.log('progressval',component.get('v.progress'));
                                }
                                
                            });
                            $A.enqueueAction(jobStatus);
                        }
                    }), 4000);
            }
               else if (state === "ERROR") {
                    helper.showMyToast('error', 'An Error has occured. Please try again or contact System Administrator.');
                
            }
        });
        console.log('action___________' + action);
        $A.enqueueAction(action);
      
         

	}
    */
    
})