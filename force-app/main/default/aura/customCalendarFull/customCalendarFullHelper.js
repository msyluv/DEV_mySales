/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 2020-11-18
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   11-03-2020   woomg@dkbmc.com   Initial Version
**/
({
	initHandlers: function(component) {
		// Build the calendar
		$('#calendarComp').fullCalendar({
            events: function(start, end, timezone, callback) {
				var events = [];
                callback(events);
            },
			eventClick:  function(event, jsEvent, view) {
                var ev = component.find("evmodal");
                component.set("v.event", event);
				ev.openModal();
			},
			/*loading: function(bool) {
				var spinner = component.find('spinner');
				if (bool)
					$A.util.removeClass(spinner, "slds-show");
				else
					$A.util.addClass(spinner, "slds-hide");
			},*/
			header: {
				left: null,
				center: 'title',
				right: null
			},
			themeButtonIcons: false,
			editable: false,
			eventLimit: true,
			eventLimitClick: 'listDay',
			timeFormat: 'H:mm',
			theme: true
		});
	},
	resetEvents: function(component, event){
		var self = this,
			params = event.getParam('arguments');
		$('#calendarComp').fullCalendar('removeEvents');
		var calView = $('#calendarComp').fullCalendar('getView');
		var calendarInput = new Object();
		calendarInput.startDate = calView.start.toJSON();
		calendarInput.endDate = calView.end.toJSON();
		calendarInput.firstCall = component.get("v.firstCall");
        calendarInput.hasCompleteField = component.get("v.hasCompleteField");
		calendarInput.fieldComplete = component.get("v.fieldComplete");
		calendarInput.isRoleId = params.isRoleId;
		calendarInput.ids = params.ids;
		calendarInput.className = component.get("v.className");
		calendarInput.editable = component.get("v.editable");
		calendarInput.useUrl = component.get("v.useUrl");
		calendarInput.color = component.get("v.color");
		calendarInput.backgroundColor = component.get("v.backgroundColor");
		calendarInput.borderColor = component.get("v.borderColor");
		calendarInput.textColor = component.get("v.textColor");
		calendarInput.types = params.checkedValue;

		component.set("v.showSpinner", true);
		self.apex(component, 'getCalendarEvents', {"calendarInputJSON":JSON.stringify(calendarInput)})
		.then((result) => {
            component.set("v.firstCall", false);
			var events = [];

			events = result.map(eve => {
				return {
					id					: eve.objId,
					title				: eve.Subject, // eve.Subject or eve.Owner

					// Required fields
					start				: eve.StartDateTime,
					end					: eve.EndDateTime,
					allDay				: eve.IsAllDayEvent,
					
					// Salesforce specific fields 
					subject				: eve.Subject,
					owner				: eve.Owner,
					ownerId				: eve.OwnerId,
					activityDate		: eve.ActivityDate,
					activityDateTime	: eve.ActivityDateTime,
					eventSubtype		: eve.EventSubtype,
					location			: eve.Location,
					description			: eve.Description,
					whoId				: eve.WhoId,
					who					: eve.Who,
					whatId				: eve.WhatId,
					what				: eve.What,
					durationInMinutes	: eve.DurationInMinutes,
					showAs				: eve.ShowAs,
					isPrivate			: eve.IsPrivate,

					// FullCalendar specific fields 
					url					: eve.url,
					className			: eve.className,
					editable			: eve.editable,
					color				: eve.color,
					backgroundColor		: eve.backgroundColor,
					borderColor			: eve.borderColor,
					textColor			: eve.textColor,
					type				: eve.type
				}
			});
			/*
			// Iterate over each record, to push to events on calendar
			var sfevents = result;
			sfevents.forEach(function(eve){
						
				events.push({
                    id					: eve.objId,
					title				: eve.Owner, // or eve.Subject

                    // Required fields
					start				: eve.StartDateTime,
					end					: eve.EndDateTime,
                    allDay				: eve.IsAllDayEvent,
                    
                    // Salesforce specific fields 
                    subject				: eve.Subject,
                    owner				: eve.Owner,
                    ownerId				: eve.OwnerId,
                    activityDate		: eve.ActivityDate,
                    activityDateTime	: eve.ActivityDateTime,
                    eventSubtype		: eve.EventSubtype,
                    location			: eve.Location,
					description			: eve.Description,
                    whoId				: eve.WhoId,
                    who					: eve.Who,
                    whatId				: eve.WhatId,
                    what				: eve.What,
                    durationInMinutes	: eve.DurationInMinutes,
                    showAs				: eve.ShowAs,
                    isPrivate			: eve.IsPrivate,

                    // FullCalendar specific fields 
                    url					: eve.url,
                    className			: eve.className,
                    editable			: eve.editable,
					color				: eve.color,
					backgroundColor		: eve.backgroundColor,
					borderColor			: eve.borderColor,
                    textColor			: eve.textColor

                });
			});
			*/
			$('#calendarComp').fullCalendar('renderEvents', events);
			component.set("v.showSpinner", false);
		})
		.catch((errors) => {
			self.errorHander(errors);
			component.set("v.showSpinner", false);
		});
	},
	
	goPrev: function(component) {
		$('#calendarComp').fullCalendar('prev');
	},
	goNext: function(component) {
		$('#calendarComp').fullCalendar('next');
	},
	goToday: function(component) {
		$('#calendarComp').fullCalendar('today');
	},
	viewMonth: function(component) {
		$('#calendarComp').fullCalendar('changeView', 'month');
	},
	viewAgendaWeek: function(component) {
		$('#calendarComp').fullCalendar('changeView', 'agendaWeek');
	},
	viewAgendaDay: function(component) {
		$('#calendarComp').fullCalendar('changeView', 'agendaDay');
	},
	viewList: function(component) {
		$('#calendarComp').fullCalendar('changeView', 'listMonth');
	},

    openEvent : function(component) {
        var ev = component.find("evmodal");
        ev.openModal();
	},
	
	apex : function(component, apexAction, params){
        return new Promise( $A.getCallback( function( resolve, reject ) {
            var action = component.get("c."+apexAction+"");
            action.setParams( params );
            action.setCallback( this, function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));
    },

    errorHander : function(errors){
        var self = this;
        if(Array.isArray(errors)){
            errors.forEach(function(err){
                self.showMyToast('error', err.exceptionType + " : " + err.message);
            });
        } else {
            console.log(errors);
            self.showMyToast('error', 'Unknown error in javascript controller/helper.')
        }
    },

    showMyToast : function(type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 10000,
            mode: 'dismissible',
            message: msg
        });
        toastEvent.fire();
	},

})