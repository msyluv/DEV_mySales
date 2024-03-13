/**
 * @description       : 
 * @author            : wonjune.oh@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-07-08
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2021-01-05   wonjune.oh@partner.samsung.com   Initial Version
**/
({
    solBizAttrSendToEcc : function(component, event) {
        var _this = this;
        _this.spinnerToggle(component, event);
        var recordId = component.get("v.recordId");	    

        var action = component.get("c.solBizAttrSendToEcc");
        action.setParams({
            /* 'recordId' : recordId */
        });

        action.setCallback(_this, function(response) {
            var state = response.getState();
            // console.log('state : ' +  state);      
            var result = response.getReturnValue(); 
            // console.log('sad123 :  ' + result['StatusCode']);
            // console.log('sad123 :  ' + result['resType']);

            if(/* result['StatusCode'] != '200' || */ result['resType'] != 'S'){
                _this.showToast(component, 'ERROR', 'dismissible',$A.get('$Label.c.COMM_LAB_ERROR'), result['Message'], 5000);
            }else{
                $A.get('e.force:refreshView').fire();
                _this.showToast(component, 'success', 'dismissible', '', $A.get('$Label.c.COMM_LAB_SUCCESS'), 5000);
            }
            
            // Spinner hide 및 QuickAction Modal Close
            $A.get("e.force:closeQuickAction").fire();
        });

		$A.enqueueAction(action)
    },
    
    spinnerToggle : function(component, event){
        var spinner = component.find('spinner2');
        $A.util.toggleClass(spinner, 'slds-hide');
    }, 

    /**
	 * 
	 * @param {*} component 
	 * @param {*} type 		'error', 'warning', 'success', 'info'
	 * @param {*} mode 		'pester', 'sticky', 'dismissible'
	 * @param {*} title 
	 * @param {*} message 
	 * @param {*} duration 
	 */
    showToast : function(component, type, mode, title, message, duration) {
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

        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type : type,
            mode : mode,
            title: title,
            message : message,
            duration : duration
        });
        toastEvent.fire();
    }

})