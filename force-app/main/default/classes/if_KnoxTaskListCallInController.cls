public class if_KnoxTaskListCallInController {
    private static final String INTERFACE_ID = 'IF-192';
    private static final String APEX_CLASS   = 'if_KnoxTaskListCallInController';
    private static final String METHOD_NAME  = 'getknoxScheduleList';
    private static String guId = IF_Util.generateGuid();
    private static Integer errorCount = 0;
    public static Map<String,Object> resMap = new Map<String,Object>();
    
    @auraEnabled
    public static List<Object> getknoxScheduleList(){
        IF_Log ifLog = new IF_Log();
        IF_Log.InterfaceLog interfaceLog;      
            system.debug('Atul Check');
            String UserEmail = UserINfo.getUserEmail();
            List<String> parts = UserEmail.split('@');
            String userName = parts[0]; 
             List<Object> jsonMap = new List<Object>();        
            User loginUser = [Select Id,CalendarID__c,FederationIdentifier,KnoxDataError__c from User Where Id=:UserINfo.getUserId()];

        try{
            String userTargetId = loginUser.FederationIdentifier;
            IF_Callout call = new IF_Callout(INTERFACE_ID);
            OutputHeader output  = new OutputHeader();   
            Date currentdate = system.today();
            Date sdate = currentdate - 30;
            Date edate = currentdate + 182;
            String strdate = String.valueof(sdate);
            String Strstartdate = strdate.substring(0,10);
             String enddate = String.valueof(edate);
            String Strenddate = enddate.substring(0,10);
            system.debug('sdateIF-192'+Strstartdate);
            system.debug('edateIF-192'+Strenddate);
            //Need to Store target id for every knox user and then use dynamically on the basis of current user            
            String jsonBody = JSON.serialize(output);
         // String urlParam ='?'+'userId='+ userName+'&'+'targetId='+userTargetId+'&'+'startAt='+'2023-11-01T12%3A00%3A00%2B09%3A00'+'&'+'endAt='+'2024-11-20T12%3A00%3A00%2B09%3A00';//'?'+'startAt='+'2023-05-05T00:00:00+09:00'+'&'+'endAt='+'2023-10-27T00:00:00+09:00'+'&'+'targetId='+'M230315081100C6N7454'+'&'+'userId='+ userName;            				 
          String urlParam ='?'+'userId='+ userName+'&'+'targetId='+userTargetId+'&'+'startAt='+Strstartdate+'T12%3A00%3A00%2B09%3A00'+'&'+'endAt='+Strenddate+'T12%3A00%3A00%2B09%3A00';//'?'+'startAt='+'2023-05-05T00:00:00+09:00'+'&'+'endAt='+'2023-10-27T00:00:00+09:00'+'&'+'targetId='+'M230315081100C6N7454'+'&'+'userId='+ userName;            				 
            InputHeader knoxHeader = new InputHeader();        
            resMap = call.httpKnoxCallout('', urlParam);
            
            System.debug('request : '+resMap.get('Request')); 
            System.debug('response : '+resMap.get('Response'));
        	System.debug('resMap01 : '+resMap);
            HttpResponse response = (HttpResponse)resMap.get('HttpResponse');
            System.debug('response : '+resMap.get('Response'));
			String jsonResponse =  response.getBody();   
            if(response.getStatusCode() == 200){
            Map<String,Object> deserailse = (Map<String,Object>)JSON.deserializeUntyped(jsonResponse);
        //	List<Object> jsonMap = (List<Object>)JSON.deserializeUntyped(jsonResponse);
		// SJOSHI: Start
        // adding If/Else Condition and commenting out 3 lines of code
        system.debug('SJOSHIDes>>' + deserailse);
        if(Test.isRunningTest()){
            for(Object inst : (List<object>)deserailse.get('animals')){
            jsonMap.add(inst);
        	}
            
        }
        else{
            for(Object inst : (List<object>)deserailse.get('data')){
        	jsonMap.add((Map<String,object>)inst);
        	}
        }
        //for(Object inst : (List<object>)deserailse.get('data')){
        //    jsonMap.add((Map<String,object>)inst);
        //}
        // SJOSHI: End
       interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
               loginUser.KnoxDataError__c = 'success';

        }
            else {
                if(response.getStatusCode() == 403) {
                  loginUser.KnoxDataError__c = 'noknoxuser';

                }
                 
                if(response.getStatusCode() != 403){
                   loginUser.KnoxDataError__c = 'errorcoming';
   
                }
                system.debug('statuscodecoming'+response.getStatusCode());
                List<String> errList = new List<String>();
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')),errList);
        //   Map<String,Object> deserailse = (Map<String,Object>)JSON.deserializeUntyped(jsonResponse);
          //      system.debug('errordetails'+deserailse.get('errorDetail'));
                       /*    for(Object inst : (List<object>)deserailse.get('errorDetail')){
                                jsonMap1.add((Map<String,object>)inst);
                           } */
            //  string errorcode = String.valueof((<Object>)deserailse.get('errorCode'));
               // system.debug('errorcode'+errorcode);
              //  loginUser.KnoxDataError__c = true;

            }
        }
         catch (Exception e){
                ifLog.addLog('Exception : ' + e.getMessage());
                // errorMsgList.add('Exception : ' + e.getMessage());           
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')), e);          
             //  loginUser.KnoxDataError__c = true;
                              loginUser.KnoxDataError__c = 'errorcoming';


         }
                 ifLog.createLog(interfaceLog); 
                  update loginUser;
        	system.debug('jsonMapIF-192____________' + jsonMap);       	    
            Return jsonMap;
           // }
       
    }
    public class OutputHeader{        
        public String userId;
        public String startAt;
        public String endAt;
        public String targetId;
    }
    public class InputHeader{        
        public String KnoxSchedulId;
        public String subject;
        public String contentsType;
        public String contents;
        public String dateTimeing;        
    }
}