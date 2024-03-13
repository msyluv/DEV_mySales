/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 07-15-2021
 * @last modified by  : zenith21c@test.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2021-06-14   seonju.jin@dkbmc.com   Initial Version
**/
({
	cancel : function(component, event, helper) {
		component.set('v.openModal',false);
	},

	confirm: function(component){
		component.set('v.openModal',false);

		try{
			//OpportunityReviewMain - confirm
			let getEvt = component.getEvent('sendToReviewConfirmEvt');
			getEvt.fire();
		}catch(e){
			console.log(e);
		}
		
	}


})