({
	operation : function(component) {
		console.log('operation');
		var target = component.get("v.target"),
			isUrl = component.get("v.isUrl"),
			isHistory = component.get("v.history");

		if(target != ""){
			if(isUrl){
				var urlEvent = $A.get("e.force:navigateToURL");
				urlEvent.setParams({
					"url": target,
					"isredirect": true
				});
				urlEvent.fire();
			} else {
				var navEvt = $A.get("e.force:navigateToSObject");
				navEvt.setParams({
					"recordId": target,
					"slideDevName": "detail",
					"isredirect": true
				});
				navEvt.fire();
			}
		} else {
			if(isHistory){
				window.history.go(-2);
			} else {
				var dismissActionPanel = $A.get("e.force:closeQuickAction");
				dismissActionPanel.fire();
			}
		}
	}
})