/**
 * @description       : 
 * @author            : yeongju.baek@dkbmc.com
 * @group             : 
 * @last modified on  : 06-04-2021
 * @last modified by  : yeongju.baek@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   06-01-2021   yeongju.baek@dkbmc.com   Initial Version
**/
public class testCalendar {
    @AuraEnabled
    public static Map<String,Object> searchCalendar(String System_ID, String userId){
        /* Map<String, Object> resMap = new Map<String, Object>(); */
        /* Map<String, Object> paramMap = (Map<String, Object>)JSON.deserializeUntyped(jsonParam);  */
        /* Map<String, Object> knoxCalendarMap = (Map<String, Object>)paramMap.get('userId');  */
        
        system.debug('TEST!!!!!!! '+userId);
            //IF_KnoxGetCalendarsController.InputClass input = new IF_KnoxGetCalendarsController.InputClass();
            //input.userId = userId;
            //Map<String, Object> knoxResponse = IF_KnoxGetCalendarsController.getCalendars(input);
            //system.debug(knoxResponse);
            return  null;

        
    }
}