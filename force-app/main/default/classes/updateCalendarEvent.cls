public class updateCalendarEvent implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext context) {        
        String query = 'SELECT Id,Subject,StartDateTime,EndDateTime,ActivityDate FROM Event';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        
    }

    public void finish(Database.BatchableContext context) {
        
    }
}