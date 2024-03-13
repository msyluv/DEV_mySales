/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-01-19
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-01-19   younghoon.kim@dkbmc.com   Initial Version
**/
({
	doInit : function(component, event, helper) {
		helper.helperInit(component, event);
	},

	download : function(component, event, helper) {
		var cdId = component.get('v.contentDocumentId');
		window.console.log('cdId : ', cdId);
		if(cdId != '') helper.downloadFile(component, event, cdId);
		else 		   helper.showMyToast('error', 'There are no attachments.');
	},

	cancel: function(component, event, helper){
		component.find("overlayLib").notifyClose();
	},
})