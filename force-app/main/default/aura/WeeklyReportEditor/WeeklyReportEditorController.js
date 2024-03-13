({
    doInit : function(component, event, helper) {
        /*window.addEventListener("message", $A.getCallback(function(event) {
            console.log(event.data);
            var msg = event.data; 
            if(msg=='close'){
                helper.closeFromVF(component,event);
            }
            else if(msg=='loading'){
                component.set('v.showSpinner',true); 
            }else if(msg=='endLoading'){
                component.set('v.showSpinner',false); 
            }else if(msg=='saveClose'){
                helper.saveClose(component,event); 
            }else{
                helper.callErrorToast(component,event,msg); 
            }
        }), false);*/

        var device = $A.get("$Browser.formFactor");
        var baseUrl = location.href; 
        if(device !="DESKTOP"){
            component.set('v.isMobile',true);
        }
		component.set('v.section', "Description");     
        
    }   
})