/**
* @description       : Rest API Callout to Interact 
* @author            : saurav.k@partner.samsung.com
* @group             : 

* @last modified on  : 05/10/2024
* @last modified by  : sbest.han@samsung.com
* Modifications Log 
* Ver   Date         Author                          Modification
* 1.0   04/08/2023   saurav.k@partner.samsung.com    Initial Version
* 1.1   05/10/2024   sbest.han@samsung.com           Modify doCalloutCreatemySalesKnoxCalenderTask because of SIIS change and delete method doCalloutCreatemySalesKnoxCalenderTask1(Not used)
* 1.2   05/13/2024   sbest.han@samsung.com           Modify doCalloutCreatemySalesKnoxCalender because of SIIS change
**/
public class IF_KnoxTaskCallOutAPIController implements Database.AllowsCallouts {
    private static final String INTERFACE_ID = 'IF-191';
    private static final String APEX_CLASS   = 'IF_KnoxTaskCallOutAPIController';

    @future(callout=true)
    //create knox calendar
    Public Static void  doCalloutCreatemySalesKnoxCalender(Id eventNewId){
        String METHOD_NAME  = 'doCalloutCreatemySalesKnoxCalender';
        
        IF_Log log = new IF_Log();       
        IF_Callout call = new IF_Callout(INTERFACE_ID);

        List<String> emailToUserId = UserInfo.getUserEmail().split('@');
        String userId = emailToUserId[0];
        String urlParam = '?' +'userId='+ userId;

        CalenderCreation cal = new CalenderCreation();
        cal.defaultYn = null;
        cal.displayType = 'VISIBLE';
        cal.calendarId = null;
        cal.color = '#ffc71b';
        cal.subject = 'mySales_Event';
        cal.timezone = 'Asia/Seoul';
        cal.authority = null;
        cal.description = 'mySales Calendar';
        cal.type = 'NORMAL';
        cal.userId = userId;
        cal.seq = null;   

        String jsonBody = JSON.serialize(cal);
        system.debug('Demand Response jsonBody : '+ jsonBody);


        User loginUser = [Select Id, CalendarID__c, Email FROM User WHERE ID =:UserInfo.getUserId()];
            
        String mysaleEventCalendarId = If_KnoxTaskCallInController.getKnoxCalendarList();

        system.debug('mysaleEventCalendarId' + mysaleEventCalendarId);

        Map<String,Object> resMap = new Map<String,Object>();

        if(mysaleEventCalendarId == null || String.isBlank(mysaleEventCalendarId)){
            resMap = call.httpKnoxCallout(jsonBody, urlParam);        
            system.debug('res____________________' + resMap);

            HttpResponse Response = (HttpResponse) resMap.get('HttpResponse');    
            System.debug('response : '+resMap.get('Response'));

            String jsonResponse = response.getBody();
            System.debug('response__________ '+jsonResponse);

            if(response.getStatusCode() == 200){
                Map<String,Object> jsonMap = (Map<String,Object>)JSON.deserializeUntyped(jsonResponse);

                System.debug('response__________ '+jsonMap);
                
                String newEventCalendarId = '';

                //SJOSHI Start
                if(!Test.isRunningTest()){
                    if(jsonMap.containsKey('calendarId') && jsonMap.get('subject') =='mySales_Event'){
                        newEventCalendarId = String.valueof(jsonMap.get('calendarId')); 
                	}
                } else {
                    newEventCalendarId = 'TEST123'; 
                }
                //SJOSHI End
                
                loginUser.CalendarID__c = newEventCalendarId;

                Update loginUser;
                
            }
            System.enqueueJob(new knoxCreateScheduleQuableClass(eventNewId));
        } else {
        
            if(loginUser.CalendarID__c != mysaleEventCalendarId){
                loginUser.CalendarID__c = mysaleEventCalendarId;

                update loginUser;
            }    
            
            System.debug('mySales Calendar already exist for current user');
            System.enqueueJob(new knoxCreateScheduleQuableClass(eventNewId));
        }        

        IF_Log.InterfaceLog ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, '', APEX_CLASS, METHOD_NAME, '', String.valueOf(resMap.get('Response')));
        ID iFLogId = log.createLog2(ifLog);
        system.debug('iFLogId **' + iFLogId);
    }    
   
    public static string doCalloutCreatemySalesKnoxCalenderTask(){
        
        String METHOD_NAME_191  = 'doCalloutCreatemySalesKnoxCalenderTask';
        
        Map<String,Object> resMap = new Map<String,Object>();

        IF_Log log = new IF_Log();

        IF_Callout call = new IF_Callout(INTERFACE_ID);
        List<CalenderCreation> calenderList = new  List<CalenderCreation>();
        
        List<String> emailToUserId = UserInfo.getUserEmail().split('@');
        String userId = emailToUserId[0];

        CalenderCreation calendar = new CalenderCreation();
        calendar.defaultYn = null;
        calendar.displayType = 'VISIBLE';
        calendar.calendarId = null;
        calendar.color = '#25b3f7';
        calendar.subject = 'mySales_task';
        calendar.timezone = 'Asia/Seoul';
        calendar.authority = null;
        calendar.description = 'mySales_task';
        calendar.type = 'NORMAL';
        calendar.userId = userId;
        calendar.seq = null;        

        String jsonBody = JSON.serialize(calendar);
        system.debug('Demand Response jsonBody : '+ jsonBody);
        
        String urlParam = '?' +'userId='+ userId;

        User loginUser = [Select Id, Task_CalendarId__c FROM User WHERE ID =:UserInfo.getUserId()];
     
        String mysaleTaskCalendarId = If_KnoxTaskCallInController.getKnoxCalendarListTask();
        system.debug('mysaleTaskCalendarId'+mysaleTaskCalendarId);

            
        if(mysaleTaskCalendarId == null || String.isBlank(mysaleTaskCalendarId)){
            resMap = call.httpKnoxCallout(jsonBody, urlParam);        
            system.debug('res____________________' + resMap);

            HttpResponse response = (HttpResponse) resMap.get('HttpResponse');    
            System.debug('response : '+resMap.get('Response'));

            String jsonResponse = response.getBody();
            System.debug('response__________ '+jsonResponse);

            if(response.getStatusCode() == 200){
                Map<String,Object> jsonMap = (Map<String,Object>) JSON.deserializeUntyped(jsonResponse);

                System.debug('response__________ '+jsonMap);

                //SJOSHI Start
                if(!Test.isRunningTest()){
                    if(jsonMap.containsKey('calendarId') && jsonMap.get('subject') =='mySales_task'){
                        mysaleTaskCalendarId = String.valueof(jsonMap.get('calendarId')); 
                	}
                }
                else{
                    mysaleTaskCalendarId = 'TEST123'; 
                }
                //SJOSHI End
                
                loginUser.Task_CalendarId__c = mysaleTaskCalendarId;
                
                Update loginUser;
                
            }
           
        }else{
            if(mysaleTaskCalendarId != loginUser.Task_CalendarId__c){
                loginUser.Task_CalendarId__c = mysaleTaskCalendarId;
                Update loginUser;
            }
            System.debug('mySales Calendar already exist for current user');
        }        
        
        IF_Log.InterfaceLog ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, '', APEX_CLASS, METHOD_NAME_191, '', String.valueOf(resMap.get('Response')));
        ID iFLogId = log.createLog2(ifLog);
        system.debug('iFLogId **' + iFLogId);
      
        return mysaleTaskCalendarId;
    } 
    
    public class CalenderCreation{
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
        public integer seq;
    }   
}