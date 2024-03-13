/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-06-23
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2021-06-23   seonju.jin@dkbmc.com   Initial Version
**/
({
	init : function(component, event, helper) {
        var options = component.get('v.sOptions'),
            value = component.get('v.defaultValue'),
            name = component.get('v.buttonName');
        
        component.set("v.buttonName" , "radioBtnGroup-" + name);
        component.set("v.sOptions" , options);
        component.set("v.defaultValue" , value);
        component.set("v.resultValue" , value);
    },
    
    onChange : function(component, event, helper) {
        var selected = event.getSource().get("v.value");
        var name = event.getSource().get("v.name");
        var changeValue = event.getParam("value");
        // console.log('click changeValue : ' , changeValue);
        // console.log('click val : ' , selected);
        component.set("v.resultValue" , changeValue);
    },
    
    onChange2 : function(component, event) {
        var selected = event.getSource().get("v.value");
        var name = event.getSource().get("v.name");
        var changeValue = event.getParam("value");
        component.set("v.resultValue" , changeValue);

        var evt = $A.get("e.c:groupBtnOnChangeEvt");
        evt.setParams({'changeIndex': component.get('v.currArrayIndex')
                        ,'changeVal': changeValue});
        evt.fire();

        // console.log('click changeValue : ' , changeValue);
        // console.log('click val : ' , selected);
        
    } 
})