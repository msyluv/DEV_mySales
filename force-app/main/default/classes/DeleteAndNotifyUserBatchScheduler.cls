global class DeleteAndNotifyUserBatchScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        DeleteAndNotifyUserBatch dd = new DeleteAndNotifyUserBatch();
        
        Database.executeBatch(dd);
    }
}