/**
* @description       : 
* @author            : hj.lee@dkbmc.com
* @group             : 
* @last modified on  : 2021-02-23
* @last modified by  : hj.lee@dkbmc.com
* Modifications Log 
* Ver   Date         Author             Modification
* 1.0   2020-12-08   hj.lee@dkbmc.com   Initial Version
**/
trigger EventTrigger on Event (before update, after insert, after update, after delete,before insert) {    
    TriggerSwitch__c trSwitch = TriggerSwitch__c.getInstance(UserInfo.getUserId()); 
    Boolean AllSwitch = trSwitch.All__c; 
    Boolean EventSwitch = trSwitch.Event__c;  
    Boolean isSandbox = Utils.getIsSandbox();
    User us = [select id, Email from user where Id =:UserInfo.getUserId()];
    public Employee__c loginEmployee = Utils.getLoginEmployeeData(UserInfo.getUserId());   
    if(AllSwitch && EventSwitch) {     
        switch on Trigger.operationType {
            when BEFORE_UPDATE {
                
                for(Event n : Trigger.new){
                    if(!Test.isRunningTest()){
                    // knox 일정 연계 이벤트인경우, 작성자 본인이 아닌 경우 수정 불가능 (*** 유효성 필요 확인 ***)
                    if(n.IsKnoxSchedule__c && (n.CreatedById != UserInfo.getUserId()) ) {
                        n.addError('Knox 연계 일정입니다. 작성자만 수정가능합니다.');
                        
                    }
                    }
                }
            }
            
            /**
* Knox 일정 등록, 수정, 삭제
*/
 when AFTER_INSERT {                
                if(String.isNotBlank(loginEmployee.EvMailAddr__c)) {
                   // System.enqueueJob(new EventTriggerHelper(Trigger.new, null, Trigger.operationType, loginEmployee));
                
                // saurav change Start
                if(!system.isBatch()){    
                    for(Event e :Trigger.New){     
                        
                            IF_KnoxTaskCallOutAPIController.doCalloutCreatemySalesKnoxCalender(e.Id);  
                    } 
                    }        
                    
                    
                }
                
                    
                
                // saurav change End
            }           
            when AFTER_UPDATE { 			                                  
                if(String.isNotBlank(loginEmployee.EvMailAddr__c)) {
                    //System.enqueueJob(new EventTriggerHelper(Trigger.new, Trigger.oldMap, Trigger.operationType, loginEmployee));
                }
                // saurav change Start
                    List<Event> updateevelist = new List<Event>();          
                if(!system.isBatch()){					                  
                    for(Event eve :Trigger.New){
                       	
                        if((Trigger.OldMap.get(eve.Id).Subject != eve.Subject) || (Trigger.OldMap.get(eve.Id).ActivityDate != eve.ActivityDate) || (Trigger.OldMap.get(eve.Id).StartDateTime != eve.StartDateTime) || (Trigger.OldMap.get(eve.Id).EndDateTime != eve.EndDateTime) || (Trigger.OldMap.get(eve.Id).Location != eve.Location) || (Trigger.OldMap.get(eve.Id).Description != eve.Description) || (Trigger.OldMap.get(eve.Id).IsAllDayEvent != eve.IsAllDayEvent)){
                           system.debug('hi');
                            if(eve.IsIF_152__c == false){
                            IF_KnoxUpdateTaskController.doCalloutSendingUpdatedTaskInfo(eve.Id); 
                            }
                        }
                        Event eve1 = new Event(id=eve.id);
                       if(eve.IsIF_152__c == true){
                        eve1.IsIF_152__c = false;
                        updateevelist.add(eve1); 
                        }
                    }
                    if(updateevelist.size() > 0){
                   	 update updateevelist;
                    }
                }
                // saurav changes end                        
            }
            when AFTER_DELETE {
                if(String.isNotBlank(loginEmployee.EvMailAddr__c)) {
                    // System.enqueueJob(new EventTriggerHelper(Trigger.old, null, Trigger.operationType, loginEmployee));
                }
                // saurav change Start
                system.debug('deleted'+system.isBatch());
                if(!system.isBatch()){               
                    for(Event ev :Trigger.Old){
                        if(ev.Knox_Schedule_ID__c != Null){
                            IF_DeleteKnoxScheduleCalloutController.deleteSingleknoxSchedule(ev.Knox_Schedule_ID__c,ev.Knox_Calendar_Id__c);                        
                        }
                    }
            }
                    // saurav change end                
            }
        }
        
    }
    
}