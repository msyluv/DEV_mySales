public class ReportScheduler implements Schedulable {
    public String repId;
    public List<String> userIds;
    //public String cronExp;
    
    public void execute(SchedulableContext SC) {
        ReportTableGenerator.generateHtmlTable(repId , userIds , false);
    } 
    
    public ReportScheduler(String repId, List<String> userIds) {
        this.repId = repId;
        this.userIds = userIds;
        //this.cronExp = cronExp;
    }
    
    /*
     *String arg1Value = '00O1s000000HyYkEAK'; // Replace 'YourArg1Value' with the actual value for arg1Value
List<String> arg2Value = new List<String>{'Value1', 'Value2'}; // Replace 'Value1' and 'Value2' with actual values for arg2Value

// Create an instance of the ReportScheduler class with the arguments
ReportScheduler scheduler = new ReportScheduler(arg1Value, arg2Value);

// Schedule the ReportScheduler class to run daily at 7:04 PM
String cronExp = '0 33 13 * * ?'; // Cron expression for 7:04 PM daily (GMT/UTC)

System.schedule('My Report Scheduler Job', cronExp, scheduler);
*/
}