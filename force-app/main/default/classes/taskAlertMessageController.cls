public class taskAlertMessageController {
    
    @AuraEnabled
    public static String gettaskalertDetail(Id taskid){
        String taskalrtmsg;
        Task taskrec =[select id, Taskalertmsg__c from Task where id =:taskid];
        taskrec.Taskalertmsg__c = false;
        update taskrec;
        taskalrtmsg = 'success';
        return taskalrtmsg;
        
    }

}