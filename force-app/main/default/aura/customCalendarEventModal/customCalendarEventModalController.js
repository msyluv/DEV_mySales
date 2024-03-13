/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 2020-11-16
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   11-03-2020   woomg@dkbmc.com   Initial Version
**/
({
    openModal: function(component, event, helper) {
		// for Display Modal,set the "isOpen" attribute to "true"
		//console.log('open clicked');
		component.set("v.isOpen", true);

        var sdt = component.get("v.event.start");
        var edt = component.get("v.event.end");
        component.set("v.sd", sdt.format('Y/MM/D'));
        component.set("v.st", sdt.format('HH:mm'));
        console.log(sdt.format('Y/MM/D') + ', ' + sdt.format('HH:mm'));
        component.set("v.ed", edt.format('Y/MM/D'));
        component.set("v.et", edt.format('HH:mm'));
	},

	closeModal: function(component, event, helper) {
		// for Hide/Close Modal,set the "isOpen" attribute to "Fasle"  
		component.set("v.isOpen", false);
	},
 
    gotoEvent: function(component, event, helper) {
        helper.gotoEvent(component, event);
        component.set("v.isOpen", false);
    }
})