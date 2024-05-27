public class IF_DeleteKnoxScheduleCalloutController {
    private static final String INTERFACE_ID = 'IF-196';
    private static final String APEX_CLASS   = 'IF_DeleteKnoxScheduleCalloutController';
    private static final String METHOD_NAME  = 'deleteSingleknoxSchedule';
    private static String guId = IF_Util.generateGuid();
    public static Map<String,Object> resMap = new Map<String,Object>();

    @future(callout=true)
    public static void deleteSingleKnoxSchedule(String knoxScheduleId,String knoxCalendarId){//set<Id> deleteTask
        system.debug('knoxScheduleId______' +knoxScheduleId);

        if(knoxScheduleId != null){
            IF_Log ifLog = new IF_Log();
            IF_Log.InterfaceLog interfaceLog;
            try{                        

                IF_Callout call = new IF_Callout(INTERFACE_ID);               
                
                List<String> userEmail = UserInfo.getUserEmail().split('@');
                String userId = userEmail[0]; 

                String urlParam = '/' +knoxCalendarId + '/schedules/' + knoxScheduleId + '/delete' +'?userId='+ userId;

                resMap = call.httpKnoxCallout('', urlParam);
                System.debug('request : '+resMap.get('Request')); 
                System.debug('response : '+resMap.get('Response'));
                System.debug('HttpResponse : '+resMap.get('HttpResponse'));        
                
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
            } catch(Exception e){   
                
                ifLog.addLog('Exception : ' + e.getMessage());
              
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')), e);          
            }
            ifLog.createLog(interfaceLog); 
        }
    }
}