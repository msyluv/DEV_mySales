public with sharing class customFullCalendarcontroller {
     @AuraEnabled(cacheable=true)
    public static List<Event> getAllEvendata() {
        List<Event> eventList = [select id,IsAllDayEvent, StartDateTime, EndDateTime, Subject,CreatedBy.TimeZoneSidKey  from Event where ownerid =: UserInfo.getUserId()];
        system.debug('eventlist'+eventList);
         TimeZone tz = UserInfo.getTimeZone();
                    String tt = tz.getDisplayName();
                    String timeOff = tt.substringBefore(')'); 
                    String tzFrommySales = timeOff.substringAfter('GMT');
                    system.debug('timefrom mysales'+tzFrommySales);
                    String timezonehrs = tzFrommySales.substringBefore(':');
                    String timezonemins = tzFrommySales.substringAfter(':');

       for(Event eve: eventList) {
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
       }
        
        return eventList;
    }

   @auraEnabled
    public Static List<Event> geteventcount(){
    List<Event> eventList = [select id,IsAllDayEvent, StartDateTime, EndDateTime, Subject,CreatedBy.TimeZoneSidKey  from Event where ownerid =: UserInfo.getUserId()];
     return eventList;
    }
        @auraEnabled
    public Static String getcalendarlist(){
       String knoxcalendarid = If_KnoxTaskCallInController.getknoxcalendarList();
       return 'success';
    }
	@auraEnabled
    public Static String getKnoxSchedules(){
        system.debug('hello'); 
        String jobid ='';
         String loginUser = [Select Id,CalendarID__c from User Where Id=:UserINfo.getUserId() Limit 1].CalendarID__c;
        
        //String knoxcalendarid = If_KnoxTaskCallInController.getknoxcalendarList();
        if(loginUser != '' && loginUser != null){
     	List<Object> knoxData = if_KnoxTaskListCallInController.getknoxScheduleList();
        system.debug('knoxData_______' + knoxData);  
        String KnoxSchedulId;
        String subject;
        String contentsType;
        String contents;
        String dateTimeing;
        String datetotime;		        
        system.debug('recordSize' + knoxData.Size());
        Map<String,Map<String,Object>> newknoxMap = New Map<String,Map<String,Object>>();
        Map<String,String> newknoxMapDate = New Map<String,String>();
        Map<String,String> newknoxMapDateSingle = New Map<String,String>();
        Map<String,String> newknoxMapDateStart = New Map<String,String>();
		List<String> listofknox = New List<String>();        
        for(Object record : knoxData){            	
                Map<String,Object> objMap = (Map<String,Object>)record;            	
                Map<String,Object> objMap1 = (Map<String,Object>) objMap.get('endTime');
            	Map<String,Object> startobjMap = (Map<String,Object>) objMap.get('startTime');
                  system.debug('objMap________' + objMap);
                system.debug('objMap1________' + objMap1);
                 system.debug('startobjMap' + startobjMap);
            //    if(objMap.containsKey('calendarId') && objMap.get('calendarId') == loginUser){  
             if(objMap.containsKey('calendarId')){                   
                 
                  KnoxSchedulId =  String.valueof(objMap.get('scheduleId'));
                   listofknox.add(KnoxSchedulId);
                  newknoxMap.put(KnoxSchedulId,objMap);                 
                   subject =  String.valueof(objMap.get('subject'));
                    contentsType =  String.valueof(objMap.get('contentsType'));
                    contents =  String.valueof(objMap.get('contents'));
                    dateTimeing =  (String)objMap1.get('date_SFDC');
                    datetotime = (String)objMap1.get('dateTime_SFDC');
                    newknoxMapDate.put(KnoxSchedulId,datetotime);
                    newknoxMapDateSingle.put(KnoxSchedulId,dateTimeing);
                    newknoxMapDateStart.put(KnoxSchedulId,(String)startobjMap.get('dateTime_SFDC'));
                }
            }
        system.debug('newknoxMap' + newknoxMap.Size());
        system.debug('KnoxSchedulId_______' + KnoxSchedulId);
            system.debug('KnoxdateTimeing _______' +dateTimeing );
        system.debug('datetotime_________________' +datetotime );
        system.debug('startdatetotime_________________' +(String)newknoxMapDateStart.get(KnoxSchedulId));
        List<Event> listofEvent = [Select Id,Knox_Schedule_ID__c from Event Where Knox_Schedule_ID__c =:KnoxSchedulId];
        batch_UpsertKnoxSchedules batchInstance = new batch_UpsertKnoxSchedules(KnoxSchedulId,subject,contentsType,contents,dateTimeing,datetotime,newknoxMap,newknoxMapDate,newknoxMapDateSingle,listofknox,newknoxMapDateStart);
		Id batchjobid = Database.executeBatch(batchInstance, 200);
        AsyncApexJob aaj = [Select Id, Status,JobItemsProcessed, TotalJobItems, NumberOfErrors From AsyncApexJob Where Id =: batchjobid];
        System.debug('JobId--> '+batchjobid + 'Status: '+ aaj.Status);
        
        jobid = aaj.Id;
        }
        else {
            jobid ='nomysalescalender';
        }
        return jobid;
    } 
    
    @auraEnabled
    public Static AsyncApexJob getAsnycjobStatus(String jobId){
         AsyncApexJob aaj = [Select Id, Status,JobItemsProcessed, TotalJobItems, NumberOfErrors From AsyncApexJob Where Id =: jobId];
        String Status = aaj.Status;
        return aaj;
    }
}