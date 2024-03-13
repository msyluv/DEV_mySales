/**
* @description       : This is a Generic apex class to call if there is need of session id in Aura/LWC component
* @author            : rakshit.s@samsung.com
* @group             : 
* @date created  : 05-07-2023
* @last modified on : 05-07-2023
* @last modified by  : rakshit.s@samsung.com
* @Version: V1.0 (Initial Development)
**/ 
public class getSessionId {
    
    public static String getSessionIdFromVFPage(PageReference visualforcePage){
        String content = visualforcePage.getContent().toString();
        Integer s = content.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
            e = content.indexOf('End_Of_Session_Id');
        return content.substring(s, e).substring(15);
    }
/*// Create a PageReference instance with your Visualforce page name
PageReference visualforcePage = new PageReference('/apex/sessionidgenerator');

// Call the getSessionIdFromVFPage method and retrieve the session ID
String sessionId = getSessionId.getSessionIdFromVFPage(visualforcePage);

// Use the session ID as needed
System.debug('Session ID: ' + sessionId);*/    
}