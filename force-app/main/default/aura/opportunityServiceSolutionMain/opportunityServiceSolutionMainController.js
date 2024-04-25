/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-10-05
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2020-11-16   seonju.jin@dkbmc.com   Initial Version
**/
({
	init : function(component, event, helper) {
		var recordId = component.get('v.recordId');
		if(recordId == undefined){
            var pageRef = component.get("v.pageReference");
            if(pageRef != null){
                var state = pageRef.state;
                var base64Context = state.inContextOfRef;
                if (base64Context.startsWith("1\.")) base64Context = base64Context.substring(2);
                var addressableContext = JSON.parse(window.atob(base64Context));
                component.set("v.recordId", addressableContext.attributes.recordId);
            }
        }
		helper.doInit(component);
	},

	cancel: function(component, event, helper){
		helper.cancel(component, event);
	},

	save: function(component, event, helper){
        console.log('isSaveButtonLog12:');
		helper.saveServiceSolution(component, false); 
	},

	onConfirmSAP : function(component, event, helper){
        console.log('isSaveButtonProject:');
		helper.saveServiceSolution(component, true); 
	},
	onSendService : function(component, event, helper){
        console.log('isSendServiceButtonProject:');
		helper.sendService(component, event, helper); 
	},

	/**
	 * opporutnitySvcSolPopup event를 통한 sendSAP 실행
	 */
	onConfirmSAP_evt : function(component, event, helper){
		component.set('v.isLoading',true);
		var isSave = event.getParam('forceSave');
		console.log('isSave:' + isSave);
		if(isSave){
			helper.saveServiceSolution(component, true);
		}else{
			helper.onConfirmSAP(component);
		}
	},

	isLocked: function(component, event, helper){
		helper.showToast('error','ERROR',$A.get('$Label.c.COMM_MSG_RECORD_LOCKED'));
	},

	onEvtAction: function(component, event, helper){
		helper.onEvtAction(component, event);
	},
})