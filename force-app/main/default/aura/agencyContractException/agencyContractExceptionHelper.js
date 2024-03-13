/**
 * @description       : 
 * @author            : wonjune.oh@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-14
 * @last modified by  : wonjune.oh@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-30   wonjune.oh@partner.samsung.com   Initial Version
**/
({
     /**
	 * 
	 * @param {*} component 
	 * @param {*} event 
	 */
	submit : function(component, event) {
        var userId = $A.get( "$SObjectType.CurrentUser.Id" );
        var fields = event.getParam('fields');

		if(fields.Urgency__c == ''){
			console.log('aaaaasd');
		}

		if(fields.Urgency__c == null){
			console.log('bbbbasd');
		}

		if(fields.Urgency__c){
			console.log('ccccasd');
		}

        console.log('owner :' +  fields.VRBOwner__c);
		if(fields.Urgency__c != null || fields.Security__c != null){
			 if(fields.Urgency__c || fields.Security__c){
				console.log('aaaa ===' + fields.Urgency__c+'===');
				component.find('recordEditForm').submit(fields);
				component.set('v.showSpinner', true);
			 }else{
				this.showToast(null, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR') , $A.get('$Label.c.OPPTYACT_MSG_008'));	 
			 }
		}else{
			this.showToast(null, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR') , $A.get('$Label.c.OPPTYACT_MSG_008'));
		}
    },

    close : function(component, event) {
		component.find('overlayLib').notifyClose();
    }, 
    log : function(msg, object) {
        var objectToJSONObject = object ? JSON.parse(JSON.stringify(object)) : object;
        if(this.DEBUG) console.log(msg, objectToJSONObject);
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
    },
})