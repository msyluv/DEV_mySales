/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 2020-11-30
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   11-03-2020   woomg@dkbmc.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
		var device = $A.get( "$Browser.formFactor");
		if( device != "DESKTOP") component.set( "v.isMobile", true);
		
		//console.log('GroupCalendar doInit function');
		helper.doInit(component, event);
    },
    renderCalendar : function(component, event, helper) {
      	helper.renderCalendar(component);
    },
    calendarReady:  function(component, event, helper){
      	helper.initCalednar(component);
    },
    selectTree : function(component, event, helper){
		event.preventDefault();
		console.log(event.getParam('name'));
		console.log(component.get('v.roleTree'));
    
    },
    goPrev : function(component, event, helper) {
		var cal = component.find("fullCalendar");
		cal.goPrev();

		helper.renderCalendar(component);
    },
    goNext : function(component, event, helper) {
		var cal = component.find("fullCalendar");
		cal.goNext();

		helper.renderCalendar(component);
    },
    goToday : function(component, event, helper) {
		var cal = component.find("fullCalendar");
		cal.goToday();

		helper.renderCalendar(component);
    },
    viewMonth : function(component, event, helper) {
		var cal = component.find("fullCalendar");
		cal.viewMonth();

		helper.renderCalendar(component);
    },
    viewList : function(component, event, helper) {
		var cal = component.find("fullCalendar");
		cal.viewList();

		helper.renderCalendar(component);
    },
    handleChange: function(component, event, helper){
      	helper.renderCalendar(component);
    }
})