global class GroupHierarchBOInfoBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return null;
    }
    
    global void execute(Database.BatchableContext BC, List<User> userList) {
        
    }
    
    global void finish(Database.BatchableContext BC) { 
        
    }
    
}