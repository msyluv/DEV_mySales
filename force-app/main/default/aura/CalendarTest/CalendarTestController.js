/**
 * @description       : 
 * @author            : yeongju.baek@dkbmc.com
 * @group             : 
 * @last modified on  : 06-04-2021
 * @last modified by  : yeongju.baek@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   05-21-2021   yeongju.baek@dkbmc.com   Initial Version
**/
({
	init: function (component, event, helper){
		console.log('init() was called');
		
	},
	doSearch : function(component, event, helper){
		console.log('searchClick was called');
		var searchValue = component.get('v.searchWord');
		var Systemid = '';
		console.log('searchword : ', searchValue);
		console.log('1111111111111111111111 : ');
		
		
		var params = {
			System_ID : Systemid,
			userId : searchValue
		};
		helper.invokeClass(component, 'searchCalendar', params).then(function(result) {
			console.log('calendars result', result.userId);
			
		}).catch(function(result) {
			console.log('error', result.getError);
		});
		
			
		
		
	}
})