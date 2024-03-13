({
	doInit : function(component, event, helper) {
		var duration = component.get("v.duration");
		window.setTimeout(
			$A.getCallback(function() {
				helper.operation(component);
			}), duration
		);
	},

	clickClose : function(component, event, helper) {
		helper.operation(component);
	},
})