/**
        * @description       : Controller Class for customFullCalendar LWC 
        * @author            : divyam.gupta@samsung.com
        * @group             : 
        * @last modified on  : 2024-05-24
        * @last modified by  : divyam.gupta@samsung.com
        * Modifications Log 
        * Ver   Date         Author                      Modification
        * 1.0   2024-05-24   divyam.gupta@samsung.com   Initial Version for MYSALES-264
        **/
public with sharing class customFullCalendarcontroller {
     @AuraEnabled(cacheable=true)
public static Map<String,List<object>> getAllEvendata() {
    Map<String,List<Object>> getalldata = new Map<String,List<Object>>();
    List<Event> eventList = [select id,IsAllDayEvent, StartDateTime, EndDateTime, Subject,CreatedBy.TimeZoneSidKey, Knox_Calendar_Id__c from Event where ownerid =: UserInfo.getUserId()];
    List<Task> tasklist = [select id,Subject,ActivityDate,Knox_Calendar_Id__c  from task where ownerid =: UserInfo.getUserId()];

    system.debug('eventlist'+eventList);
        TimeZone tz = UserInfo.getTimeZone();
                String tt = tz.getDisplayName();
                String timeOff = tt.substringBefore(')'); 
                String tzFrommySales = timeOff.substringAfter('GMT');
                system.debug('timefrom mysales'+tzFrommySales);
                String timezonehrs = tzFrommySales.substringBefore(':');
                String timezonemins = tzFrommySales.substringAfter(':');
    
    Map<String, String> calendarMap = If_KnoxTaskCallInController.getAllKnoxCalendarList();              
    for(Event eve: eventList) {
    String color = calendarMap.get(eve.Knox_Calendar_Id__c) == null ? '#87cefa' : calendarMap.get(eve.Knox_Calendar_Id__c);
    eve.Knox_Calendar_Id__c = color;
    system.debug('starttimebeforegmt'+eve.StartDateTime);
        //  eve.EndDateTime = eve.EndDateTime.dateGMT();
        if(eve.IsAllDayEvent == false){
            Datetime sdt = eve.StartDateTime;
        eve.StartDateTime = sdt.addHours(integer.valueof(timezonehrs)).addMinutes(integer.valueof(timezonemins));
        String endtime = string.valueof(eve.EndDateTime) + tzFrommySales;
        Datetime edt = eve.EndDateTime;
        eve.EndDateTime = edt.addHours(integer.valueof(timezonehrs)).addMinutes(integer.valueof(timezonemins));

        system.debug('dategmtstarttime'+eve.StartDateTime);
    } 
    else {
    /* String stime = String.valueof(eve.StartDateTime);
        
        String starttime= stime.substringBefore('T');
        eve.StartDateTime = Date.valueOf(starttime);
    String etime = String.valueof(eve.EndDateTime);
    String endtime = etime.substringBefore('T');
        eve.EndDateTime= Date.valueof(endtime); */
    Datetime edt = eve.EndDateTime;
        eve.EndDateTime = edt.addHours(24);


    }
    getalldata.put('Eventdata',eventList);
    }
    if(tasklist.size() > 0){
        for(Task tsk: tasklist){
    String color = calendarMap.get(tsk.Knox_Calendar_Id__c) == null ? '#25b3f7' : calendarMap.get(tsk.Knox_Calendar_Id__c);
    tsk.Knox_Calendar_Id__c = color;
        getalldata.put('taskdata',tasklist);
        }
    

    }
    //  return eventList;
            return getalldata;

    }
    @AuraEnabled(cacheable=true)
    public static List<Task> gettaskdata(){
        List<Task> tasklist = [select id,Subject,ActivityDate  from task where ownerid =: UserInfo.getUserId()];
        return tasklist;

    }
   @auraEnabled
    public Static Integer geteventcount(){
    List<Event> eventList = [select id,IsAllDayEvent, StartDateTime, EndDateTime, Subject,CreatedBy.TimeZoneSidKey  from Event where ownerid =: UserInfo.getUserId()];
    List<Task> tasklist = [select id,Subject,ActivityDate  from task where ownerid =: UserInfo.getUserId()];
      Integer totalcount = (eventList.size() + tasklist.size()); 
      system.debug('Totalcounteventtask'+totalcount);
    // return eventList;
       return totalcount;
    }
        @auraEnabled
    public Static String getcalendarlist(){
       String knoxcalendarid = If_KnoxTaskCallInController.getknoxcalendarList();
       return 'success';
    }

	@auraEnabled
    public static String getKnoxSchedules(){
        system.debug('hello'); 
        String jobid ='';
        User loginUser = [Select Id,CalendarID__c,FederationIdentifier,KnoxDataError__c from User Where Id=:UserINfo.getUserId() Limit 1];
        
     	List<IF_KnoxCalendar> knoxData = if_KnoxTaskListCallInController.getknoxScheduleList();

        system.debug('knoxData_______' + knoxData);  
        system.debug('recordSize' + knoxData.Size());
        
        Map<String, IF_KnoxCalendar> knoxScheduleMap = New Map<String, IF_KnoxCalendar>();
        Map<String,String> endDateTimeMap = New Map<String,String>();
        Map<String,String> endDateMap = New Map<String,String>();
        Map<String,String> startDateTimeMap = New Map<String,String>();
        Map<String,String> startDateMap = New Map<String,String>();
        
		List<String> knoxScheduleIdList = New List<String>();     

        String knoxScheduleId;

        if(knoxData.Size() > 0){
            for(IF_KnoxCalendar record : knoxData){            	
                
                knoxScheduleId = record.scheduleId;
                system.debug('KnoxSchedulId_______' + knoxScheduleId);

                knoxScheduleIdList.add(knoxScheduleId);
                knoxScheduleMap.put(knoxScheduleId, record);                                 


                endDateTimeMap.put(knoxScheduleId, record.endTime.knoxDateTime);
                endDateMap.put(knoxScheduleId, record.endTime.xdate);
                startDateTimeMap.put(knoxScheduleId, record.startTime.knoxDateTime);
                startDateMap.put(knoxScheduleId, record.startTime.xdate);
            }

            system.debug('newknoxMap' + knoxScheduleMap.Size());
            

            batch_UpsertKnoxSchedules batchInstance = new batch_UpsertKnoxSchedules(knoxScheduleMap, endDateTimeMap, endDateMap, knoxScheduleIdList, startDateTimeMap, startDateMap);

		    Id batchjobid = Database.executeBatch(batchInstance, 200);
            AsyncApexJob aaj = [Select Id, Status,JobItemsProcessed, TotalJobItems, NumberOfErrors From AsyncApexJob Where Id =: batchjobid];
            System.debug('JobId--> '+batchjobid + 'Status: '+ aaj.Status);
        
            jobid = aaj.Id;
        } else if(knoxData.Size() == 0 && loginUser.KnoxDataError__c == 'success'){
            jobid ='noSchedulepresent';
        } else {
            if(loginUser.KnoxDataError__c == 'noknoxuser'){
                jobid = 'noemprecord';
            } else if(loginUser.KnoxDataError__c == 'errorcoming'){
                jobid = 'unknownerror';
            }
        }
        return jobid;
    } 
    
    @auraEnabled
    public Static AsyncApexJob getAsnycjobStatus(String jobId){
         AsyncApexJob aaj = [Select Id, Status,JobItemsProcessed, TotalJobItems, NumberOfErrors, ExtendedStatus From AsyncApexJob Where Id =: jobId];
        String Status = aaj.Status;
        return aaj;
    }
    @auraEnabled
    public Static Datetime getWeekdate(Datetime startdatetime){
          TimeZone tz = UserInfo.getTimeZone();
                    String tt = tz.getDisplayName();
                    String timeOff = tt.substringBefore(')'); 
                    String tzFrommySales = timeOff.substringAfter('GMT');
                    system.debug('timefrom mysales'+tzFrommySales);
                    String timezonehrs = tzFrommySales.substringBefore(':');
                    String timezonemins = tzFrommySales.substringAfter(':');
           
          Datetime Evtstarttime= startdatetime.addHours(-integer.valueof(timezonehrs)).addMinutes(-integer.valueof(timezonemins));

        return Evtstarttime;
    }
    /*
        @auraEnabled
    public Static string synctasktoknox(){
        system.debug('callsyncmethod');
        List<Task> Taskinsert = new List<Task>();
        List<Task> tasklist = [select id,Knox_Calendar_Id__c, Knox_Schedule_ID__c, Subject, ActivityDate,CreatedDate,Description  from Task where ownerid =: UserInfo.getUserId()];
        for(Task tk : tasklist ){
            if((tk.Knox_Schedule_ID__c == '' || tk.Knox_Schedule_ID__c == null)){
                String knoxid =     knoxCreateScheduleTask.createtaskonknox(tk);
                tk.Knox_Schedule_ID__c = knoxid;
           Taskinsert.add(tk);
            }
        }
       if(Taskinsert.size() > 0){
            system.debug('beforecaltask');
            update tasklist;
          //  knoxCreateScheduleTask.createtaskonknox(Taskinsert);
        } 
        try {
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return 'success';
    } */

    @auraEnabled
    public Static User getuserdetail(){
            User userrec = [select id,Synchronize_task__c from user where id =: UserInfo.getUserId()];
      return userrec;
    }

    @auraEnabled
     public Static User synctaskuserrec(Boolean syncknox){
            User userrec = [select id,Synchronize_task__c,Task_CalendarId__c from user where id =: UserInfo.getUserId()];
      userrec.Synchronize_task__c = syncknox;
      if(syncknox == false){
        //  userrec.Task_CalendarId__c ='';
          IF_DeleteKnoxCalendarCallout.deleteKnoxTaskcalendarId();
          List<Task> tasklist = [select id , Knox_Schedule_ID__c,Knox_Calendar_Id__c from Task where ownerid =: UserInfo.getUserId() AND Knox_Schedule_ID__c != ''];
          List<Task> Updatelist = new List<Task>();
          for(Task tk : tasklist){
              tk.Knox_Schedule_ID__c = '';
              tk.Knox_Calendar_Id__c = '';
              Updatelist.add(tk);
          }
          if(Updatelist.size() > 0){
              update Updatelist;
          } 
    
      }
      if(userrec != null){
      update userrec;
      }
      return userrec;
    }
     @auraEnabled
     public Static String synctaskcaltoknox(){
        String knoxtaskcalid  = IF_KnoxTaskCallOutAPIController.doCalloutCreatemySalesKnoxCalenderTask();
        return knoxtaskcalid;

     }

      @auraEnabled
    public Static String deleteEventData(String eventrecdid){
        String message= '';
        try{
          Event evt = [select id from Event where id=:eventrecdid];
            delete evt;
            message = 'success';
        
        }
        catch(exception e){
            message= 'error';
        }
        return message;
    }


    @auraEnabled
    public Static String deleteTaskData(String taskrecdid){
        String message= '';
        try{
          Task tsk = [select id from Task where id=:taskrecdid];
          System.debug('task '+tsk);
            delete tsk;
            message = 'success';
        
        }
        catch(exception e){
            message= 'error';
            System.debug('error message'+e);
        }
        return message;
    }
}