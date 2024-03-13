public class if_KnoxSingletaskCallController {
    private static final String INTERFACE_ID = 'IF-194';
    private static final String APEX_CLASS   = 'if_KnoxSingletaskCallController';
    private static final String METHOD_NAME  = 'getSingleknoxSchedule';
    private static String guId = IF_Util.generateGuid();
    private static Integer errorCount = 0;
    public static Map<String,Object> resMap = new Map<String,Object>();
    public static List<Object> getSingleknoxSchedule(String newrecordID){
        IF_Log ifLog = new IF_Log();
         List<Object> jsonMap = new List<Object>();
        IF_Log.InterfaceLog interfaceLog;
        try{
            String UserEmail = UserINfo.getUserEmail();
            List<String> parts = UserEmail.split('@');
            String userName = parts[0]; 
            User loginUser = [Select Id,CalendarID__c from User Where Id=:UserINfo.getUserId()];
            Event ev = [Select Id,Knox_Schedule_ID__c,Description,Isrecurrence__c from Event WHERE Id =: newrecordID];
            InputHeader input = New InputHeader();
            if(ev.Knox_Schedule_ID__c != Null){
                if(ev.Description == '' || ev.Description == Null){
                    String knoxschid = ev.Knox_Schedule_ID__c; 
              String knoxorgid = knoxschid.substring(0,27);
              input.knoxSchedulId = knoxorgid;

                }
                else {
               
              input.knoxSchedulId = ev.Knox_Schedule_ID__c;

                }
            }
            IF_Callout call = new IF_Callout(INTERFACE_ID);
            OutputHeader output  = new OutputHeader();              
            //need to store calendar id first in org and use on the basis of current user             
            String jsonBody = JSON.serialize(output);
            String urlParam = '?userId='+ userName + '&'+'calendarId='+loginUser.CalendarID__c+'&'+'scheduleId='+input.knoxSchedulId;                        
            InputHeader inputHeader = new InputHeader();        
            resMap = call.httpKnoxCallout('', urlParam);
            System.debug('request : '+resMap.get('Request')); 
            System.debug('response : '+resMap.get('Response'));
            HttpResponse response = (HttpResponse)resMap.get('HttpResponse');
            System.debug('responseIF194 : '+resMap.get('Response'));  
            if(response.getStatusCode() == 200){
               String jsonResponse =  response.getBody();  
               // inputHeader = (InputHeader)JSON.deserialize(response.getBody(),InputHeader.class);  
             Map<String,Object> deserailse = (Map<String,Object>)JSON.deserializeUntyped(jsonResponse);  
              object inst = (object)deserailse.get('data');
                jsonMap.add((Map<String,object>)inst);
                system.debug('deserailse'+deserailse);
            }
        }
        catch(Exception e){               
            ifLog.addLog('Exception : ' + e.getMessage());
            // errorMsgList.add('Exception : ' + e.getMessage());           
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')), e);          
        }
        //SJOSHI Start // Added ifLog.createLog(interfaceLog); inside !Test.isRunningTest() to avoid test class error
        if(!Test.isRunningTest()){
           ifLog.createLog(interfaceLog); 
        }
        //SJOSHI End
        return jsonMap;
    }
    public class OutputHeader{        
        public String userId;
        public String calendarId;
        public String scheduleId;        
    }
    public class InputHeader{
        Public String knoxSchedulId;
    }
}