({
    closeToast : function(type, message, duration) {    
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title":type+"!",
            "message":message,
            "type" : type,
            "duration" : duration
        });
        toastEvent.fire();
        
        $A.get("e.force:closeQuickAction").fire();
        
    }
})