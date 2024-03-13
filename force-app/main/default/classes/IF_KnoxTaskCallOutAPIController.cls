/**
* @description       : Rest API Callout to Interact 
* @author            : saurav.k@partner.samsung.com
* @group             : 

* @last modified on  : 04/08/2023
* @last modified by  : saurav.k@partner.samsung.com
* Modifications Log 
* Ver   Date         Author                          Modification
* 1.0   04/08/2023   saurav.k@partner.samsung.com    Initial Version
**/
public class IF_KnoxTaskCallOutAPIController implements Database.AllowsCallouts {  
    @future(callout=true)
    //create knox calendar
    Public Static void  doCalloutCreatemySalesKnoxCalender(Id eventNewId){
        String APEX_CLASS   = 'IF_KnoxTaskCallOutAPIController';
        String METHOD_NAME_190  = 'doCalloutCreatemySalesKnoxCalender';
        String INTERFACE_ID_190 = 'IF-191';
        Map<String,Object> resMap = new Map<String,Object>();
        IF_Log log = new IF_Log();
        String guId = '';
        IF_Callout call;
        String jsonBody = '';
        HttpResponse Response;
        call = new IF_Callout(INTERFACE_ID_190);
        List<calenderCreation> calenderList = new  List<calenderCreation>();
        String UserEmail = USerINfo.getUserEmail();
        List<String> parts = UserEmail.split('@');
        String userName = parts[0];
        calenderCreation cC = new calenderCreation();
        cC.defaultYn = null;
        cC.displayType = 'VISIBLE';
        cC.calendarId = null;
        cC.color = '#ffc71b';
        cC.subject = 'mySales';
        cC.timezone = 'Asia/Seoul';
        cC.authority = null;
        cC.description = 'mySales Calendar';
        cC.type = 'NORMAL';
        cC.userId = userName;
        cC.seq = null;        
        jsonBody = JSON.serialize(cC);
        system.debug('Demand Response jsonBody : '+ jsonBody);
        String urlParam = '';
        //String urlParam = '?' +'userId='+ userName;

        user u = [Select Id,CalendarID__c FROM User WHERE ID =:USerINfo.getUserId()];
        if(u.CalendarID__c == Null && String.isBlank(u.CalendarID__c)){
            resMap = call.httpKnoxCallout(jsonBody, urlParam);        
            system.debug('res____________________' + resMap);
            Response = (HttpResponse)resMap.get('HttpResponse');    
            System.debug('response : '+resMap.get('Response'));
            String jsonResponse = response.getBody();
             System.debug('response__________ '+jsonResponse);
            if(response.getStatusCode() == 200){
                Map<String,Object> jsonMap = (Map<String,Object>)JSON.deserializeUntyped(jsonResponse);
                 Map<String,Object> dMap = (Map<String,Object>) jsonMap.get('data');

                System.debug('response__________ '+jsonMap);
                InputHeader inputData = new InputHeader();
                
                //SJOSHI Start
                System.debug('dMap01'+dMap);
                if(!Test.isRunningTest()){
                    if(dMap.containsKey('calendarId') && dMap.get('subject') =='mySales'){
                    inputData.userKnoxCalendarId = String.valueof(dMap.get('calendarId')); 
                	}
                }
                else{
                    inputData.userKnoxCalendarId = 'TEST123'; 
                }
                //SJOSHI End
                
                User loginUser = [Select Id,CalendarID__c from User Where Id=:UserINfo.getUserId()];
                loginUser.CalendarID__c = inputData.userKnoxCalendarId;
                if(loginUser.CalendarID__c!= Null && String.isNotBlank(loginUser.CalendarID__c)){
                   Update loginUser;
                }
                
            }
            System.enqueueJob(new knoxCreateScheduleQuableClass(eventNewId));
        }else{
            System.debug('mySales Calendar already exist for current user');
            System.enqueueJob(new knoxCreateScheduleQuableClass(eventNewId));
        }        
        IF_Log.InterfaceLog ifLog;
        ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_190, guId, APEX_CLASS, METHOD_NAME_190, String.valueOf(calenderList), String.valueOf(resMap.get('Response')));
        ID iFLogId = log.createLog2(ifLog);
        system.debug('iFLogId **' + iFLogId);
        System.debug('After calenderList'+calenderList); 
      //  return   true;     
    }           
    Public class calenderCreation{
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
    public class InputHeader{
    public String userKnoxCalendarId;
    }
}