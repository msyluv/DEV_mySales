({
    cancelKnoxEmail : function(component, event){
		var _this = this;
        var record = component.get("v.record");	    
		var knoxEmailObj = {
			'KnoxEmail__c' : {
                "Id": record.Id,
                "MailId__c": record.MailId__c,
                "ToAddress__c": record.ToAddress__c,
                "CcAddress__c": record.CcAddress__c,
                "BccAddress__c": record.BccAddress__c,
                "Status__c" : record.Status__c,
			}
		};

        console.log('knoxEmailObj', knoxEmailObj);
        var action = component.get("c.cancelKnoxEmail");
        action.setParams({
            'jsonParam' : JSON.stringify(knoxEmailObj)
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue(); 
                console.log('result', result);
				if(result.RESULT == 'success'){
                    _this.showToast(component, 'success', 'dismissible', $A.get('$Label.c.COMM_LAB_SUCCESS'), $A.get('$Label.c.EMAIL_MSG_0014'), 3000);  // 결재 상태가 업데이트 되었습니다.
                    
				}else{
                    console.log('Fail');
                    _this.showToast(component, 'error', 'dismissible', $A.get('$Label.c.COMM_MSG_0001'), result.Message, 3000); // 오류가 발생하였습니다.
					
				}  
            }else{
                _this.showToast(component, 'error', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.COMM_MSG_0001'), 3000); // 오류가 발생하였습니다.
			}             
            
            // Spinner hide 및 QuickAction Modal Close
            _this.spinnerToggle(component, event);
            $A.get("e.force:closeQuickAction").fire();
        });

		$A.enqueueAction(action);	
	},
	
    spinnerToggle : function(component, event){
        var spinner = component.find('spinner');
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