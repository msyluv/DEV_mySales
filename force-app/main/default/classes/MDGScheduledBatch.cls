global with sharing class MDGScheduledBatch implements Schedulable {
global void execute(SchedulableContext sc) {
  ID BatchId = Database.executeBatch(new MDG_AccountInfoUpdate(), 5);
}
 
Public static void SchedulerMethod() {
  string timeinterval = '0 5 * * * ?';
  System.schedule('MDGScheduledBatch-Every5mins','0 0 * * * ?', new MDGScheduledBatch());
  System.schedule('MDGScheduledBatch-Every5mins','0 5 * * * ?', new MDGScheduledBatch());
  System.schedule('MDGScheduledBatch-Every5mins','1 0 * * * ?', new MDGScheduledBatch());
  System.schedule('MDGScheduledBatch-Every5mins','1 5 * * * ?', new MDGScheduledBatch());
  System.schedule('MDGScheduledBatch-Every5mins','2 0 * * * ?', new MDGScheduledBatch());
    System.schedule('MDGScheduledBatch-Every5mins','2 5 * * * ?', new MDGScheduledBatch());
      System.schedule('MDGScheduledBatch-Every5mins','3 0 * * * ?', new MDGScheduledBatch());
      System.schedule('MDGScheduledBatch-Every5mins','3 5 * * * ?', new MDGScheduledBatch());
  }
}