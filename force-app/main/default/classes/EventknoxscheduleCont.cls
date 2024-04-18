public class EventknoxscheduleCont {

     @AuraEnabled
    public static String getknoxscheduledata(String eventid){
       Event eve = [Select Id,Knox_Schedule_ID__c,Description,Isrecurrence__c,recurrence_con__c,EndType__c,Count_rec__c,freqInterval__c,Frequence__c,OwnerId from Event WHERE Id =: eventid and ownerid =: UserInfo.getUserId()];
      UserRecordAccess usr =[select RecordId ,HasEditAccess from UserRecordAccess where UserId =:UserInfo.getUserId() and RecordId =: eventid];
        try{
        if(usr.HasEditAccess){    
     String descrption = '';
        String userid = UserInfo.getUserId();
        String msg = 'success';
            
      List<Object> knoxData = if_KnoxSingletaskCallController.getSingleknoxSchedule(eventid);
        system.debug('knoxdata194'+knoxData);
        system.debug('knoxDatasize'+knoxData.size());
        if(knoxData != Null &&  eve.OwnerId == userid){
        for(Object record : knoxData){   
              Map<String,Object> objMap = (Map<String,Object>)record;    
         // descrption= String.valueof(objMap.get('contents'));
           // system.debug('descrtioncoming'+descrption);
            String base64Content = String.valueof(objMap.get('contents'));
            system.debug('base64Content'+base64Content);
             if(base64Content != null && base64Content != ''){
                    String base64String = base64Content.substringAfter('Content-Transfer-Encoding: base64\n').substringBefore('\n\n');
                  Blob decodeBlob;
                 String descValue;
                 if((base64String == '' || base64String == null) && base64Content.contains('html')){
                    // String base64Stringval = base64Content.substringAfter('Content-Transfer-Encoding: base64\n');
                   //  decodeBlob = EncodingUtil.base64Decode(base64Content);
                        descValue = base64Content;
                 }
                 else {
                  decodeBlob = EncodingUtil.base64Decode(base64String);
                       descValue = decodeBlob.toString();

                 }
                    system.debug('descvauebeforehtml'+descValue);
                    //Start SJOSHI[15-Dec-2023]
                    String addline = descValue.replaceAll('</p>','linex');
                    system.debug('addlinevalue'+addline);
                    //String extractedText = descValue.stripHTMLTags();
                    String extractedText = addline.stripHTMLTags();
                    system.debug('Desccoming'+extractedText);

                    String extractedText2 = extractedText.replaceAll('linex', '\n');
                    
                    if(extractedText2 == '' || extractedText2 == null){
                       descrption =  base64Content;
                      system.debug('Desccomingnull'+base64Content);

                    }
                    else {
                    system.debug('descriptionmsg'+extractedText2);
                    descrption = extractedText2;  
                    }
                    //End SJOSHI[15-Dec-2023]
                }
            eve.Description = descrption;
            eve.IsIF_152__c = true;
            if(objMap.containskey('recurrence')){
           Map<String,Object> recurrencemap = (Map<String,Object>) objMap.get('recurrence');
                system.debug('recurrencemap'+recurrencemap);
                if(recurrencemap != null){
                    eve.Isrecurrence__c = true;
                     eve.recurrence_con__c = String.valueof(recurrencemap.get('condition'));
                     eve.EndType__c = String.valueof(recurrencemap.get('endType'));
                     eve.Count_rec__c = String.valueof(recurrencemap.get('count'));
                     eve.freqInterval__c = Integer.valueof(recurrencemap.get('freqInterval'));
                     eve.Frequence__c =  String.valueof(recurrencemap.get('freq'));
                    eve.Until_RecurrenceDate__c = String.valueof(recurrencemap.get('until'));
                }
               
            }
             else {
                 eve.Isrecurrence__c = false;

                }
        }
            update eve;
            
        }
         
        system.debug('knoxDataIF-194'+knoxData);
        }
        }
 catch(Exception e){               
          //  ifLog.addLog('Exception : ' + e.getMessage());
            // errorMsgList.add('Exception : ' + e.getMessage());           
            //interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')), e);          
        }        return 'success';
        
    }
}