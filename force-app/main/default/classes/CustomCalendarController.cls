/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 2020-11-26
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   11-03-2020   woomg@dkbmc.com   Initial Version
**/
global with sharing class CustomCalendarController {
    @AuraEnabled
    public static List<Event> fetchAllEvents(){
        List<Event> eventList = new List<Event>();
        eventList = [Select Id, Subject, WhatId, WhoId, 
                    Description, EndDate, EndDateTime, OwnerId,
                    ActivityDate, ActivityDateTime From Event LIMIT 100];
        return eventList;
    }

    @AuraEnabled
	global static SetId getUserRoleId(){
        SetId tmp = new SetId();
        if(UserInfo.getUserRoleId() != null){
            tmp.isRoleId = true;
            tmp.UserOrRoleId = UserInfo.getUserRoleId();
        } else {
            tmp.isRoleId = false;
            tmp.UserOrRoleId = UserInfo.getUserId();
        }
        return tmp;
	}

	@AuraEnabled
	global static List<CalendarEvent> getCalendarEvents(String calendarInputJSON){
		// Load the input into the custom type
		CalendarInput cInput = (CalendarInput)JSON.deserialize(calendarInputJSON,CalendarInput.class);

		List<CalendarEvent> events = new List<CalendarEvent>();

		try {
            // Convert Javascript date string to Apex DateTime class
            String sdt = '';
            String edt = '';
            Date sd = Date.newInstance(system.today().year(), system.today().month(), 1);
            Date ed = sd.addMonths(1);
            Time tt = Time.newInstance(0,0,0,0);
            
            if(!String.isBlank(cInput.startDate)){
                sd = Date.valueOf(cInput.startDate);
            }
            if(!String.isBlank(cInput.endDate)){
                ed = Date.valueOf(cInput.endDate).addDays(1);
            }
            
            sdt = DateTime.newInstance(sd, tt).format('yyyy-MM-dd HH:mm:ss').replace(' ', 'T') + 'z';
			edt = DateTime.newInstance(ed, tt).format('yyyy-MM-dd HH:mm:ss').replace(' ', 'T') + 'z';

			String actDateStart = DateTime.newInstance(sd, tt).format('yyyy-MM-dd');
			String actDateEnd = DateTime.newInstance(ed, tt).format('yyyy-MM-dd');
			
			//Seonju.jin@dkbmc.com | 2020-11-13
			//Task, Account Plan, Opportunity Activity 이벤트 추가
			for(String type: cInput.types){
				if(type == 'Event'){
					List<Event> levent = getEventsFromEvent(cInput,sdt,edt);
					events.addAll(rednerEvents(cInput, levent));
				}
				
				if(type == 'Task'){
					List<Task> lTask = getEventsFromTask(cInput,actDateStart,actDateEnd);
					events.addAll(rednerEvents(cInput, lTask));
				}
	
				if(type == 'Account Plan'){
					List<AccountPlan__c> lAcctPlan = getEventsFromAcctPlan(cInput,sdt,edt);
					events.addAll(rednerEvents(cInput, lAcctPlan));
				}
	
				if(type == 'Opportunity Activity'){
					List<Opportunity_Activity__c> lOpprtAct = getEventsFromOpportAcct(cInput,actDateStart,actDateEnd);
					events.addAll(rednerEvents(cInput, lOpprtAct));
				}
			}

		} catch (QueryException e) {
			throw new CalendarException ('Error when retrieving events ' + e.getMessage());
		} catch (Exception e) {
			throw new CalendarException ('Error when retrieving events ' + e.getMessage() + e.getStackTraceString());
		}

		return events;
    }

    @AuraEnabled
	global static String getUserRoles(String roleOrUserId, Boolean includeUser) {
        String jsonString = '';
		if(jsonString == ''){
            String oId = roleOrUserId != null ? roleOrUserId : '';
            if(oId == '') oId = UserInfo.getUserRoleId() != null ? UserInfo.getUserRoleId() : UserInfo.getUserId();
			jsonString = RoleUtil.getTreeJSON(oId, includeUser);
		}
		return jsonString;
	}

    global static list<String> getUsersIdByRole(list<String> rids){
        list<String> lid = new list<String>();
        list<User> lusr = [SELECT Id FROM User WHERE UserRoleId IN :rids];
        if(lusr != null && lusr.size() > 0){
            for(User u : lusr){
                lid.add(u.Id);
            }
        }
        return lid;
    }

	/**
	 * Method that generates a random color
	 * @return String value for a random color
	 */
	global static String getRandomColor() {
		List<String> letters = '0123456789ABCDEF'.split('');
		String color = '#';
		for (Integer i = 0; i < 6; i++ ) {
			color += letters[Integer.valueof(Math.floor(Math.random() * 16))];
		}
		return color;
	}

	/**
	* @description select event
	* @author seonju.jin@dkbmc.com | 2020-11-13 
	* @param CalendarInput cInput CalendarInput
	* @param String startDate 이벤트 시작일
	* @param String endDate 이벤트 종료일
	* @return List<Event> EventList
	**/
	public static List<Event> getEventsFromEvent(CalendarInput cInput, String startDate, String endDate){
		List<Event> levent = new List<Event>();

		// Build the query
		String query = '';
		query += 'SELECT Id, Subject, OwnerId, Owner.Name, StartDateTime, EndDateTime, ';
		query += 'EventSubtype, Location, Description, WhoId, Who.Name, WhatId, What.Name, ';
		query += 'DurationInMinutes, ShowAs, IsPrivate, IsAllDayEvent, ';
		
		if(cInput.hasCompleteField && !String.isBlank(cInput.fieldComplete)){
			query += cInput.fieldComplete;
			query += ', ';
		}

		query = query.trim().removeEnd(',');
		
		query += ' FROM Event ';
		String whereClause = ' WHERE StartDateTime >= ' + startDate + ' AND EndDateTime <= ' + endDate + ' ';
		
		list<String> listId = new list<String>();
		if(cInput.ids != null && cInput.ids.size() > 0) listId.addAll(getUsersIdByRole(cInput.ids));
		
		if(cInput.firstCall && (listId == null || listId.size() == 0)){
			listId.add(UserInfo.getUserId());
		}
		
		whereClause += ' AND OwnerId IN :listId ';
		
		query += whereClause;
		
		String color = cInput.color;

		// Query for the records
		levent = Database.query(query);

		return levent;
	}


	/**
	* @description data render to CalendarEvent List
	* @author seonju.jin@dkbmc.com | 2020-11-13 
	* @param List<Event> lEvent Event List
	* @return List<CalendarEvent> 
	**/
	public static List<CalendarEvent> rednerEvents(CalendarInput cInput, List<Event> lEvent){
		List<CalendarEvent> events = new List<CalendarEvent>();

		if(levent != null && levent.size() > 0){
			for(Event ev : levent){
				CalendarEvent cEvent = new CalendarEvent();
				
				cEvent.objId			= ev.Id;
				cEvent.Subject			= ev.Subject;
				cEvent.OwnerId			= ev.OwnerId;
				cEvent.Owner			= ev.Owner.Name;
				cEvent.ActivityDate		= ev.StartDateTime != null ? ev.StartDateTime.format('yyyy-MM-dd') : '';
				cEvent.ActivityDateTime	= ev.StartDateTime != null ? ev.StartDateTime.format('yyyy-MM-dd HH:mm:ss').replace(' ', 'T') : '';
				cEvent.StartDateTime	= ev.StartDateTime != null ? ev.StartDateTime.format('yyyy-MM-dd HH:mm:ss').replace(' ', 'T') : '';
				cEvent.EndDateTime		= ev.EndDateTime != null ? ev.EndDateTime.format('yyyy-MM-dd HH:mm:ss').replace(' ', 'T') : '';
				cEvent.EventSubtype		= ev.EventSubtype != null ? ev.EventSubtype : '';
				cEvent.Location			= ev.Location != null ? ev.Location : '';
				cEvent.Description		= ev.Description != null ? ev.Description : '';
				cEvent.WhoId			= ev.WhoId == null ? '' : ev.WhoId;
				cEvent.Who				= ev.WhoId == null ? '' : ev.Who.Name;
				cEvent.WhatId			= ev.WhatId == null ? '' : ev.WhatId;
				cEvent.What				= ev.WhatId == null ? '' : ev.What.Name;
				cEvent.DurationInMinutes= ev.DurationInMinutes != null ? ev.DurationInMinutes : 0;
				cEvent.ShowAs			= ev.ShowAs != null ? ev.ShowAs : '';
				cEvent.IsPrivate		= ev.IsPrivate;
				cEvent.IsAllDayEvent	= ev.IsAllDayEvent;

				cEvent.url				= cInput.useUrl ? '#/sObject/' + ev.Id + '/view' : '';
				cEvent.className		= cInput.className;
				cEvent.editable			= cInput.editable;
				cEvent.color			= '#EDC779'; // '#FFA648';	//cInput.color
				cEvent.backgroundColor	= cInput.backgroundColor;
				cEvent.borderColor		= cInput.borderColor;
				cEvent.textColor		= cInput.textColor;
				cEvent.type				= 'Event';
				
				events.add(cEvent);
			}
		}

		return events;
	}


	/**
	* @description select event
	* @author seonju.jin@dkbmc.com | 2020-11-13 
	* @param CalendarInput cInput CalendarInput
	* @param String startDate 이벤트 시작일
	* @param String endDate 이벤트 종료일
	* @return List<Task> TaskList
	**/
	public static List<Task> getEventsFromTask(CalendarInput cInput, String startDate, String endDate){
		List<Task> lTask = new List<Task>();

		// Build the query
		String query = '';
		query += 'SELECT Id, Subject, OwnerId, Owner.Name, ActivityDate,';
		query += 'Description, WhoId, Who.Name, WhatId, What.Name, ';
		
		if(cInput.hasCompleteField && !String.isBlank(cInput.fieldComplete)){
			query += cInput.fieldComplete;
			query += ', ';
		}

		query = query.trim().removeEnd(',');
		
		query = query + ' FROM Task ';
		
		String whereClause = ' WHERE ActivityDate >= ' + String.escapeSingleQuotes(startDate) + ' AND ActivityDate <= ' + String.escapeSingleQuotes(endDate) + ' ';
		
		list<String> listId = new list<String>();
		if(cInput.ids != null && cInput.ids.size() > 0) listId.addAll(getUsersIdByRole(cInput.ids));
		
		if(cInput.firstCall && (listId == null || listId.size() == 0)){
			listId.add(UserInfo.getUserId());
		}
		
		whereClause += ' AND OwnerId IN :listId ';
		
		query += whereClause;
		
		String color = cInput.color;

		// Query for the records
		lTask = Database.query(query);

		return lTask;
	}

	/**
	* @description data render to CalendarEvent List
	* @author seonju.jin@dkbmc.com | 2020-11-13 
	* @param List<Task> lTask Task List
	* @return List<CalendarEvent> 
	**/
	public static List<CalendarEvent> rednerEvents(CalendarInput cInput, List<Task> lTask){
		List<CalendarEvent> events = new List<CalendarEvent>();

		if(lTask != null && lTask.size() > 0){
			for(Task ev : lTask){
				CalendarEvent cEvent = new CalendarEvent();
				
				cEvent.objId			= ev.Id;
				cEvent.Subject			= ev.Subject;
				cEvent.OwnerId			= ev.OwnerId;
				cEvent.Owner			= ev.Owner.Name;
				cEvent.ActivityDate		= ev.ActivityDate == null ? '' : String.valueOf(ev.ActivityDate);
				cEvent.ActivityDateTime	= ev.ActivityDate == null ? '' : String.valueOf(ev.ActivityDate);
				cEvent.StartDateTime	= ev.ActivityDate == null ? '' : String.valueOf(ev.ActivityDate);
				cEvent.EndDateTime		= ev.ActivityDate == null ? '' : String.valueOf(ev.ActivityDate);
				cEvent.Description		= ev.Description == null ? '' : ev.Description;
				cEvent.WhoId			= ev.WhoId == null ? '' : ev.WhoId;
				cEvent.Who				= ev.WhoId == null ? '' : ev.Who.Name;
				cEvent.WhatId			= ev.WhatId == null ? '' : ev.WhatId;
				cEvent.What				= ev.WhatId == null ? '' : ev.What.Name;

				cEvent.url				= cInput.useUrl ? '#/sObject/' + ev.Id + '/view' : '';
				cEvent.className		= cInput.className;
				cEvent.editable			= cInput.editable;
				cEvent.color			= '#D77F6E'; // '#8BBDFF';
				cEvent.backgroundColor	= cInput.backgroundColor;
				cEvent.borderColor		= cInput.borderColor;
				cEvent.textColor		= cInput.textColor;
				cEvent.type				= 'Task';
				
				events.add(cEvent);
			}
		}

		return events;
	}


	/**
	* @description select event
	* @author seonju.jin@dkbmc.com | 2020-11-13 
	* @param CalendarInput cInput CalendarInput
	* @param String startDate 이벤트 시작일
	* @param String endDate 이벤트 종료일
	* @return List<Task> TaskList
	**/
	public static List<AccountPlan__c> getEventsFromAcctPlan(CalendarInput cInput, String startDate, String endDate){
		List<AccountPlan__c> lAccountPlan = new List<AccountPlan__c>();

		// Build the query
		String query = '';
		query += 'SELECT Id, Name, AccountId__c, AccountId__r.Name, OwnerId, Owner.Name, ';
		query += 'StartDateTime__c, EndDateTime__c, Description__c, ';
		
		if(cInput.hasCompleteField && !String.isBlank(cInput.fieldComplete)){
			query += cInput.fieldComplete;
			query += ', ';
		}

		query = query.trim().removeEnd(',');
		
		query = query + ' FROM AccountPlan__c ';
		
		// String whereClause = ' WHERE StartDateTime__c >= ' + startDate + ' AND EndDateTime__c <= ' + endDate + ' ';
		String whereClause = ' WHERE StartDateTime__c >= ' + startDate + ' AND StartDateTime__c <= ' + endDate + ' ';
		
		list<String> listId = new list<String>();
		if(cInput.ids != null && cInput.ids.size() > 0) listId.addAll(getUsersIdByRole(cInput.ids));
		
		if(cInput.firstCall && (listId == null || listId.size() == 0)){
			listId.add(UserInfo.getUserId());
		}
		
		whereClause += ' AND OwnerId IN :listId ';
		
		query += whereClause;
		
		String color = cInput.color;

		// Query for the records
		lAccountPlan = Database.query(query);

		return lAccountPlan;
	}

	/**
	* @description data render to CalendarEvent List
	* @author seonju.jin@dkbmc.com | 2020-11-13 
	* @param List<AccountPlan__c> lacctPlan AccountPlan List
	* @return List<CalendarEvent> 
	**/
	public static List<CalendarEvent> rednerEvents(CalendarInput cInput, List<AccountPlan__c> lacctPlan){
		List<CalendarEvent> events = new List<CalendarEvent>();

		if(lacctPlan != null && lacctPlan.size() > 0){
			for(AccountPlan__c ev : lacctPlan){
				CalendarEvent cEvent = new CalendarEvent();
				
				cEvent.objId			= ev.Id;
				cEvent.Subject			= ev.Name;
				cEvent.OwnerId			= ev.OwnerId;
				cEvent.Owner			= ev.Owner.Name;
				cEvent.ActivityDate		= ev.StartDateTime__c != null ? ev.StartDateTime__c.format('yyyy-MM-dd').replace(' ', 'T') : '';
				cEvent.ActivityDateTime	= ev.StartDateTime__c != null ? ev.StartDateTime__c.format('yyyy-MM-dd HH:mm:ss').replace(' ', 'T') : '';
				cEvent.StartDateTime	= ev.StartDateTime__c != null ? ev.StartDateTime__c.format('yyyy-MM-dd HH:mm:ss').replace(' ', 'T') : '';
				cEvent.EndDateTime		= ev.EndDateTime__c != null ? ev.EndDateTime__c.format('yyyy-MM-dd HH:mm:ss').replace(' ', 'T') : '';
				cEvent.WhatId			= ev.AccountId__c == null ? '' : ev.AccountId__c;
				cEvent.What				= ev.AccountId__r.Name == null ? '' : ev.AccountId__r.Name;
				cEvent.Description		= ev.Description__c;

				cEvent.url				= cInput.useUrl ? '#/sObject/' + ev.Id + '/view' : '';
				cEvent.className		= cInput.className;
				cEvent.editable			= cInput.editable;
				cEvent.color			= '#73A598'; // '#C4BC4B';
				cEvent.backgroundColor	= cInput.backgroundColor;
				cEvent.borderColor		= cInput.borderColor;
				cEvent.textColor		= cInput.textColor;
				cEvent.type			= 'Account Plan';
				
				events.add(cEvent);
			}
		}

		return events;
	}


		/**
	* @description select event
	* @author seonju.jin@dkbmc.com | 2020-11-13 
	* @param CalendarInput cInput CalendarInput
	* @param String startDate 이벤트 시작일
	* @param String endDate 이벤트 종료일
	* @return List<Task> TaskList
	**/
	public static List<Opportunity_Activity__c> getEventsFromOpportAcct(CalendarInput cInput, String startDate, String endDate){
		List<Opportunity_Activity__c> lOpprtAct = new List<Opportunity_Activity__c>();

		// Build the query
		String query = '';
		query += 'SELECT Id, Name, WhatId__r.OwnerId, WhatId__r.Owner.Name,  ';
		query += 'StartDate__c,EndDate__c, Description__c, WhatId__c, WhatId__r.Name, ';
		
		if(cInput.hasCompleteField && !String.isBlank(cInput.fieldComplete)){
			query += cInput.fieldComplete;
			query += ', ';
		}

		query = query.trim().removeEnd(',');
		
		query += ' FROM Opportunity_Activity__c ';
		
		// String whereClause = ' WHERE StartDate__c >= ' + startDate + ' AND EndDate__c <= ' + endDate + ' ';
		String whereClause = ' WHERE StartDate__c >= ' + startDate + ' AND StartDate__c <= ' + endDate + ' ';
		
		list<String> listId = new list<String>();
		if(cInput.ids != null && cInput.ids.size() > 0) listId.addAll(getUsersIdByRole(cInput.ids));
		
		if(cInput.firstCall && (listId == null || listId.size() == 0)){
			listId.add(UserInfo.getUserId());
		}

		whereClause += ' AND WhatId__r.OwnerId IN :listId ';
		
		query += whereClause;
		
		String color = cInput.color;

		// Query for the records
		lOpprtAct = Database.query(query);

		return lOpprtAct;
	}

	/**
	* @description data render to CalendarEvent List
	* @author seonju.jin@dkbmc.com | 2020-11-13 
	* @param List<Opportunity_Activity__c> lacctPlan Opportunity_Activity__c List
	* @return List<CalendarEvent> 
	**/
	public static List<CalendarEvent> rednerEvents(CalendarInput cInput, List<Opportunity_Activity__c> lacctPlan){
		List<CalendarEvent> events = new List<CalendarEvent>();

		if(lacctPlan != null && lacctPlan.size() > 0){
			for(Opportunity_Activity__c ev : lacctPlan){
				CalendarEvent cEvent = new CalendarEvent();
				
				cEvent.objId			= ev.Id;
				cEvent.Subject			= ev.Name;
				cEvent.OwnerId			= ev.WhatId__r.OwnerId;
				cEvent.Owner			= ev.WhatId__r.Owner.Name;
				cEvent.ActivityDate		= ev.StartDate__c  == null ? '' : String.valueOf(ev.StartDate__c);
				cEvent.ActivityDateTime	= ev.StartDate__c  == null ? '' : String.valueOf(ev.StartDate__c);
				cEvent.StartDateTime	= ev.StartDate__c  == null ? '' : String.valueOf(ev.StartDate__c);
				cEvent.EndDateTime		= ev.EndDate__c  == null ? '' 	: String.valueOf(ev.EndDate__c);

				cEvent.Description		= ev.Description__c == null ? '' : ev.Description__c;
				cEvent.WhatId			= ev.WhatId__c == null ? '' : ev.WhatId__c;
				cEvent.What				= ev.WhatId__c == null ? '' : ev.WhatId__r.Name;

				cEvent.url				= cInput.useUrl ? '#/sObject/' + ev.Id + '/view' : '';
				cEvent.className		= cInput.className;
				cEvent.editable			= cInput.editable;
				cEvent.color			= '#A9BC8B'; // '#86E57F';
				cEvent.backgroundColor	= cInput.backgroundColor;
				cEvent.borderColor		= cInput.borderColor;
				cEvent.textColor		= cInput.textColor;
				cEvent.type				= 'Opportunity Activity';
				
				events.add(cEvent);
			}
		}

		return events;
	}

	public static DateTime convertDateToDateTime(Date dt){
		Integer d = dt.day();
		Integer m = dt.month();
		Integer yr = dt.year();

		return DateTime.newInstance(yr, m, d);
	}

	global class SetId {
		@AuraEnabled
		global	Boolean		isRoleId	{ get; set; }
		@AuraEnabled
        global	String		UserOrRoleId	{ get; set; }
	}

    /**
	 *	Class CalendarEvent --> Hold calendar event data --> Very specific to the Calendar Component
	 */
	global class CalendarEvent {
		@AuraEnabled
		global	String			objId				{ get; set; }
		@AuraEnabled
		global	String			Subject				{ get; set; }
		@AuraEnabled
		global	String			OwnerId				{ get; set; }
		@AuraEnabled
		global	String			Owner				{ get; set; }
		@AuraEnabled
		global	String			ActivityDate		{ get; set; }
		@AuraEnabled
		global	String			ActivityDateTime	{ get; set; }
		@AuraEnabled
		global	String			StartDateTime		{ get; set; }
		@AuraEnabled
		global	String			EndDateTime			{ get; set; }
		@AuraEnabled
		global	String			EventSubtype		{ get; set; }
		@AuraEnabled
		global	String			Location			{ get; set; }
		@AuraEnabled
		global	String			Description			{ get; set; }
		@AuraEnabled
		global	String			WhoId				{ get; set; }
		@AuraEnabled
		global	String			Who					{ get; set; }
		@AuraEnabled
		global	String			WhatId				{ get; set; }
		@AuraEnabled
		global	String			What				{ get; set; }
		@AuraEnabled
		global	Integer			DurationInMinutes	{ get; set; }
		@AuraEnabled
		global	String			ShowAs				{ get; set; }
		@AuraEnabled
		global	Boolean			IsPrivate			{ get; set; }
		@AuraEnabled
		global	Boolean			IsAllDayEvent		{ get; set; }

		@AuraEnabled
		global	String			url					{ get; set; }
		@AuraEnabled
		global	String			className			{ get; set; }
		@AuraEnabled
		global	Boolean			editable			{ get; set; }
		@AuraEnabled
		global	String			color				{ get; set; }
		@AuraEnabled
		global	String			backgroundColor		{ get; set; }
		@AuraEnabled
		global	String			borderColor			{ get; set; }
		@AuraEnabled
		global	String			textColor			{ get; set; }
		@AuraEnabled
		global	String			type				{ get; set; }
	}

	/**
	 *	Class CalendarInput --> Input class type for Calendar Input, specific to calendar.cmp
	 */
	global class CalendarInput {

		@AuraEnabled
		public	Boolean			firstCall			{ get; set; }
		@AuraEnabled
		public	String			startDate			{ get; set; }
		@AuraEnabled
		public	String			endDate				{ get; set; }
		@AuraEnabled
		public	Boolean			hasCompleteField	{ get; set; }
		@AuraEnabled
		public	String			fieldComplete		{ get; set; }
		@AuraEnabled
        public	Boolean			isRoleId			{ get; set; }
		@AuraEnabled
        public	List<String>	ids					{ get; set; }

		@AuraEnabled
		public	String			className			{ get; set; }
		@AuraEnabled
		public	Boolean			editable			{ get; set; }
		@AuraEnabled
		public	Boolean			useUrl				{ get; set; }
		@AuraEnabled
		public	String			color				{ get; set; }
		@AuraEnabled
		public	String			backgroundColor		{ get; set; }
		@AuraEnabled
		public	String			borderColor			{ get; set; }
		@AuraEnabled
		public	String			textColor			{ get; set; }
		@AuraEnabled
		public List<String>		types				{ get; set;}

	}

	global class CalendarException extends Exception {}

}