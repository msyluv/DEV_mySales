({
    showMyToast : function(type, msg) {
        var mode     = 'dismissible',
            duration = 5000,
            title    = type.charAt(0).toUpperCase() + type.slice(1);
        switch (type.toLowerCase()) {
            case 'error':
                mode = 'sticky';
                break;
            case 'warning':
                mode = 'sticky';
                break;
            case 'success':
                mode = 'dismissible';
                duration = 5000;
                break;
        }

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            mode: mode,
            message: msg,
            title: title,
            duration: duration,
        });
        toastEvent.fire();
	}
})