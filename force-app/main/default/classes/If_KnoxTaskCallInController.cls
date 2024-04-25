global class If_KnoxTaskCallInController {
    private static final String INTERFACE_ID = 'IF-190';
    private static final String APEX_CLASS   = 'If_KnoxTaskCallInController';
    private static final String METHOD_NAME  = 'getknoxcalendarList';
    private static String guId = IF_Util.generateGuid();
    private static Integer errorCount = 0;
    public static Map<String,Object> resMap = new Map<String,Object>();
    
    
    global static String getknoxcalendarList(){
        IF_Log ifLog = new IF_Log();
        IF_Log.InterfaceLog interfaceLog; 
        String Usercalendarid='';
        try{
            String UserEmail = UserINfo.getUserEmail();
            List<String> parts = UserEmail.split('@');
             String userName = parts[0]; 
            IF_Callout call = new IF_Callout(INTERFACE_ID);          
            String urlParam = '?' +'userId='+ userName;              
            resMap = call.httpKnoxCallout('', urlParam);
            System.debug('request : '+resMap.get('Request')); 
            System.debug('response 1: '+resMap.get('Response'));
            HttpResponse response = (HttpResponse)resMap.get('HttpResponse');
            System.debug('response 2: '+ response.getBody());    
            String jsonResponse = response.getBody();
             Map<String,Object> deserailse = (Map<String,Object>)JSON.deserializeUntyped(jsonResponse);

            system.debug('jsonResponse____2' + jsonResponse);    
            system.debug('Response3' + response.getStatusCode());
            system.debug('Response4' + deserailse);
            
            if(response.getStatusCode() == 200){
                //SJOSHI Start
        	  List<Object> jsonMap1 = new List<Object>();
                if(!Test.isRunningTest()){
                  // jsonMap = (List<Object>)JSON.deserializeUntyped(jsonResponse); 
                    for(Object inst : (List<object>)deserailse.get('data')){
                        system.debug('instvalue'+inst);
                        jsonMap1.add((Map<String,object>)inst);
                    }
		        }
                else{
                   jsonMap1.add(JSON.deserializeUntyped(jsonResponse));
                }
                //SJOSHI End          
                system.debug('jsonResponse____1' + jsonMap1);
                InputHeader inputData = new InputHeader();
                for(Object record : jsonMap1){
                    Map<String,Object> objMap = (Map<String,Object>)record;
                    system.debug('objMap____' + objMap.get('calendarId'));
                    if(objMap.containsKey('calendarId') && objMap.get('subject') =='mySales_Event'){
                        system.debug('mySalesId___'+ objMap.get('calendarId'));
                       inputData.userKnoxCalendarId = String.valueof(objMap.get('calendarId'));                        
                    }
                }
                system.debug('mySalesIdcal___'+ inputData.userKnoxCalendarId);
                if(inputData.userKnoxCalendarId != null){
                                    Usercalendarid = inputData.userKnoxCalendarId;
                }
              /* User loginUser = [Select Id,CalendarID__c from User Where Id=:UserINfo.getUserId()];
                String usercalendrid = loginUser.CalendarID__c;
                loginUser.CalendarID__c = inputData.userKnoxCalendarId;
                if(loginUser.CalendarID__c!= Null && String.isNotBlank(loginUser.CalendarID__c)){
                    if(loginUser.CalendarID__c != usercalendrid){
                   Update loginUser;
                    }
                }
                if(usercalendrid !='' && (inputData.userKnoxCalendarId == '' || inputData.userKnoxCalendarId == null )){
                    loginUser.CalendarID__c ='';
                    Update loginUser;
                } */
            }                
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));            
        }
        catch(Exception e){               
            ifLog.addLog('Exception : ' + e.getMessage());                         
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')), e);          
        }
      // ifLog.createLog(interfaceLog); 
        return Usercalendarid;
    }
    global static String getknoxcalendarListTask(){
        IF_Log ifLog = new IF_Log();
        IF_Log.InterfaceLog interfaceLog; 
        String Usercalendarid='';
        try{
            String UserEmail = UserINfo.getUserEmail();
            List<String> parts = UserEmail.split('@');
             String userName = parts[0]; 
            IF_Callout call = new IF_Callout(INTERFACE_ID);          
            String urlParam = '?' +'userId='+ userName;              
            resMap = call.httpKnoxCallout('', urlParam);
            System.debug('request : '+resMap.get('Request')); 
            System.debug('response 1: '+resMap.get('Response'));
            HttpResponse response = (HttpResponse)resMap.get('HttpResponse');
            System.debug('response 2: '+ response.getBody());    
            String jsonResponse = response.getBody();
             Map<String,Object> deserailse = (Map<String,Object>)JSON.deserializeUntyped(jsonResponse);

            system.debug('jsonResponse____2' + jsonResponse);    
            system.debug('Response3' + response.getStatusCode());
            system.debug('Response4' + deserailse);
            
            if(response.getStatusCode() == 200){
                //SJOSHI Start
        	  List<Object> jsonMap1 = new List<Object>();
                if(!Test.isRunningTest()){
                  // jsonMap = (List<Object>)JSON.deserializeUntyped(jsonResponse); 
                    for(Object inst : (List<object>)deserailse.get('data')){
                        system.debug('instvalue'+inst);
                        jsonMap1.add((Map<String,object>)inst);
                    }
		        }
                else{
                   jsonMap1.add(JSON.deserializeUntyped(jsonResponse));
                }
                //SJOSHI End          
                system.debug('jsonResponse____1' + jsonMap1);
                InputHeader inputData = new InputHeader();
                for(Object record : jsonMap1){
                    Map<String,Object> objMap = (Map<String,Object>)record;
                    system.debug('objMap____' + objMap.get('calendarId'));
                    if(objMap.containsKey('calendarId') && objMap.get('subject') =='mySales_task'){
                        system.debug('mySalesId___'+ objMap.get('calendarId'));
                       inputData.userKnoxCalendarId = String.valueof(objMap.get('calendarId'));                        
                    }
                }
                system.debug('mySalesIdcal___'+ inputData.userKnoxCalendarId);
                if(inputData.userKnoxCalendarId != null){
                                    Usercalendarid = inputData.userKnoxCalendarId;
                }
              /* User loginUser = [Select Id,CalendarID__c from User Where Id=:UserINfo.getUserId()];
                String usercalendrid = loginUser.CalendarID__c;
                loginUser.CalendarID__c = inputData.userKnoxCalendarId;
                if(loginUser.CalendarID__c!= Null && String.isNotBlank(loginUser.CalendarID__c)){
                    if(loginUser.CalendarID__c != usercalendrid){
                   Update loginUser;
                    }
                }
                if(usercalendrid !='' && (inputData.userKnoxCalendarId == '' || inputData.userKnoxCalendarId == null )){
                    loginUser.CalendarID__c ='';
                    Update loginUser;
                } */
            }                
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));            
        }
        catch(Exception e){               
            ifLog.addLog('Exception : ' + e.getMessage());                         
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')), e);          
        }
       // ifLog.createLog(interfaceLog); 
        return Usercalendarid;
    }
    @auraEnabled
    public static Map<String, String> getAllKnoxCalendarList(){

        IF_Log ifLog = new IF_Log();
        IF_Log.InterfaceLog interfaceLog; 
        Map<String, String> calendarMap = new Map<String, String>();

        try{
            String UserEmail = UserINfo.getUserEmail();
            List<String> parts = UserEmail.split('@');
            String userName = parts[0]; 
            IF_Callout call = new IF_Callout(INTERFACE_ID);          
            String urlParam = '?' +'userId='+ userName;              
            resMap = call.httpKnoxCallout('', urlParam);
            System.debug('request : '+resMap.get('Request')); 
            System.debug('response 1: '+resMap.get('Response'));
            HttpResponse response = (HttpResponse)resMap.get('HttpResponse');
            System.debug('response 2: '+ response.getBody());    
            String jsonResponse = response.getBody();
            Map<String,Object> deserailse = (Map<String,Object>)JSON.deserializeUntyped(jsonResponse);

            system.debug('jsonResponse____2' + jsonResponse);    
            system.debug('Response3' + response.getStatusCode());
            system.debug('Response4' + deserailse);
            
            List<Object> jsonMap1 = new List<Object>();
            
            if(response.getStatusCode() == 200){
        	    
                if(!Test.isRunningTest()){
                    
                    for(Object inst : (List<object>) deserailse.get('data')){
                        
                        Map<String,Object> record = (Map<String,Object>) inst;
                        String calendarId = String.valueOf(record.get('calendarId'));
                        String color = String.valueOf(record.get('color'));    
                        
                        calendarMap.put(calendarId, color);
                    }
		        }
                
            }                
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));            
        }
        catch(Exception e){               
            ifLog.addLog('Exception : ' + e.getMessage());                         
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')), e);          
        }
        ifLog.createLog(interfaceLog); 
        return calendarMap;
    }


    global class InputHeader{
    public String userKnoxCalendarId;
    }
}