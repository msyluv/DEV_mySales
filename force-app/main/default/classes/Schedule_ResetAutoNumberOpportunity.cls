/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-02-24
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   02-24-2021   woomg@dkbmc.com   Initial Version
**/
public class Schedule_ResetAutoNumberOpportunity implements Schedulable {
    /*
    	↓실행 코드 [실행 일시 : 매년 1월 1일 오전 1시]
    	System.schedule('Reset AutoNember Field of Opportunity', '0 0 1 1 1 ? *', new Schedule_ResetAutoNumberOpportunity());
	*/
    
    // Execute Schedule
    public void execute( SchedulableContext SC ){
        Date today = Date.today();
        String years = String.valueOf(today.year()).right(2);
        String str_startNumber = years + '00001';        
        Integer int_startNumber = Integer.valueOf(str_startNumber);
        
        MiniMETAUtils.ResetAutoNumberField('Opportunity', 'Auto_OpptyCode__c', 'Opportunity Code', '{0000000}', int_startNumber);
    }
}