/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-09-28
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2021-06-14   seonju.jin@dkbmc.com   Initial Version
**/
({
	close : function(component, event, helper) {
		component.set('v.openModal',false);
	},

	onConfirmSAP: function(component){
		component.set('v.openModal',false);

		try{
			//OpporutnityServiceSolutionMain - onConfirmSAP
			let getEvt = component.getEvent('sendToSapEvt');
			getEvt.setParams({'forceSave':component.get('v.forceSave')});
			getEvt.fire();
		}catch(e){
			console.log(e);
		}
		
	}


})