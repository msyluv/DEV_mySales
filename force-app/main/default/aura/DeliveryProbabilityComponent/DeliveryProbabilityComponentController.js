({
    init : function(component, event, helper) { 
		let oppId = component.get('v.recordId');
        console.log('oppId: '+oppId);
        var action = component.get("c.DeliveryProbabilityList");        
        action.setParams({"oppId":oppId}); 
        action.setCallback(this, function (response) { 
            var state = response.getState();
            if (state === 'SUCCESS') {
                var res = response.getReturnValue();
                //console.log('Lines: '+ (String(res).match("\n")).length + 1);
                console.log('res: '+res);
                if(res == '' || res == null){
                    component.set("v.DeliveryProbabilityPartial",$A.get("$Label.c.DeliveryProbabilityDefault"));
                }
                else{
                    var value = 'True';
                    component.set("v.ViewAll",value); 
                    component.set("v.DeliveryProbability",res);
                    if(res.length <= 300){
                        console.log('Less Than 300');
                        component.set("v.DeliveryProbabilityPartial",res);
                        var value = 'false';
        				component.set("v.ShowButton",value); 
                    }
                    else{
                        console.log('Less Than 300');
                        console.log('res300: '+res);
                        var x = 0;
                        for(let i=0;i<5 && x<res.length;i++){ 
                            x= res.indexOf("\n",x+1);
                            console.log('Index: '+x);
                            if(x<0){
                                break;
                            }
                        }
                        if(x>0){
                            var index = res.indexOf(" ",x-1);
                            if(index>x){index = x;}
                            console.log('Here');
                            component.set("v.DeliveryProbabilityPartial",res.substring(0,index));   
                        }else{
                            var index = res.indexOf(" ",299);
                            console.log('Here1');
                            component.set("v.DeliveryProbabilityPartial",res.substring(0,index));
                        }
                    }
                }
            } 
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": ErrorMessage,
                    "type":"error"
                });
                toastEvent.fire();
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                        console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action); 
	},
    View : function(component, event, helper){
        component.set("v.Partial",!component.get("v.Partial"));
    }
})