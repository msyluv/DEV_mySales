/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2022-02-21
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-01-25   younghoon.kim@dkbmc.com   Initial Version
 * 1.1   2022-02-21   younghoon.kim@dkbmc.com   주간보고 내용이 입력되지 않은 경우 IF 전송하지 않도록 로직 추가
**/
public class WeeklyReportSendController {
    @AuraEnabled
    public static Map<String, String> sendWeeklyReport(String rcdId){
        Map<String, String> rtnMap = new Map<String, String>();
        
        WeeklyReport__c wp = [SELECT Id, Name, Opportunity__c, Contents__c FROM WeeklyReport__c WHERE Id =: rcdId];
        if(wp.Opportunity__c != null){
            if(wp.Contents__c != null){
                List<String> idList = new List<String>();
                idList.add(rcdId);

                try{
                    if(idList.size() > 0){
                        IF_LsWeeklyReportController.calloutWeeklyInfo(idList);
                        rtnMap.put('RESULT', 'S');
                        rtnMap.put('MSG', System.Label.WEEKLYREPORT_MSG_0001);
                    }
                }catch(Exception e){
                    System.debug('Error : ' + e);
                    rtnMap.put('RESULT', 'F');
                    rtnMap.put('MSG', e.getMessage());
                }
            }else{ // 주간보고 내용이 입력되지 않은 경우 IF 전송하지 않도록 로직 추가
                rtnMap.put('RESULT', 'W');
                rtnMap.put('MSG', System.Label.WEEKLYREPORT_MSG_0003);
            }
        }else{
			rtnMap.put('RESULT', 'F');
            rtnMap.put('MSG', System.Label.WEEKLYREPORT_MSG_0002);            
        }        
        return rtnMap;
    }
}