/**
 * @description       : 주소검색 Controller
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 06-29-2021
 * @last modified by  : yeongju.baek@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2020-11-03   seonju.jin@dkbmc.com   Initial Version
**/
({
	init: function(component, event, helper){
		helper.doInit(component, event);
		var device = $A.get( "$Browser.formFactor");
		if( device != "DESKTOP") component.set( "v.isMobile", true);
	},

	clickSearch: function(component,event,helper){
		helper.openPopup(component);
	},
	click360: function(component,event,helper){
		helper.open360(component);
	}
})