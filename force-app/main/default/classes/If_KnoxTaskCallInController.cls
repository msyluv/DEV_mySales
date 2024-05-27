global class If_KnoxTaskCallInController {
    private static final String INTERFACE_ID = 'IF-190';
    private static final String APEX_CLASS   = 'If_KnoxTaskCallInController';
    private static final String METHOD_NAME  = 'getKnoxCalendarList';
    private static String guId = IF_Util.generateGuid();
    private static Integer errorCount = 0;
    public static Map<String,Object> resMap = new Map<String,Object>();
    
    
    global static String getKnoxCalendarList(){
        IF_Log ifLog = new IF_Log();
        IF_Log.InterfaceLog interfaceLog; 
        String userKnoxCalendarId='';

        try{
            List<String> userEmail = UserInfo.getUserEmail().split('@');
            String userId = userEmail[0]; 
            String urlParam = '?' +'userId='+ userId;       

            IF_Callout call = new IF_Callout(INTERFACE_ID);                
            resMap = call.httpKnoxCallout('', urlParam);
            System.debug('request : '+resMap.get('Request')); 
            System.debug('response 1: '+resMap.get('Response'));

            HttpResponse response = (HttpResponse) resMap.get('HttpResponse');

            System.debug('response 2: '+ response.getBody());    
            String jsonResponse = response.getBody();

            List<CalendarInfo> calList = (List<CalendarInfo>) JSON.deserialize(jsonResponse, List<CalendarInfo>.class);

            system.debug('jsonResponse____2' + jsonResponse);    
            system.debug('calList___1' + calList);
            
            if(response.getStatusCode() == 200){
                
                for(CalendarInfo cal : calList){
                    if(cal.subject =='mySales_Event'){
                       userKnoxCalendarId = cal.calendarId;                        
                    }
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
        return userKnoxCalendarId;
    }
    
    global static String getKnoxCalendarListTask(){
        IF_Log ifLog = new IF_Log();
        IF_Log.InterfaceLog interfaceLog; 
        String userTaskCalendarId='';

        try{
            
            List<String> userEmail = UserInfo.getUserEmail().split('@');
            String userId = userEmail[0]; 
            String urlParam = '?' +'userId='+ userId;       

            IF_Callout call = new IF_Callout(INTERFACE_ID);          
            resMap = call.httpKnoxCallout('', urlParam);

            System.debug('request : '+resMap.get('Request')); 
            System.debug('response 1: '+resMap.get('Response'));
            HttpResponse response = (HttpResponse)resMap.get('HttpResponse');
            System.debug('response 2: '+ response.getBody());    
            String jsonResponse = response.getBody();

            List<CalendarInfo> calList = (List<CalendarInfo>) JSON.deserialize(jsonResponse, List<CalendarInfo>.class);
            
            system.debug('Response3' + response.getStatusCode());
            
            
            if(response.getStatusCode() == 200){
                
                for(CalendarInfo cal : calList){
                    if(cal.subject =='mySales_task'){
                       system.debug('mySalesId___'+ cal.calendarId);
                       userTaskCalendarId = cal.calendarId;                        
                    }
                }
            }                
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));            
        }
        catch(Exception e){               
            ifLog.addLog('Exception : ' + e.getMessage());                         
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')), e);          
        }
       
        return userTaskCalendarId;
    }

    @auraEnabled
    public static Map<String, String> getAllKnoxCalendarList(){

        IF_Log ifLog = new IF_Log();
        IF_Log.InterfaceLog interfaceLog; 
        Map<String, String> calendarMap = new Map<String, String>();

        try{
            List<String> userEmail = UserInfo.getUserEmail().split('@');
            String userId = userEmail[0]; 
            String urlParam = '?' +'userId='+ userId;       

            IF_Callout call = new IF_Callout(INTERFACE_ID);          
            resMap = call.httpKnoxCallout('', urlParam);

            System.debug('request : '+resMap.get('Request')); 
            System.debug('response 1: '+resMap.get('Response'));
            HttpResponse response = (HttpResponse)resMap.get('HttpResponse');

            System.debug('response 2: '+ response.getBody());    
            String jsonResponse = response.getBody();

            List<CalendarInfo> calList = (List<CalendarInfo>) JSON.deserialize(jsonResponse, List<CalendarInfo>.class);

            system.debug('jsonResponse____2' + jsonResponse);    
            system.debug('calList___1' + calList);
            system.debug('Response3' + response.getStatusCode());
            
            if(response.getStatusCode() == 200){
        	    
                if(!Test.isRunningTest()){  
                    for(CalendarInfo cal : calList){
                        calendarMap.put(cal.calendarId, cal.color);
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

    public class CalendarInfo{
        public String defaultYn;
        public String displayType;
        public String calendarId;
        public String color;
        public String subject;
        public String timezone;
        public String authority;
        public String description;
        public String type;
        public String userId;
        public String seq;
    }
}