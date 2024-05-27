public class IF_DeleteKnoxCalendarCallout implements Database.AllowsCallouts{
    private static final String INTERFACE_ID = 'IF-197';
    private static final String APEX_CLASS   = 'IF_DeleteKnoxCalendarCallout';
    private static final String METHOD_NAME  = 'deleteKnoxTaskcalendarId';
    private static String guId = IF_Util.generateGuid();
    public static Map<String,Object> resMap = new Map<String,Object>();

    @future(callout=true)
    public static void deleteKnoxTaskcalendarId(){//set<Id> deleteTask
      
        IF_Log ifLog = new IF_Log();
        IF_Log.InterfaceLog interfaceLog;

        try {                        
                List<String> userEmail = UserInfo.getUserEmail().split('@');
                String userId = userEmail[0]; 

                User loginUser = [Select Id,CalendarID__c,Task_CalendarId__c,FederationIdentifier from User Where Id=:UserInfo.getUserId()];
                IF_Callout call = new IF_Callout(INTERFACE_ID);                   
              
                String urlParam = '/'+loginUser.Task_CalendarId__c+'/delete'+'?userId='+userId;           
                resMap = call.httpKnoxCallout('', urlParam);
                
                System.debug('request : '+resMap.get('Request')); 
                System.debug('response : '+resMap.get('Response'));
                HttpResponse response = (HttpResponse)resMap.get('HttpResponse');
                System.debug('response : '+resMap.get('HttpResponse'));        
                
                if(response.getStatusCode() == 200){
                 
                    interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
                    loginUser.Task_CalendarId__c = '';

                    update loginUser;
                } else {
                    interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')), new List<String>());
                }
        } catch(Exception e){   
            ifLog.addLog('Exception : ' + e.getMessage());      
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')), e);          
        }
        ifLog.createLog(interfaceLog); 
    }
}