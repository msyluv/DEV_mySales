/**
 * @description       : 
 * @author            : chae_ho.yang@samsung.com
 * @group             : 
 * @last modified on  : 03-24-2023
 * @last modified by  : chae_ho.yang@samsung.com
**/
@isTest
public class ScheduleGroupHierarchyBoInfoTest {

      // just tests whether the scheduled classes run.
  static testMethod void testRunsScheduled() {
    ScheduleGroupHierarchyBOInfo boInfo = new ScheduleGroupHierarchyBOInfo();
    String sch = '0 0 23 * * ?';
    
    Test.startTest();
    Id jobId = System.schedule('City Vision Lead Scoring', sch, boInfo);
    
    // Get the CronTrigger info prior to the run
  CronTrigger cronTrigger1 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
      
  // Assert that the expressions are the same
  System.assertEquals(sch, cronTrigger1.CronExpression);
      
  // Assert that the cron job has not started
  System.assertEquals(0, cronTrigger1.TimesTriggered);

    Test.stopTest(); // will execute the asynchronous Apex
}
}