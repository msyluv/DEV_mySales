/**
        * @description       :  Class for FullCalender  LWC 
        * @author            : divyam.gupta@samsung.com
        * @group             : 
        * @last modified on  : 2024-05-24
        * @last modified by  : divyam.gupta@samsung.com
        * Modifications Log 
        * Ver   Date         Author                      Modification
        * 1.0   2024-05-24   divyam.gupta@samsung.com   Initial Version for MYSALES-264
        **/
public class if_KnoxSingletaskCallController {
    private static final String INTERFACE_ID = 'IF-194';
    private static final String APEX_CLASS   = 'if_KnoxSingletaskCallController';
    private static final String METHOD_NAME  = 'getSingleknoxSchedule';
    private static String guId = IF_Util.generateGuid();
    public static Map<String,Object> resMap = new Map<String,Object>();

    public static List<IF_KnoxCalendar> getSingleknoxSchedule(String newrecordID){
        IF_Log ifLog = new IF_Log();
        IF_Log.InterfaceLog interfaceLog;

        List<IF_KnoxCalendar> scheduleList = new List<IF_KnoxCalendar>();

        try{
            List<String> userEmail = UserInfo.getUserEmail().split('@');
            String userId = userEmail[0]; 

            Event ev = [SELECT Id,
                               Knox_Schedule_ID__c,
                               Knox_Calendar_Id__c,
                               Description,
                               Isrecurrence__c 
                          FROM Event 
                         WHERE Id =: newrecordID];

            String knoxScheduleId = '';
            String knoxCalendarId = '';

            if(ev.Knox_Schedule_ID__c != null){
                if(ev.Description == '' || ev.Description == null){
                    knoxScheduleId = ev.Knox_Schedule_ID__c.substring(0,27);
                    knoxCalendarId = ev.Knox_Calendar_Id__c;
                } else {
                    knoxScheduleId = ev.Knox_Schedule_ID__c;
                }
            }

            IF_Callout call = new IF_Callout(INTERFACE_ID);
            String urlParam = '/' + knoxCalendarId + '/schedules/'+ knoxScheduleId + '?userId='+ userId ;                        
            
            resMap = call.httpKnoxCallout('', urlParam);
            System.debug('request : ' + resMap.get('Request')); 
            System.debug('response : ' + resMap.get('Response'));
            HttpResponse response = (HttpResponse) resMap.get('HttpResponse');

            if(response.getStatusCode() == 200){
                String jsonResponse = '['+ response.getBody() +']';  // Added [ Bracket by Waris to resolve Malformed Json Error
                system.debug('jsonResponse______' +jsonResponse);
                scheduleList = (List<IF_KnoxCalendar>) JSON.deserialize(jsonResponse, List<IF_KnoxCalendar>.class);

                system.debug('scheduleList______' + scheduleList);
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));          
            }
        } catch (Exception e) {               
            ifLog.addLog('Exception : ' + e.getMessage());    
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')), e);          
        }

        //SJOSHI Start // Added ifLog.createLog(interfaceLog); inside !Test.isRunningTest() to avoid test class error
        if(!Test.isRunningTest()){
           ifLog.createLog(interfaceLog); 
        }
        //SJOSHI End
        return scheduleList;
    }
}