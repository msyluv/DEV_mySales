/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 2020-12-11
 * @last modified by  : hj.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   11-20-2020   woomg@dkbmc.com   Initial Version
**/
({
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
    /**
	 * 
	 * @param {*} component 
	 * @param {*} componentName 
	 * @param {*} attributeParams 
	 * @param {*} cssClass 
	 * @param {*} closeCallback 
	 */
	showComponentModal : function(component, componentName, attributeParams, cssClass, closeCallback) {        
        $A.createComponent('c:' + componentName
            , attributeParams
            , function(content, status, errorMessage) {
				if (status === "SUCCESS") {
					component.find('overlayLib').showCustomModal({
						body: content,
						showCloseButton: true,
						cssClass: cssClass,
						closeCallback: closeCallback
					})
				} else if (status === "ERROR") {
					console.log("Error: " + errorMessage);
				}
        });
	}
})