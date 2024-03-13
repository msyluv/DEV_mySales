global class EmailNotificationBatchScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        EmailNotficationBatch b = new EmailNotficationBatch();
        database.executebatch(b);
    }
}