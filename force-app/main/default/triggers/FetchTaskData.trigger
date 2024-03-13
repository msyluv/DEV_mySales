/** 
* @author            : saurav.k@partner.samsung.com
* @group             : 

* @last modified on  : 04/08/2023
* @last modified by  : saurav.k@partner.samsung.com
* Modifications Log 
* Ver   Date         Author                          Modification
* 1.0   04/08/2023   saurav.k@partner.samsung.com    Initial Version
**/
trigger FetchTaskData on Task (After Insert,After Update) {
    Set<Id> newrecordID = new set<Id>();
    for(Task t:Trigger.New){
        newrecordID.add(t.Id);
    }
    if(Trigger.isInsert  && Trigger.IsAfter){
        IF_KnoxTaskCallOutAPIController.doCalloutSendingTaskInfo(newrecordID);
       
    }
    if( Trigger.isUpdate && Trigger.IsAfter){
     IF_KnoxUpdateTaskController.doCalloutSendingUpdatedTaskInfo(newrecordID);
    }
}