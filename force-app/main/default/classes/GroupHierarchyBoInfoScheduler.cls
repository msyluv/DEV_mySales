/**
* @description       : This is a Apex Scheduler Class that runs in order to Schedule the GroupHierarchyBOInfoBatch to Send Email to all the Team Leaders with The info of Elapsed(Close Date passed)/Near To Elapsed(7 or less than 7 Days to clsoe Date)
* @author            : rakshit.s@samsung.com
* @group             : 
* @date created  : 02-20-2023
* @last modified on : 02-25-2023
* @last modified by  : rakshit.s@samsung.com
* @Version: V1.0 (Initial Development)
**/
public class GroupHierarchyBoInfoScheduler implements Schedulable {
    
    public void execute(SchedulableContext ctx) {
        ///Code to execute when scheduled job runs    
        GroupHierarchyBOInfo.sendEmailToLeaders();
    }
    
    /*public static String scheduleJob() {
        // Schedule job to run on March 30th 2023 at 9:00 AM
        Datetime scheduledTime = Datetime.newInstance(2023, 03, 30, 9, 0, 0);
        String cronExp = '' + scheduledTime.second() + ' ' + scheduledTime.minute() + ' ' + scheduledTime.hour() + ' ' + scheduledTime.day() + ' ' + scheduledTime.month() + ' ? ' + scheduledTime.year();
        
        MyScheduledClass job = new MyScheduledClass();
        return System.schedule('My Scheduled Job', cronExp, job);
    }*/
}