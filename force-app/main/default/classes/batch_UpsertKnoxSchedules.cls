public class batch_UpsertKnoxSchedules implements  Database.Batchable<sObject>,Database.stateful {
    
    Public Map<String, IF_KnoxCalendar> knoxScheduleMap;
    Public Map<String,String> endDateTimeMap;
    Public Map<String,String> endDateMap;
    Public List<String> listofknoxid = New List<String>();
    Public List<String> knoxScheduleIdList = New List<String>(); 
    Public Map<String,String> startDateTimeMap;
    Public Map<String,String> startDateMap;

    public batch_UpsertKnoxSchedules(Map<String, IF_KnoxCalendar> knoxScheduleMap, Map<String,String> endDateTimeMap, Map<String,String> endDateMap, List<String> knoxScheduleIdList, Map<String,String> startDateTimeMap, Map<String,String> startDateMap) {
        
        this.knoxScheduleMap = knoxScheduleMap;
        this.endDateTimeMap = endDateTimeMap;
        this.endDateMap = endDateMap;		        
        this.knoxScheduleIdList = knoxScheduleIdList;
        this.startDateTimeMap = startDateTimeMap;
        this.startDateMap = startDateMap;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        system.debug('Username'+UserInfo.getusername());
        system.debug('batchKnoxSchedulId______' + knoxScheduleMap.keyset());
        return Database.getQueryLocator([SELECT Id,
                                                Subject,
                                                StartDateTime,
                                                EndDateTime,
                                                Location,
                                                Description,
                                                ActivityDateTime,
                                                Type,
                                                Knox_Schedule_ID__c,
                                                Isrecurrence__c,
                                                CreatedBy.Name,
                                                IsPrivate 
                                           FROM Event 
                                          WHERE Knox_Schedule_ID__c IN:knoxScheduleMap.keyset() 
                                            AND ownerid =: UserInfo.getUserId()]);
    }
    
    public void execute(Database.BatchableContext context, List<Event> scope) {
        
        if(scope != null){            
            List<Event> upsertlistofEvent = New List<Event>();                      
            for(Event e : scope){        
                System.debug('Sjoshi1>>'+e);
                System.debug('createdbyname'+e.CreatedBy.Name);
                
                listofknoxid.add(e.Knox_Schedule_ID__c);               
                IF_KnoxCalendar objMap1 = knoxScheduleMap.get(e.Knox_Schedule_ID__c);                
                system.debug('test____'+ knoxScheduleMap.get(e.Knox_Schedule_ID__c));                 

                e.Knox_Schedule_ID__c = objMap1.scheduleId;
                e.Subject = objMap1.subject;
                e.Type = objMap1.subject;

                String classevt =objMap1.outclass;

                if(classevt == 'PRIVATE'){
                    e.IsPrivate = true;
                } else {
                    e.IsPrivate = false;
                }
                
                if(objMap1.recurrence != null){
                    e.Isrecurrence__c = true;      
                } else {
                    e.Isrecurrence__c = false;
                }

                String base64Content = objMap1.contents;
                e.Description = ''; 

                if(base64Content != null && base64Content != ''){
                    String base64String = base64Content.substringAfter('Content-Transfer-Encoding: base64\n').substringBefore('\n\n');
                    
                    Blob decodeBlob;
                    String descValue;
                    if((base64String == '' || base64String == null) && base64Content.contains('html')){
                   
                        descValue = base64Content;
                    } else {
                        decodeBlob = EncodingUtil.base64Decode(base64String);
                        descValue = decodeBlob.toString();
                    }

                    system.debug('descvauebeforehtml'+descValue);
                    //Start SJOSHI[15-Dec-2023]
                    String addline = descValue.replaceAll('</p>','linex');
                    system.debug('addlinevalue'+addline);

                    String extractedText = addline.stripHTMLTags();
                    system.debug('Desccoming'+extractedText);

                    String extractedText2 = extractedText.replaceAll('linex', '\n');
                    
                    if(extractedText2 == '' || extractedText2 == null){
                        e.Description =  base64Content;
                        system.debug('Desccomingnull'+base64Content);
                    } else {
                        system.debug('descriptionmsg'+extractedText2);
                        e.Description = extractedText2;  
                    }
                    //End SJOSHI[15-Dec-2023]
                }

                e.Location = objMap1.place;
                e.Knox_Calendar_Id__c = objMap1.calendarId;
                
                if(endDateTimeMap.get(e.Knox_Schedule_ID__c) != null || objMap1.allDayYn != 'Y' ){
                    e.IsAllDayEvent = false;
                    String sUpdatedtime = startDateTimeMap.get(e.Knox_Schedule_ID__c);   
                    System.debug('Sjoshi2>>'+sUpdatedtime);
                    System.debug('Sjoshi3>>'+startDateTimeMap);
                    System.debug('Sjoshi4>>'+e.Knox_Schedule_ID__c);
                    Datetime sUpdatedDate = Datetime.valueofGmt(sUpdatedtime.replace('T',' '));
                    system.debug('testupdatedate'+sUpdatedDate);
                   
                    String eUpdatedtime = endDateTimeMap.get(e.Knox_Schedule_ID__c);                    
                    Datetime eUpdatedDate = Datetime.valueofGmt(eUpdatedtime.replace('T',' '));
                   
                    TimeZone tz = UserInfo.getTimeZone();
                    String tt = tz.getDisplayName();
                    String timeOff = tt.substringBefore(')'); 
                    String tzFrommySales = timeOff.substringAfter('GMT');
                    system.debug('tzFrommySales___________' + tzFrommySales);
                    system.debug('tt___________' + tt);
                    String stime = startDateTimeMap.get(e.Knox_Schedule_ID__c); 
                    system.debug('startDateTime_________' + startDateTimeMap.get(e.Knox_Schedule_ID__c));
                    String etime = endDateTimeMap.get(e.Knox_Schedule_ID__c);
                    system.debug('endDateTime_________' + endDateTimeMap.get(e.Knox_Schedule_ID__c));
                    String stzFromKnox;
                    if(stime.length() > 20){
                        stzFromKnox = stime.right(6); 
                    } else {
                       stzFromKnox = '+00:00';
                    }
                    system.debug('stzFromKnox___________' + stzFromKnox); 
                    String offsetmysales = tzFrommySales.replace(':','.');
                    String offsetknox = stzFromKnox.replace(':','.');
                    system.debug('offsetknox_________' + offsetknox);
                    Decimal mysalesdval = Decimal.valueof(offsetmysales);
                    Decimal knxodval = Decimal.valueof(offsetknox);
                    Decimal calcdiff  = (mysalesdval - knxodval);
                    Decimal lastval;

                    if(calcdiff > 0 || calcdiff < 0){
                        Decimal calldiff1;
                        if(calcdiff > 0){
                            calldiff1 = calcdiff - 0.40;
                        } else if(calcdiff < 0){
                            calldiff1 = calcdiff + 0.40;
                        }   
                        integer calcint = Integer.valueof(calldiff1);
                        double  pointvalue = calldiff1 - calcint;
                   
                        if(pointvalue >= 0.60){
                            lastval = calldiff1 + 0.40;
                        } else if(pointvalue <= -0.60){
                            lastval = calldiff1 - 0.40;
                        } else {
                            lastval = calldiff1;
                        }
                    } else {
                        lastval = calcdiff;
                    }

                    system.debug('Time Differnce-->'+lastval);
                    String timezoneval = String.valueof(lastval);
                    String hrscal = timezoneval.substringBefore('.');
                    String mincal = timezoneval.substringAfter('.');

                    if(lastval >= 0){
                        Datetime sDate = Datetime.valueofGmt(stime.replace('T',' ')); 
                        system.debug('sDate________' + sDate);
                        Datetime Sdatenew = sDate.addHours(integer.valueof(hrscal)).addMinutes(integer.valueof(mincal));
                        Datetime eDate = Datetime.valueofGmt(etime.replace('T',' '));
                        Datetime Edatenew  = eDate.addHours(integer.valueof(hrscal)).addMinutes(integer.valueof(mincal));
                        String addhrmins = String.valueof(mysalesdval);
                        String hrsadd = addhrmins.substringBefore('.');
                        String minsadd = addhrmins.substringAfter('.');
                        system.debug('hrsadd'+hrsadd);
                        system.debug('minsadd'+minsadd);
                        if(mysalesdval > 0){    
                            e.StartDateTime = Sdatenew.addHours(-integer.valueof(hrsadd)).addMinutes(-integer.valueof(minsadd));
                            e.EndDateTime =  Edatenew.addHours(-integer.valueof(hrsadd)).addMinutes(-integer.valueof(minsadd));
                            e.ActivityDateTime =  Sdatenew.addHours(-integer.valueof(hrsadd)).addMinutes(-integer.valueof(minsadd));
                        } else {
                            e.StartDateTime = Sdatenew.addHours(-integer.valueof(hrsadd)).addMinutes(integer.valueof(minsadd));
                            e.EndDateTime =  Edatenew.addHours(-integer.valueof(hrsadd)).addMinutes(integer.valueof(minsadd));
                            e.ActivityDateTime = Sdatenew.addHours(-integer.valueof(hrsadd)).addMinutes(integer.valueof(minsadd));
                        }
                        
                   
                        system.debug('ifStartDateTime___' +  e.StartDateTime);
                
                        system.debug('ifendDateTime___' +  e.EndDateTime);
                    } else {
                        String hrscal1 = hrscal.substringAfter('-');
                        Datetime sDate = Datetime.valueofGmt(stime.replace('T',' '));
                        system.debug('sDate________' + sDate);
                      
                        Datetime snewDate = sDate.addHours(-integer.valueof(hrscal1)).addMinutes(-integer.valueof(mincal));
                        system.debug('ifelseStartDateTime___' +  e.StartDateTime);
                        Datetime eDate = Datetime.valueofGmt(etime.replace('T',' '));
                        Datetime enewDate = eDate.addHours(-integer.valueof(hrscal1)).addMinutes(-integer.valueof(mincal)); 

                    	system.debug('ifelseStartDateTime___' +  e.EndDateTime);

                        String addhrmins = String.valueof(mysalesdval);
                        String hrsadd = addhrmins.substringBefore('.');
                        String minsadd = addhrmins.substringAfter('.');

                        if(mysalesdval > 0){    
                            e.StartDateTime = snewDate.addHours(-integer.valueof(hrsadd)).addMinutes(-integer.valueof(minsadd));
                            e.EndDateTime =  enewDate.addHours(-integer.valueof(hrsadd)).addMinutes(-integer.valueof(minsadd));
                            e.ActivityDateTime = snewDate.addHours(-integer.valueof(hrsadd)).addMinutes(-integer.valueof(minsadd));
                        } else {
                            e.StartDateTime = snewDate.addHours(-integer.valueof(hrsadd)).addMinutes(integer.valueof(minsadd));
                            e.EndDateTime =  enewDate.addHours(-integer.valueof(hrsadd)).addMinutes(integer.valueof(minsadd));
                            e.ActivityDateTime = snewDate.addHours(-integer.valueof(hrsadd)).addMinutes(integer.valueof(minsadd));
                        }
                    }
                } else {  
                    e.IsAllDayEvent = true;
                    e.StartDateTime = Date.valueof((String)(startDateMap.get(e.Knox_Schedule_ID__c)));                   
                    e.EndDateTime =  Date.valueof((String)(endDateMap.get(e.Knox_Schedule_ID__c)));
                    e.ActivityDateTime = Date.valueof((String)(endDateMap.get(e.Knox_Schedule_ID__c))); 
                }

                String datestart = String.valueof(e.StartDateTime);
                String dateend = String.valueof(e.EndDateTime);
                Date sdate;
                Date edtate;

                if(e.IsAllDayEvent == true){
                    sdate =  Date.valueof(datestart);
                    edtate = Date.valueof(dateend);
                } else {
                    sdate = Date.valueof(datestart.substringBefore('T'));
                    edtate = Date.valueof(dateend.substringBefore('T'));
                }

                Integer days = sDate.daysBetween(edtate);
                system.debug('Dayscoming'+days);
                if(days < 14) {
                    upsertlistofEvent.add(e);
                }
                
            }                                               
                update upsertlistofEvent;
            
        }
    }

    public void finish(Database.BatchableContext context) {  
        List<Event> newListEvent = New List<Event>();
        system.debug('osize________' + knoxScheduleMap.Size());
        
        system.debug('listofknoxid+++___________' + listofknoxid);
        
        List<Task> tasklist = [SELECT id,
                                      Knox_Calendar_Id__c, 
                                      Knox_Schedule_ID__c, 
                                      Subject, 
                                      ActivityDate,
                                      CreatedDate,
                                      Description,
                                      OwnerId,
                                      Owner.Email,
                                      PrivateTask__c 
                                 FROM Task 
                                WHERE OwnerId =: UserInfo.getUserId() 
                                  AND Knox_Schedule_ID__c != null];

        User userrecd = [SELECT id,
                                Synchronize_task__c,
                                Task_CalendarId__c,
                                FederationIdentifier 
                           FROM user 
                          WHERE id =: UserInfo.getUserId()];

        Map<String,Task> taskmap = new Map<String,Task>();
        List<Task> updatetasklst = new List<Task>();
        List<Task> inserttasklst = new List<Task>();

        for(task tk: tasklist){
            taskmap.put(tk.Knox_Schedule_ID__c, tk);
        }

        for(String o : knoxScheduleMap.keySet()){  
            IF_KnoxCalendar knoxdataMap = knoxScheduleMap.get(o);                                               

            if(taskmap.containsKey(o)){

                Task tsk = taskmap.get(o);
                tsk.Subject = knoxdataMap.subject;
                String classtsk = knoxdataMap.outClass;
                if(classtsk == 'PRIVATE'){
                    tsk.PrivateTask__c = true;
                } else {
                    tsk.PrivateTask__c = false;
                }

                String base64Content = knoxdataMap.contents;
                system.debug('base64String_______' + base64Content);

                if(base64Content != null && base64Content != '') {
                    String base64String = base64Content.substringAfter('Content-Transfer-Encoding: base64\n').substringBefore('\n\n');            
                    Blob decodeBlob;
                    String descValue;
                    
                    if((base64String == '' || base64String == null) && base64Content.contains('html')){
                        descValue = base64Content;
                    } else {
                        decodeBlob = EncodingUtil.base64Decode(base64String);
                        descValue = decodeBlob.toString();  
                    }

                    //Start SJOSHI[15-Dec-2023]
                    String addline = descValue.replaceAll('</p>','x');
                    //String extractedText = descValue.stripHTMLTags();
                    String extractedText = addline.stripHTMLTags();
                   	String extractedText2 = extractedText.replaceAll('x', '\n');
                    if(extractedText2 == '' || extractedText2 == null){
                       tsk.Description =  base64Content;
                    } else {
                        system.debug('descriptionmsg'+extractedText2);
                        tsk.Description = extractedText2;  
                    }
                    //End SJOSHI[15-Dec-2023]
                }

                if(knoxdataMap.allDayYn == 'Y'){
                    tsk.ActivityDate = Date.valueof((String)(startDateMap.get(o)));
                } else {
                    tsk.ActivityDate =   Date.valueof((String)(startDateTimeMap.get(o)));
                }
                updatetasklst.add(tsk);
            }
             
            
            String schedulecalid = knoxdataMap.calendarId;
            String knoxuserid = knoxdataMap.userId;
            system.debug('knoxuseridcoming'+knoxuserid);
        
            if(!listofknoxid.contains(o) && !taskmap.containsKey(o) && schedulecalid != userrecd.Task_CalendarId__c && knoxuserid == userrecd.FederationIdentifier){
                Event e = New Event();

                e.Knox_Schedule_ID__c = knoxdataMap.scheduleId;
                e.Subject = knoxdataMap.subject;
                e.Type = knoxdataMap.subject;
                e.Location = knoxdataMap.place;
                e.Knox_Calendar_Id__c = knoxdataMap.calendarId;
                String classevt = knoxdataMap.outclass;
                if(classevt == 'PRIVATE'){
                    e.IsPrivate = true;
                } else {
                    e.IsPrivate = false;
                }

                String base64Content = knoxdataMap.contents;
                system.debug('base64String_______' + base64Content);

                if(base64Content != null && base64Content != ''){
                    String base64String = base64Content.substringAfter('Content-Transfer-Encoding: base64\n').substringBefore('\n\n');
                    Blob decodeBlob;
                    String descValue;
                    if((base64String == '' || base64String == null) && base64Content.contains('html')){
                        descValue = base64Content;
                    } else {
                        decodeBlob = EncodingUtil.base64Decode(base64String);
                        descValue = decodeBlob.toString();  
                    }

                    //Start SJOSHI[15-Dec-2023]
                    String addline = descValue.replaceAll('</p>','x');
                    String extractedText = addline.stripHTMLTags();
                   	String extractedText2 = extractedText.replaceAll('x', '\n');
                    if(extractedText2 == '' || extractedText2 == null) {
                       e.Description =  base64Content;
                    } else {
                        system.debug('descriptionmsg'+extractedText2);
                        e.Description = extractedText2;  
                    }
                    //End SJOSHI[15-Dec-2023]
                }
                
                e.IsAllDayEvent = Boolean.valueof(knoxdataMap.allDayYn);
                
                if(knoxdataMap.allDayYn == 'Y' ){
                    e.IsAllDayEvent = true;
                    e.StartDateTime = Date.valueof((String)(startDateMap.get(o)));
                    system.debug('startDateTime_________' + Date.valueof((String)(endDateMap.get(o))));
                    e.EndDateTime =  Date.valueof((String)(endDateMap.get(o)));
              
                    system.debug('startDateTime_________' + Date.valueof((String)(endDateMap.get(o))));
                    e.ActivityDateTime = Date.valueof((String)(endDateMap.get(o)));
                }else{
                    e.IsAllDayEvent = false; 
                    TimeZone tz = UserInfo.getTimeZone();
                    String tt = tz.getDisplayName();
                    String timeOff = tt.substringBefore(')'); 
                    String tzFrommySales = timeOff.substringAfter('GMT');
                    system.debug('tzFrommySales___________' + tzFrommySales);
                    system.debug('tt___________' + tt);
                    String stime = startDateTimeMap.get(o); 
                    system.debug('startDateTime_________' + startDateTimeMap.get(o));
                    String etime = endDateTimeMap.get(o);
                     system.debug('endDateTime_________' + endDateTimeMap.get(o));
                    String stzFromKnox;
                    if(stime.length() > 20){
                        stzFromKnox = stime.right(6); 
                    } else {
                       stzFromKnox = '+00:00';
                    }
                    system.debug('stzFromKnox___________' + stzFromKnox); 

                    String offsetmysales = tzFrommySales.replace(':','.');
                    String offsetknox = stzFromKnox.replace(':','.');
                    system.debug('offsetknox_________' + offsetknox);
                    Decimal mysalesdval = Decimal.valueof(offsetmysales);
                    Decimal knxodval = Decimal.valueof(offsetknox);
                    Decimal calcdiff  = (mysalesdval - knxodval);
                    Decimal lastval;
                    if(calcdiff > 0 || calcdiff < 0){
                        Decimal calldiff1;
                        if(calcdiff > 0){
                            calldiff1 = calcdiff - 0.40;
                        } else if(calcdiff < 0){
                        calldiff1 = calcdiff + 0.40;
                        }   
                        integer calcint = Integer.valueof(calldiff1);
                        double  pointvalue = calldiff1 - calcint;
                   
                        if(pointvalue >= 0.60){
                            lastval = calldiff1 + 0.40;
                        } else if(pointvalue <= -0.60){
                            lastval = calldiff1 - 0.40;
                        } else {
                            lastval = calldiff1;
                        }
                    } else {
                        lastval = calcdiff;
                    }
                    system.debug('Time Differnce-->'+lastval);
                    String timezoneval = String.valueof(lastval);
                    String hrscal = timezoneval.substringBefore('.');
                    String mincal = timezoneval.substringAfter('.');
                    system.debug('hrscal-->'+hrscal);
                    system.debug('mincal-->'+mincal);

                    if(lastval >= 0){
                        Datetime sDate = Datetime.valueofGmt(stime.replace('T',' ')); 
                        system.debug('sDate________' + sDate);
                        Datetime Sdatenew = sDate.addHours(integer.valueof(hrscal)).addMinutes(integer.valueof(mincal));
                        Datetime eDate = Datetime.valueofGmt(etime.replace('T',' '));
                        Datetime Edatenew  = eDate.addHours(integer.valueof(hrscal)).addMinutes(integer.valueof(mincal));
                        String addhrmins = String.valueof(mysalesdval);
                        String hrsadd = addhrmins.substringBefore('.');
                        String minsadd = addhrmins.substringAfter('.');
                        system.debug('hrsadd'+hrsadd);
                        system.debug('minsadd'+minsadd);

                        if(mysalesdval > 0){    
                             e.StartDateTime = Sdatenew.addHours(-integer.valueof(hrsadd)).addMinutes(-integer.valueof(minsadd));
                             e.EndDateTime =  Edatenew.addHours(-integer.valueof(hrsadd)).addMinutes(-integer.valueof(minsadd));
                        } else {
                             e.StartDateTime = Sdatenew.addHours(-integer.valueof(hrsadd)).addMinutes(integer.valueof(minsadd));
                             e.EndDateTime =  Edatenew.addHours(-integer.valueof(hrsadd)).addMinutes(integer.valueof(minsadd));
                        }
                        
                   
                        system.debug('ifStartDateTime___' +  e.StartDateTime);
                
                        system.debug('ifendDateTime___' +  e.EndDateTime);
                    } else {
                        String hrscal1 = hrscal.substringAfter('-');
                        Datetime sDate = Datetime.valueofGmt(stime.replace('T',' '));
                        system.debug('sDate________' + sDate);
                      
                        Datetime snewDate = sDate.addHours(-integer.valueof(hrscal1)).addMinutes(-integer.valueof(mincal));
                        system.debug('ifelseStartDateTime___' +  e.StartDateTime);
                        Datetime eDate = Datetime.valueofGmt(etime.replace('T',' '));
                        Datetime enewDate = eDate.addHours(-integer.valueof(hrscal1)).addMinutes(-integer.valueof(mincal)); 

                    	system.debug('ifelseStartDateTime___' +  e.EndDateTime);
                        String addhrmins = String.valueof(mysalesdval);
                        String hrsadd = addhrmins.substringBefore('.');
                        String minsadd = addhrmins.substringAfter('.');
                        if(mysalesdval > 0) {
                            e.StartDateTime = snewDate.addHours(-integer.valueof(hrsadd)).addMinutes(-integer.valueof(minsadd));
                            e.EndDateTime =  enewDate.addHours(-integer.valueof(hrsadd)).addMinutes(-integer.valueof(minsadd));
                        } else {
                            e.StartDateTime = snewDate.addHours(-integer.valueof(hrsadd)).addMinutes(integer.valueof(minsadd));
                            e.EndDateTime =  enewDate.addHours(-integer.valueof(hrsadd)).addMinutes(integer.valueof(minsadd));
                        }
                    }
                }

                String datestart = String.valueof(e.StartDateTime);
                String dateend = String.valueof(e.EndDateTime);
                Date sdate;
                Date edtate;
                if(e.IsAllDayEvent == true){
                    sdate =  Date.valueof(datestart);
                    edtate = Date.valueof(dateend);
                } else {
                    sdate = Date.valueof(datestart.substringBefore('T'));
                    edtate = Date.valueof(dateend.substringBefore('T'));
                } 
                
                Integer days = sDate.daysBetween(edtate);
                system.debug('Dayscoming'+days);
                if(days < 14){
                    newListEvent.add(e);
                }
            }                        
        }
        if(newListEvent.Size()>0){
            insert newListEvent;
        }
        if(updatetasklst.size() > 0){
            upsert updatetasklst;
        }
        String useremail = UserInfo.getuserEmail();
        system.debug('getuseremailprint'+useremail);
        List<Event> deleteEventList =[SELECT Id,
                                             Knox_Schedule_ID__c,
                                             CreatedBy.Email 
                                        FROM Event 
                                       WHERE Knox_Schedule_ID__c 
                                      NOT IN:knoxScheduleMap.keyset() 
                                         AND CreatedBy.Email =:useremail];
        List<Task> deletetasklist = [SELECT Id,
                                            Knox_Schedule_ID__c 
                                       FROM Task 
                                      WHERE Knox_Schedule_ID__c 
                                     NOT IN:knoxScheduleMap.keyset() 
                                        AND CreatedBy.Email =:useremail 
                                        AND Knox_Schedule_ID__c!= null];
                                        
        if(deleteEventList.Size()>0){
            delete deleteEventList;            
        }     
        if(deletetasklist.size()>0){
            delete deletetasklist;
        }
        system.debug('finish');
    }
    
}