public class batch_UpsertKnoxSchedules implements  Database.Batchable<sObject>,Database.stateful {
    public String KnoxSchedulId;
    public String subject;
    public String contentsType;
    public String contents;
    public String dateTimeing;
    public String datetotime;
    Public Map<String,Map<String,Object>> newknoxMap;
    Public Map<String,String> newknoxMapDate;
    Public Map<String,String>newknoxMapDateSingle;
    Public List<String> listofknoxid = New List<String>();
    Public List<String> listofknox = New List<String>(); 
    Public Map<String,String>newknoxMapDateStart;
    public batch_UpsertKnoxSchedules(String KnoxSchedulId,String subject,String contentsType,String contents,String dateTimeing,String datetotime,Map<String,Map<String,Object>> newknoxMap,Map<String,String> newknoxMapDate,Map<String,String>newknoxMapDateSingle,List<String>listofknox,Map<String,String>newknoxMapDateStart) {
        this.KnoxSchedulId = KnoxSchedulId;
        this.subject = subject;
        this.contentsType = contentsType;
        this.contents = contents;
        this.dateTimeing = dateTimeing;
        this.datetotime = datetotime;
        this.newknoxMap = newknoxMap;
        this.newknoxMapDate = newknoxMapDate;
        this.newknoxMapDateSingle = newknoxMapDateSingle;		        
        this.listofknox = listofknox;
        this.newknoxMapDateStart = newknoxMapDateStart;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        system.debug('Username'+UserInfo.getusername());
        system.debug('batchKnoxSchedulId______' + newknoxMap.keyset());
        return Database.getQueryLocator([Select Id,Subject,StartDateTime,EndDateTime,Location,Description,ActivityDateTime,Type,Knox_Schedule_ID__c,Isrecurrence__c,CreatedBy.Name FROM Event WHERE Knox_Schedule_ID__c IN:newknoxMap.keyset()]);
    }
    
    public void execute(Database.BatchableContext context, List<Event> scope) {
        
        if(scope != null){            
            List<Event> upsertlistofEvent = New List<Event>();                      
            for(Event e : scope){        
                System.debug('Sjoshi1>>'+e);
                system.debug('createdbyname'+e.CreatedBy.Name);
                listofknoxid.add(e.Knox_Schedule_ID__c);               
                Map<String,Object> objMap1 = newknoxMap.get(e.Knox_Schedule_ID__c);                
                system.debug('test____'+ newknoxMap.get(e.Knox_Schedule_ID__c));                 
                e.Knox_Schedule_ID__c = String.valueof(objMap1.get('scheduleId'));
                e.Subject = String.valueof(objMap1.get('subject'));
                e.Type = String.valueof(objMap1.get('subject'));
                 if(objMap1.containskey('recurrence')){
                      if(objMap1.get('recurrence') != null){
                          e.Isrecurrence__c = true;
                      }
                  }
                else {
                       e.Isrecurrence__c = false;
                }
                String base64Content = String.valueof(objMap1.get('contents'));
                e.Description = ''; 
                if(base64Content != null && base64Content != ''){
                    String base64String = base64Content.substringAfter('Content-Transfer-Encoding: base64\n').substringBefore('\n\n');
                    Blob decodeBlob = EncodingUtil.base64Decode(base64String);
                    String descValue = decodeBlob.toString();
                    system.debug('descvauebeforehtml'+descValue);
                    //Start SJOSHI[15-Dec-2023]
                    String addline = descValue.replaceAll('</p>','linex');
                    system.debug('addlinevalue'+addline);
                    //String extractedText = descValue.stripHTMLTags();
                    String extractedText = addline.stripHTMLTags();
                    system.debug('Desccoming'+extractedText);

                    String extractedText2 = extractedText.replaceAll('linex', '\n');
                    
                    if(extractedText2 == '' || extractedText2 == null){
                       e.Description =  base64Content;
                      system.debug('Desccomingnull'+base64Content);

                    }
                    else {
                    system.debug('descriptionmsg'+extractedText2);
                    e.Description = extractedText2;  
                    }
                    //End SJOSHI[15-Dec-2023]
                }
                e.Location = String.valueof(objMap1.get('place'));
                //e.IsAllDayEvent = Boolean.valueof(objMap1.get('allDayYn'));
                if(newknoxMapDate.get(e.Knox_Schedule_ID__c) != null || objMap1.get('allDayYn') != 'Y' ){
                    e.IsAllDayEvent = false;
                    String sUpdatedtime = newknoxMapDateStart.get(e.Knox_Schedule_ID__c);   
                    System.debug('Sjoshi2>>'+sUpdatedtime);
                    System.debug('Sjoshi3>>'+newknoxMapDateStart);
                    System.debug('Sjoshi4>>'+e.Knox_Schedule_ID__c);
                    Datetime sUpdatedDate = Datetime.valueofGmt(sUpdatedtime.replace('T',' '));
                    system.debug('testupdatedate'+sUpdatedDate);
                   // e.StartDateTime = sUpdatedDate.addHours(-9);
                    String eUpdatedtime = newknoxMapDate.get(e.Knox_Schedule_ID__c);                    
                    Datetime eUpdatedDate = Datetime.valueofGmt(eUpdatedtime.replace('T',' '));
                   // e.EndDateTime =  eUpdatedDate.addHours(-9);
                 //   e.ActivityDateTime = sUpdatedDate.addHours(-9);//Date.valueof((String)(newknoxMapDate.get(e.Knox_Schedule_ID__c)));
                    TimeZone tz = UserInfo.getTimeZone();
                    String tt = tz.getDisplayName();
                    String timeOff = tt.substringBefore(')'); 
                    String tzFrommySales = timeOff.substringAfter('GMT');
                    system.debug('tzFrommySales___________' + tzFrommySales);
                    system.debug('tt___________' + tt);
                    String stime = newknoxMapDateStart.get(e.Knox_Schedule_ID__c); 
                    system.debug('startDateTime_________' + newknoxMapDateStart.get(e.Knox_Schedule_ID__c));
                    String etime = newknoxMapDate.get(e.Knox_Schedule_ID__c);
                     system.debug('endDateTime_________' + newknoxMapDate.get(e.Knox_Schedule_ID__c));
                    String stzFromKnox;
                     if(stime.length() > 20){
                   stzFromKnox = stime.right(6); 
                    }
                    else {
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
                                        }
                      else if(calcdiff < 0){
                       calldiff1 = calcdiff + 0.40;
                                        }   
                    integer calcint = Integer.valueof(calldiff1);
                    double  pointvalue = calldiff1 - calcint;
                   
                    if(pointvalue >= 0.60){
                        lastval = calldiff1 + 0.40;
                    }
                    else if(pointvalue <= -0.60){
                        lastval = calldiff1 - 0.40;
                    }
                    else {
                        lastval = calldiff1;
                    }
                    }
                    else {
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
                        }
                        else {
                             e.StartDateTime = Sdatenew.addHours(-integer.valueof(hrsadd)).addMinutes(integer.valueof(minsadd));
                             e.EndDateTime =  Edatenew.addHours(-integer.valueof(hrsadd)).addMinutes(integer.valueof(minsadd));
                            e.ActivityDateTime = Sdatenew.addHours(-integer.valueof(hrsadd)).addMinutes(integer.valueof(minsadd));
                        }
                        
                   
                    system.debug('ifStartDateTime___' +  e.StartDateTime);
                
                    system.debug('ifendDateTime___' +  e.EndDateTime);
                    }
                    else {
                        String hrscal1 = hrscal.substringAfter('-');
                         Datetime sDate = Datetime.valueofGmt(stime.replace('T',' '));
                        system.debug('sDate________' + sDate);
                       // e.StartDateTime = sDate.addHours(-integer.valueof(hrscal1)).addMinutes(-integer.valueof(mincal));    
                        Datetime snewDate = sDate.addHours(-integer.valueof(hrscal1)).addMinutes(-integer.valueof(mincal));
                        system.debug('ifelseStartDateTime___' +  e.StartDateTime);
                        Datetime eDate = Datetime.valueofGmt(etime.replace('T',' '));
                        //e.EndDateTime = eDate.addHours(-integer.valueof(hrscal1)).addMinutes(-integer.valueof(mincal)); 
                        Datetime enewDate = eDate.addHours(-integer.valueof(hrscal1)).addMinutes(-integer.valueof(mincal)); 

                    	 system.debug('ifelseStartDateTime___' +  e.EndDateTime);
                         String addhrmins = String.valueof(mysalesdval);
                            String hrsadd = addhrmins.substringBefore('.');
                            String minsadd = addhrmins.substringAfter('.');
                        if(mysalesdval > 0){
                            
                             e.StartDateTime = snewDate.addHours(-integer.valueof(hrsadd)).addMinutes(-integer.valueof(minsadd));
                             e.EndDateTime =  enewDate.addHours(-integer.valueof(hrsadd)).addMinutes(-integer.valueof(minsadd));
                             e.ActivityDateTime = snewDate.addHours(-integer.valueof(hrsadd)).addMinutes(-integer.valueof(minsadd));
                        }
                        else {
                             e.StartDateTime = snewDate.addHours(-integer.valueof(hrsadd)).addMinutes(integer.valueof(minsadd));
                             e.EndDateTime =  enewDate.addHours(-integer.valueof(hrsadd)).addMinutes(integer.valueof(minsadd));
                            e.ActivityDateTime = snewDate.addHours(-integer.valueof(hrsadd)).addMinutes(integer.valueof(minsadd));
                        }
                    }
                }else{  
                    e.IsAllDayEvent = true;
                    e.StartDateTime = Date.valueof((String)(newknoxMapDateSingle.get(e.Knox_Schedule_ID__c)));                   
                    e.EndDateTime =  Date.valueof((String)(newknoxMapDateSingle.get(e.Knox_Schedule_ID__c)));
                  e.ActivityDateTime = Date.valueof((String)(newknoxMapDateSingle.get(e.Knox_Schedule_ID__c))); 
                }
                 upsertlistofEvent.add(e);
                
            }                                               
                update upsertlistofEvent;
            
        }
    }
    public void finish(Database.BatchableContext context) {  
        List<Event> newListEvent = New List<Event>();
        system.debug('osize________' + newknoxMap.Size());
        
        system.debug('listofknoxid+++___________' + listofknoxid);
        //system.debug('newknoxMap________' + newknoxMap);
        for(String o : newknoxMap.keySet()){           
            if(!listofknoxid.contains(o)){
                Map<String,Object> knoxdataMap = newknoxMap.get(o);                                               
                Event e = New Event();
                e.Knox_Schedule_ID__c = String.valueof(knoxdataMap.get('scheduleId'));
                
                e.Subject = String.valueof(knoxdataMap.get('subject'));
                e.Type = String.valueof(knoxdataMap.get('subject'));
                e.Location = String.valueof(knoxdataMap.get('place'));
                String base64Content = String.valueof(knoxdataMap.get('contents'));
                system.debug('base64String_______' + base64Content);
                if(base64Content != null && base64Content != ''){
                    String base64String = base64Content.substringAfter('Content-Transfer-Encoding: base64\n').substringBefore('\n\n');
                    Blob decodeBlob = EncodingUtil.base64Decode(base64String);
                    String descValue = decodeBlob.toString();
                    //Start SJOSHI[15-Dec-2023]
                    String addline = descValue.replaceAll('</p>','x');
                    //String extractedText = descValue.stripHTMLTags();
                    String extractedText = addline.stripHTMLTags();
                    
                   	String extractedText2 = extractedText.replaceAll('x', '\n');
                     if(extractedText2 == '' || extractedText2 == null){
                       e.Description =  base64Content;
                    }
                    else {
                    system.debug('descriptionmsg'+extractedText2);
                    e.Description = extractedText2;  
                    }
                    //End SJOSHI[15-Dec-2023]
                }
                e.IsAllDayEvent = Boolean.valueof(knoxdataMap.get('allDayYn'));
                //e.Location = String.valueof(knoxdataMap.get('place'));              
                system.debug('knoxdate' + knoxdataMap.get('dateTime'));                
                if(knoxdataMap.get('dateTime') != null || knoxdataMap.get('allDayYn') == 'Y' ){
                    e.IsAllDayEvent = true;
                    e.StartDateTime = Date.valueof((String)(newknoxMapDateSingle.get(o)));
                    system.debug('startDateTime_________' + Date.valueof((String)(newknoxMapDateSingle.get(o))));
                    e.EndDateTime =  Date.valueof((String)(newknoxMapDateSingle.get(o)));
                    system.debug('startDateTime_________' + Date.valueof((String)(newknoxMapDateSingle.get(o))));
                    e.ActivityDateTime = Date.valueof((String)(newknoxMapDateSingle.get(o)));
                }else{
                    e.IsAllDayEvent = false; 
                    TimeZone tz = UserInfo.getTimeZone();
                    String tt = tz.getDisplayName();
                    String timeOff = tt.substringBefore(')'); 
                    String tzFrommySales = timeOff.substringAfter('GMT');
                    system.debug('tzFrommySales___________' + tzFrommySales);
                    system.debug('tt___________' + tt);
                    String stime = newknoxMapDateStart.get(o); 
                    system.debug('startDateTime_________' + newknoxMapDateStart.get(o));
                    String etime = newknoxMapDate.get(o);
                     system.debug('endDateTime_________' + newknoxMapDate.get(o));
                    String stzFromKnox;
                    if(stime.length() > 20){
                   stzFromKnox = stime.right(6); 
                    }
                    else {
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
                                        }
                      else if(calcdiff < 0){
                       calldiff1 = calcdiff + 0.40;
                                        }   
                    integer calcint = Integer.valueof(calldiff1);
                    double  pointvalue = calldiff1 - calcint;
                   
                    if(pointvalue >= 0.60){
                        lastval = calldiff1 + 0.40;
                    }
                    else if(pointvalue <= -0.60){
                        lastval = calldiff1 - 0.40;
                    }
                    else {
                        lastval = calldiff1;
                    }
                    }
                    else {
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

                        }
                        else {
                             e.StartDateTime = Sdatenew.addHours(-integer.valueof(hrsadd)).addMinutes(integer.valueof(minsadd));
                             e.EndDateTime =  Edatenew.addHours(-integer.valueof(hrsadd)).addMinutes(integer.valueof(minsadd));
                        }
                        
                   
                    system.debug('ifStartDateTime___' +  e.StartDateTime);
                
                    system.debug('ifendDateTime___' +  e.EndDateTime);
                    }
                    else {
                        String hrscal1 = hrscal.substringAfter('-');
                         Datetime sDate = Datetime.valueofGmt(stime.replace('T',' '));
                        system.debug('sDate________' + sDate);
                       // e.StartDateTime = sDate.addHours(-integer.valueof(hrscal1)).addMinutes(-integer.valueof(mincal));    
                        Datetime snewDate = sDate.addHours(-integer.valueof(hrscal1)).addMinutes(-integer.valueof(mincal));
                        system.debug('ifelseStartDateTime___' +  e.StartDateTime);
                        Datetime eDate = Datetime.valueofGmt(etime.replace('T',' '));
                        //e.EndDateTime = eDate.addHours(-integer.valueof(hrscal1)).addMinutes(-integer.valueof(mincal)); 
                        Datetime enewDate = eDate.addHours(-integer.valueof(hrscal1)).addMinutes(-integer.valueof(mincal)); 

                    	 system.debug('ifelseStartDateTime___' +  e.EndDateTime);
                         String addhrmins = String.valueof(mysalesdval);
                            String hrsadd = addhrmins.substringBefore('.');
                            String minsadd = addhrmins.substringAfter('.');
                        if(mysalesdval > 0){
                            
                             e.StartDateTime = snewDate.addHours(-integer.valueof(hrsadd)).addMinutes(-integer.valueof(minsadd));
                             e.EndDateTime =  enewDate.addHours(-integer.valueof(hrsadd)).addMinutes(-integer.valueof(minsadd));

                        }
                        else {
                             e.StartDateTime = snewDate.addHours(-integer.valueof(hrsadd)).addMinutes(integer.valueof(minsadd));
                             e.EndDateTime =  enewDate.addHours(-integer.valueof(hrsadd)).addMinutes(integer.valueof(minsadd));
                        }
                    }
                                             
                    
                }
                
                newListEvent.add(e);
            }                        
        }
        if(newListEvent.Size()>0){
            insert newListEvent;
        }
        String useremail = UserInfo.getuserEmail();
        system.debug('getuseremailprint'+useremail);
        List<Event> deleteEventList =[Select Id,Knox_Schedule_ID__c,CreatedBy.Email FROM Event WHERE Knox_Schedule_ID__c NOT IN:newknoxMap.keyset() and CreatedBy.Email =:useremail];
        if(deleteEventList.Size()>0){
            delete deleteEventList;            
        }                   
        system.debug('finish');
    }
    
}