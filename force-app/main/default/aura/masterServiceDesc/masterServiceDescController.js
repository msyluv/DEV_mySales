/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-11-03
 * @last modified by  : seonju.jin@dkbmc.com
**/
({
	changeLabel : function(component, event, helper) {
		var labelName = component.get('v.customLabelName');
		var labelSubStr = labelName;
		var labelReference = $A.getReference("$Label.c." + labelSubStr);

		component.set("v.customLabelVal", labelReference);
		var temp = component.get("v.customLabelVal");
		if(temp.indexOf('does not exist.')  > -1){
			component.set("v.customLabelVal", '');
		}
	}
})