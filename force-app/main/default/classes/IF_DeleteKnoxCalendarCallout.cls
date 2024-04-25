public class IF_DeleteKnoxCalendarCallout implements Database.AllowsCallouts{
     private static final String INTERFACE_ID = 'IF-197';
    private static final String APEX_CLASS   = 'IF_DeleteKnoxCalendarCallout';
    private static final String METHOD_NAME  = 'deleteKnoxTaskcalendarId';
    private static String guId = IF_Util.generateGuid();
    private static Integer errorCount = 0;
    public static Map<String,Object> resMap = new Map<String,Object>();
    @future(callout=true)
    public static void deleteKnoxTaskcalendarId(){//set<Id> deleteTask
      
        IF_Log ifLog = new IF_Log();
        IF_Log.InterfaceLog interfaceLog;
        try{                        
                String UserEmail = UserINfo.getUserEmail();
                List<String> parts = UserEmail.split('@');
                String userName = parts[0]; 
                User loginUser = [Select Id,CalendarID__c,Task_CalendarId__c,FederationIdentifier from User Where Id=:UserINfo.getUserId()];
                IF_Callout call = new IF_Callout(INTERFACE_ID);               
                //need to store calendar id first in org and use on the basis of current user                                      
              //  String urlParam = '?userId='+ userName +'&'+'calendarId='+loginUser.CalendarID__c+'&'+'scheduleId='+knoxScheduleId;//inputData.userKnoxCalendarId;           
              //  String urlParam = '?userId='+ userName +'&'+'calendarId='+loginUser.Task_CalendarId__c+'&'+'scheduleId='+knoxScheduleId;//inputData.userKnoxCalendarId;    
                String urlParam = '/'+loginUser.Task_CalendarId__c+'/delete'+'?userId='+userName;           
            //    InputHeader inputHeader = new InputHeader();        
                resMap = call.httpKnoxCallout('', urlParam);
                System.debug('request : '+resMap.get('Request')); 
                System.debug('response : '+resMap.get('Response'));
                HttpResponse response = (HttpResponse)resMap.get('HttpResponse');
                System.debug('response : '+resMap.get('Response'));        
                if(response.getStatusCode() == 200){
                 //   inputHeader = (InputHeader)JSON.deserialize(response.getBody(),InputHeader.class);    
               interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
                loginUser.Task_CalendarId__c = '';
                    update loginUser;
                }
            else {
                List<String> errList = new List<String>();
                 interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')),errList);

            }
            }
        
        
            catch(Exception e){   
                
                ifLog.addLog('Exception : ' + e.getMessage());
                // errorMsgList.add('Exception : ' + e.getMessage());           
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')), e);          
            }
            ifLog.createLog(interfaceLog); 
        }
    
       
        public class InputHeader{
            public String userKnoxCalendarId; 
        }

}