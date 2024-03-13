({
    toastClose : function(component, event, helper) {    
        var toastkey = event.currentTarget.getAttribute("data-itemId");
        var toastList = component.get('v.toastList');

        for(var i=0; i < toastList.length; i++){
            if(toastList[i].toastId == toastkey){     
                console.log('find');
                toastList.splice(i,1);
                console.log(toastList.length);
                component.set('v.toastList', toastList);
                return;                
            }
        }
        
    },
    addToast : function(component, event, helper) {    
        var toast = component.get('v.toast');       
        
        if(toast.isClose){
            helper.closeToast(toast.type, toast.message, toast.duration );
        }else{
            var isStack = component.get('v.isStack');
            
            
            var ar  = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
            
            var toastkey = new Date().getTime();			
            
            for(var i = 0; i < 6; i++) {
                toastkey += ar.charAt(Math.floor(Math.random() * ar.length));
            };
            
            var toastObj = {
                'toastId'        : toastkey
                , 'type'         : toast.type
                , 'message_type' : toast.message_type
                , 'message'      : toast.message
            };
            
            if(isStack){
                var toastList = component.get('v.toastList');
                toastList.push(toastObj);
                component.set('v.toastList', toastList);
            }else{
                var newList = [];
                newList.push(toastObj);
                component.set('v.toastList', newList);
            }
            
            console.log(toast.duration);
            var time = toast.duration;
            window.setTimeout(
                $A.getCallback(function() {      
                    console.log('setTimeout');       
                    var toastList = component.get('v.toastList');

                    if(toastList){
                        for(var i=0; i < toastList.length; i++){
                            console.log('toastList[i].toastId', toastList[i].toastId);
                            console.log('toastkey', toastkey);
                            if(toastList[i].toastId == toastkey){     
                                console.log('find');
                                toastList.splice(i,1);
                                console.log(toastList.length);
                                component.set('v.toastList', toastList);
                                return;
                                
                            }                        
                        }
                    }
                    
                }), time
            );
        }
    }
    
})