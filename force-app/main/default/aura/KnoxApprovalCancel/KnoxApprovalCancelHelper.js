({
    
	doInit : function(component, event){
        var self = this;
        var device = $A.get("$Browser.formFactor");
        if(device != "DESKTOP"){
            component.set('v.isMobile',true);
        }  
        var closeQuickModalEvt = $A.get("e.force:closeQuickAction");
        self.spinnerToggle(component, event, true);

        var action = component.get("c.initComponent");      
        action.setParams({
            'recordId' : component.get("v.record").Id
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue(); 
                console.log('# result', result);

                if(result.RESULT){
					component.set('v.canGetStatus', true);

				}else{
					component.set('v.canGetStatus', false);
                    
                    self.showToast(component, 'ERROR', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), result.MSG); 
                    closeQuickModalEvt.fire();
                    return;
				}  

            } else if (state === "ERROR") {
                let errors = response.getError();   // Process error returned by server
                console.error('# errors : ', errors);

                let message = 'Unknown error';      // Default error message                
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                console.error('# errors.message : ', message);
                
                self.showToast(component, 'ERROR', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.COMM_MSG_0001') + ' : ' + message );
                closeQuickModalEvt.fire();
                
            } else {
                self.showToast(component, 'ERROR', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.COMM_MSG_0001') );
                closeQuickModalEvt.fire();
			}
              // Spinner 해제
		    self.spinnerToggle(component, event, false);
        });
        $A.enqueueAction(action);
	},

	cancelApproval : function(component, event){
        var self = this;
        self.spinnerToggle(component, event, true);  

        var comments = component.get("v.CancelComment");
        var closeQuickModalEvt = $A.get("e.force:closeQuickAction");


        var record = component.get("v.record");	    
		var cancelApproval = {
			'KnoxApproval' : {
                "Id": record.Id,
				"MISID__c": record.MISID__c
			},
			 'Comments' : comments
		};

        var action = component.get("c.cancelApproval");      
        action.setParams({
            'jsonParam' : JSON.stringify(cancelApproval)
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				var result = response.getReturnValue(); 
				console.log(result);                
				if(result.RESULT == 'success'){
                    // 상신취소 하였습니다.
                    self.showToast(component, 'success', 'sticky', $A.get('$Label.c.COMM_LAB_SUCCESS'), $A.get('$Label.c.CAPP_MSG_0002') ); // 상신취소 하였습니다.
                    closeQuickModalEvt.fire();

				}else{
                    //'상신취소에 실패 하였습니다.'
                    self.showToast(component, 'error', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get("$Label.c.CAPP_MSG_0003") + ' ' +result.Message); 

				}  
            }else{		
                //'상신취소에 실패 하였습니다.'	
                self.showToast(component, 'error', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get("$Label.c.CAPP_MSG_0003") + ' ' +result.Message);                 

			}             
              // Spinner 해제
        self.spinnerToggle(component, event, false);
        });

		$A.enqueueAction(action);
	},
	
    /**
    * @description  Spinner Toggle Action 
    * @param        
    * @return       Boolean true/false
	**/
    spinnerToggle : function(component, event, showSpinner){
        var spinner = component.find('spinner');
        if(showSpinner) {
            $A.util.removeClass(spinner, 'slds-hide');
            $A.util.addClass(spinner, 'slds-show');
        } else {
            $A.util.removeClass(spinner, 'slds-show');
            $A.util.addClass(spinner, 'slds-hide');
        }
    }, 

   showCustomToast : function(component, toastType, toastMessage){
        component.set('v.showCustomToast', true);
        component.set('v.toastType', toastType);
        component.set('v.toastMessage', toastMessage);
    }, 

    /**
    * @author       Aryum.kim
    * @description  alertToast Action 
    * @param        component : Component
    *               isCloseModal : Close with Modal (Boolean)
    *               toastType : ‘success’, ‘error’
    *               toastMsg : Toast Message
    *               toastSecond : Alert Time
    **/
    alertToast : function(component, isCloseModal, toastType, toastMsg, toastSecond){
        component.set('v.toastMessage', toastMsg);
        this.toastToggle(component, isCloseModal, toastType);
        if(isCloseModal) this.timeOutCloseModal(component, toastSecond);
        else this.timeOutCloseToast(component, isCloseModal, toastSecond, toastType);
    }, 
    
    /**
    * @author       Aryum.kim
    * @description  Toast Toggle Action 
    * @param        component : Component
    * 				isCloseModal : Close with Modal (Boolean)
    * 				toastType : 'success', 'error'
	**/
    toastToggle : function(component, isCloseModal, toastType){
        component.set('v.isCloseModal', isCloseModal);
        component.set('v.toastType', toastType);
        $A.util.toggleClass(component.find(toastType+'-toast'), 'slds-hide');
        if(isCloseModal) $A.util.toggleClass(component.find('body'), 'slds-hide');
    },
    
    /**
    * @author       Aryum.kim
    * @description  Toast Close Action 
    * @param        component : Component
    * 				isCloseModal : Close with Modal (Boolean)
    * 				time : Alert Time
    * 				toastType : 'success', 'error'
	**/
    timeOutCloseToast : function(component, isCloseModal, time, toastType){
        window.setTimeout(
            $A.getCallback(function() {
                if(isCloseModal) $A.util.removeClass(component.find('body'), 'slds-hide');
                $A.util.addClass(component.find(toastType+'-toast'), 'slds-hide');
            }), time
        );
    },
    
    /**
    * @author       Aryum.kim
    * @description  Toast Close with Modal Action
    * @param        component : Component
    * 				time : Alert Time
	**/
    timeOutCloseModal : function(component, time){ 
        window.setTimeout(
            $A.getCallback(function() {
                $A.get("e.force:closeQuickAction").fire();
            }), time
        );
    }, 
    
    callToast : function(isClose, message, type, duration){        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title":type+"!",
            "message":message,
            "type" : type,
            "duration" : duration
        });
        toastEvent.fire();
        if(isClose){
            $A.get("e.force:closeQuickAction").fire();
        }        
    },

    isStringBlank : function(obj) {
        var str = obj.toString();
        return str.replace(/^\s+|\s+$/g, '').length == 0;
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