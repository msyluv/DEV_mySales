/**
 * @author            : hyunhak.roh@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2022-11-23
 * @last modified by  : hyunhak.roh@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2022-11-23   hyunhak.roh@dkbmc.com		Initial Version
**/
({
	doInit : function(component, event, helper) {
		helper.helperInit(component, event);
	},

	confirm : function(component, event, helper) {
        /*
		var cdId = component.get('v.contentDocumentId');
		window.console.log('cdId : ', cdId);
		if(cdId != '') helper.downloadFile(component, event, cdId);
		else 		   helper.showMyToast('error', 'There are no attachments.');
        */
        
	},

	cancel: function(component, event, helper){
		component.find("overlayLib").notifyClose();
	}
})