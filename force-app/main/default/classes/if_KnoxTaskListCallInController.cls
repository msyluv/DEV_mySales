public class if_KnoxTaskListCallInController {
    private static final String INTERFACE_ID = 'IF-192';
    private static final String APEX_CLASS   = 'if_KnoxTaskListCallInController';
    private static final String METHOD_NAME  = 'getKnoxScheduleList';
    private static String guId = IF_Util.generateGuid();
    
    public static Map<String,Object> resMap = new Map<String,Object>();
    
    @auraEnabled
    public static List<IF_KnoxCalendar> getKnoxScheduleList(){
        IF_Log ifLog = new IF_Log();
        IF_Log.InterfaceLog interfaceLog;      
        
        List<String> userEmail = UserInfo.getUserEmail().split('@');
        String userId = userEmail[0];  

        User loginUser = [Select Id, CalendarID__c, FederationIdentifier, KnoxDataError__c from User Where Id=:UserInfo.getUserId()];

        List<IF_KnoxCalendar> scheduleList = new List<IF_KnoxCalendar>();

        try {
            String userTargetId = loginUser.FederationIdentifier;

            IF_Callout call = new IF_Callout(INTERFACE_ID);
            
            Date currentdate = system.today();
            
            String startDate = String.valueof(currentdate - 30);
            String queryStartDate = startDate.substring(0,10);

            String endDate = String.valueof(currentdate + 182);
            String queryEndDate = endDate.substring(0,10);

            system.debug('StartDateIF-192 ' + queryStartDate);
            system.debug('EndDateIF-192 ' + queryEndDate);

            String urlParam ='?'+'userId='+ userId+'&'+'targetId='+userTargetId+'&'+'startAt='+queryStartDate+'T12%3A00%3A00%2B09%3A00'+'&'+'endAt='+queryEndDate+'T12%3A00%3A00%2B09%3A00';
            resMap = call.httpKnoxCallout('', urlParam);
            
            System.debug('resMap : '+resMap);
            System.debug('request : '+resMap.get('Request')); 
            System.debug('response : '+resMap.get('Response'));
        	

            HttpResponse response = (HttpResponse) resMap.get('HttpResponse');
            System.debug('response : '+resMap.get('Response'));

			String jsonResponse =  response.getBody();   
            System.debug('jsonResponse : '+ jsonResponse);
            jsonResponse = jsonResponse.Replace('date','xdate');
            jsonResponse = jsonResponse.Replace('xdateTime','knoxDateTime');
            jsonResponse = jsonResponse.Replace('class','outclass');
            System.debug('jsonResponse Subin Check : '+ jsonResponse);

            if(response.getStatusCode() == 200){
                scheduleList = (List<IF_KnoxCalendar>) JSON.deserialize(jsonResponse, List<IF_KnoxCalendar>.class);
                system.debug('scheduleList : ' + scheduleList);
                
                /*
                if(Test.isRunningTest()){
                    Map<String,Object> deserailse = (Map<String,Object>) JSON.deserializeUntyped(jsonResponse);
                    system.debug('SJOSHIDes>>' + deserailse);

                    for(Object inst : (List<object>)deserailse.get('animals')){
                        jsonMap.add(inst);
        	        }

                } else {
                    for(IF_KnoxCalendar schedule : scheduleList){
                        jsonMap.add(schedule);
                    }
                }
                */

                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
                loginUser.KnoxDataError__c = 'success';
            } else {
                if(response.getStatusCode() == 403) {
                    loginUser.KnoxDataError__c = 'noknoxuser';
                }
                 
                if(response.getStatusCode() != 403){
                   loginUser.KnoxDataError__c = 'errorcoming';
                }
                system.debug('statuscodecoming'+response.getStatusCode());

                List<String> errList = new List<String>();

                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')),errList);
            }
        } catch (Exception e){
            ifLog.addLog('Exception : ' + e.getMessage());
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')), e);          
     
            loginUser.KnoxDataError__c = 'errorcoming';

        }

        ifLog.createLog(interfaceLog); 

        Update loginUser;

        return scheduleList;
    }
}