trigger TaskTrigger on Task (before update, after insert, after update, after delete,before insert) {
 TriggerSwitch__c trSwitch = TriggerSwitch__c.getInstance(UserInfo.getUserId()); 
    Boolean AllSwitch = trSwitch.All__c; 
    //Boolean EventSwitch = trSwitch.Event__c;
    public Employee__c loginEmployee = Utils.getLoginEmployeeData(UserInfo.getUserId());   
                   User userrec = [select id,Synchronize_task__c from user where id =: UserInfo.getUserId()];

    //List<Refresh_Record_Event__e> RefreshEventList = new List<Refresh_Record_Event__e>();
    if(AllSwitch) {     
        switch on Trigger.operationType {
            when AFTER_INSERT {                
                // saurav change Start
                if(!system.isBatch()){    
                    
                    for(Task tsk :Trigger.New){   
                        if(userrec.Synchronize_task__c == true && tsk.ActivityDate != null){
                       // knoxCreateScheduleTask.createtaskonknox(tsk.Id);
                     //IF_KnoxTaskCallOutAPIController.doCalloutCreatemySalesKnoxCalenderTask1(tsk.Id);
                         System.enqueueJob(new knoxCreateScheduleTask(tsk.Id));
                            
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
                if(!system.isBatch()){					                  
                    for(Task tsk :Trigger.New){
                        if(userrec.Synchronize_task__c){
                        if((Trigger.OldMap.get(tsk.Id).Subject != tsk.Subject) || (Trigger.OldMap.get(tsk.Id).ActivityDate != tsk.ActivityDate) || (Trigger.OldMap.get(tsk.Id).Description != tsk.Description) ){
                           system.debug('hi');
                            if( tsk.ActivityDate!=null && Trigger.OldMap.get(tsk.Id).ActivityDate != null) {
                            IF_KnoxUpdateTaskCallout.doCalloutSendingUpdatedTasktoknox(tsk.Id); 
                            }
                            else if(tsk.ActivityDate!=null && Trigger.OldMap.get(tsk.Id).ActivityDate == null){
                               System.enqueueJob(new knoxCreateScheduleTask(tsk.Id)); 
                            }
                            else {
                                
                               IF_DeleteKnoxScheduleCalloutController.deleteSingleknoxSchedule(tsk.Knox_Schedule_ID__c,tsk.Knox_Calendar_Id__c);                        

                            }
                        } 
                        }
                    
                    }
                 
                }
                // saurav changes end                        
            }
                 when AFTER_DELETE {
             
                // saurav change Start
                system.debug('deleted'+system.isBatch());
                if(!system.isBatch()){               
                    for(Task tk :Trigger.Old){
                        if(tk.Knox_Schedule_ID__c != Null && userrec.Synchronize_task__c == true){
                            IF_DeleteKnoxScheduleCalloutController.deleteSingleknoxSchedule(tk.Knox_Schedule_ID__c,tk.Knox_Calendar_Id__c);                        
                        }
                    }
            }
                    // saurav change end                
            }
        
        }

}
}