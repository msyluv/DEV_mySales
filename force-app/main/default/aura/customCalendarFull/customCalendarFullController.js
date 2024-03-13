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
    afterScriptsLoaded: function(component, event, helper) {       
        //console.log('Inside the Component Controller', component.get("v.ready"));
      //  helper.initHandlers(component);
       // component.set("v.ready", true);
    },
    resetEvents: function(component, event, helper) {
        helper.resetEvents(component, event);
    },
    goPrev: function(component, event, helper) {
        helper.goPrev(component);
    },
    goNext: function(component, event, helper) {
        helper.goNext(component);
    },
    goToday: function(component, event, helper) {
        helper.goToday(component);
    },
    viewMonth: function(component, event, helper) {
        helper.viewMonth(component);
    },
    viewList: function(component, event, helper) {
        helper.viewList(component);
    }
})