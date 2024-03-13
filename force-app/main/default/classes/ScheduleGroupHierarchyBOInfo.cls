/**
 * @description       : 
 * @author            : chae_ho.yang@samsung.com
 * @group             : 
 * @last modified on  : 03-24-2023
 * @last modified by  : chae_ho.yang@samsung.com
**/
public class ScheduleGroupHierarchyBOInfo implements Schedulable {
    
    // Implement the execute method
    public void execute(SchedulableContext sc) {
        
        // Instantiate the Apex class to be scheduled
        GroupHierarchyBOInfo.sendEmailToLeaders();
        
    }
    
    // Schedule the Apex class to run at a specific time
   /*public static void scheduleApexClass() {
        
        // // Set the start time for the scheduled Apex class
        Datetime startTime = Datetime.newInstance(2023, 03, 01, 12, 0, 0);
        
        // // Create a new instance of the ScheduleApexClass class
        ScheduleGroupHierarchyBOInfo mySchedulableClass = new ScheduleGroupHierarchyBOInfo();
        
        // // Schedule the Apex class to run using the CronTrigger class
        String cronExpression = '0 0 8 ? * MON-FRI'; // Cron expression for 12pm on March 1, 2023
        String jobID = System.schedule('delayedBoMail', cronExpression, mySchedulableClass);
        
        // return jobID; // Return the job ID for the scheduled Apex class
        
    }*/
    
}