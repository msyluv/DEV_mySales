public class Queueable_WeeklySalesReport implements Queueable,Database.AllowsCallouts {
    
    public Employee__c senderEmployee;
    public Id recordId; 
    public List<String> toList;
    public List<String> ccList; 
    public List<String> bccList;
    public String subject;
    public String description; 
    public List<Map<String, Object>> efileList;
    public List<Map<String, String>> nfileList;
    public Queueable_WeeklySalesReport(Employee__c senderEmployee, Id recordId, List<String> toList, List<String> ccList, 
                                       List<String> bccList ,String subject,  String description, 
                                       List<Map<String, Object>> efileList, List<Map<String, String>> nfileList) {
                                           this.senderEmployee = senderEmployee;      
                                           this.recordId = recordId; 
                                           this.toList = toList;
                                           this.ccList = ccList;
                                           this.bccList = bccList;
                                           this.subject = subject;
                                           this.description = description;
                                           this.efileList = efileList;
                                           this.nfileList = nfileList;
                                       }
    
    public void execute(QueueableContext context) {
        
        OpportunityEmailAlertController.sendKnoxEmailMulti(senderEmployee, recordId, toList, ccList, bccList, subject, description, efileList, nfileList);
        
    }
}