global class Batch_UserPasswordReset implements Database.Batchable<sObject>{
    
    global List<Profile> profileList = new List<Profile>();
    global String str_query = '';
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator(str_query);
    }
     
    global void execute(Database.BatchableContext BC, List<User> scope) {
        for(User u : scope){
            System.debug('Name : ' + u.Name + ' / Profile Name : ' + u.Profile.Name + ' / Active : ' + u.IsActive);
            System.resetPassword(u.Id, true);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}