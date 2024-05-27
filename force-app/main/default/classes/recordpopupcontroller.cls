public class recordpopupcontroller {
    
     @auraEnabled
    public Static Event getEventData(String evntrecdid){
        Event ev = [select id,Subject, StartDateTime, EndDateTime, IsAllDayEvent, IsPrivate, Description, OwnerId, Owner.Name, CurrencyIsoCode,Location, type from Event where id =: evntrecdid];
        return ev;
    }
        @auraEnabled
    public Static Task getTaskData(String taskrecdid){
        Task tsk = [select id,Subject, Assignor__c,OwnerId,Owner.Name,WhoId, Who.Name,CurrencyIsoCode, PrivateTask__c,Description,ActivityDate,Priority,Status from task where id =: taskrecdid];
        return tsk;
    }
       @auraEnabled
    public Static String updateEventData(Event eventrecd){
        String message= '';
        if(eventrecd != null){
            update eventrecd;
            message = 'success';
        }
        
       
        return message;
    }
       @auraEnabled
        public Static String updateTaskData(Task taskrecd){
        String message= '';
        if(taskrecd != null){
            update taskrecd;
            message = 'success';
        }
        
       
        return message;
    }
       @auraEnabled
    public Static String deleteEventData(String eventrecdid){
        String message= '';
        try{
          Event evt = [select id from Event where id=:eventrecdid];
            delete evt;
            message = 'success';
        
        }
        catch(exception e){
            message= 'error';
        }
        return message;
    }
        @auraEnabled
    public Static String deleteTaskData(String taskrecdid){
        String message= '';
        try{
          Task tsk = [select id from Task where id=:taskrecdid];
          System.debug('task '+tsk);
            delete tsk;
            message = 'success';
        
        }
        catch(exception e){
            message= 'error';
            System.debug('error message'+e);
        }
        return message;
    }
       @AuraEnabled(cacheable=true)
    public static List<User> searchUsers(String searchTerm) {
        String searchKey = '%' + searchTerm + '%';
        return [SELECT Id, Name,SmallPhotoUrl  FROM User WHERE Name LIKE :searchKey LIMIT 10];
    }
       @AuraEnabled(cacheable=true)
    public static List<Contact> searchContacts(String searchTerm) {
        String searchKey = '%' + searchTerm + '%';
        return [SELECT Id, Name  FROM Contact WHERE Name LIKE :searchKey LIMIT 10];
    }
    
  @AuraEnabled(cacheable=true)
    public static List<String> getEventTypes() {
        List<String> eventTypes = new List<String>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType eventTypeSchema = gd.get('Event');
        if (eventTypeSchema != null) {
            Schema.DescribeSObjectResult eventDescribe = eventTypeSchema.getDescribe();
            Map<String, Schema.SObjectField> fieldsMap = eventDescribe.fields.getMap();
            if (fieldsMap.containsKey('CurrencyIsoCode')) {
                Schema.DescribeFieldResult eventTypeField = fieldsMap.get('CurrencyIsoCode').getDescribe();
                List<Schema.PicklistEntry> picklistValues = eventTypeField.getPicklistValues();
                for (Schema.PicklistEntry entry : picklistValues) {
                    eventTypes.add(entry.getValue());
                }
            }
        }
        return eventTypes;
    }
     @AuraEnabled(cacheable=true)
    public static List<String> getTaskTypes() {
        List<String> eventTypes = new List<String>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType eventTypeSchema = gd.get('Task');
        if (eventTypeSchema != null) {
            Schema.DescribeSObjectResult eventDescribe = eventTypeSchema.getDescribe();
            Map<String, Schema.SObjectField> fieldsMap = eventDescribe.fields.getMap();
            if (fieldsMap.containsKey('Status')) {
                Schema.DescribeFieldResult eventTypeField = fieldsMap.get('Status').getDescribe();
                List<Schema.PicklistEntry> picklistValues = eventTypeField.getPicklistValues();
                for (Schema.PicklistEntry entry : picklistValues) {
                    eventTypes.add(entry.getValue());
                }
            }
        }
        return eventTypes;
    }
    
     @AuraEnabled(cacheable=true)
    public static List<String> getTaskTypesP() {
        List<String> eventTypes = new List<String>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType eventTypeSchema = gd.get('Task');
        if (eventTypeSchema != null) {
            Schema.DescribeSObjectResult eventDescribe = eventTypeSchema.getDescribe();
            Map<String, Schema.SObjectField> fieldsMap = eventDescribe.fields.getMap();
            if (fieldsMap.containsKey('Priority')) {
                Schema.DescribeFieldResult eventTypeField = fieldsMap.get('Priority').getDescribe();
                List<Schema.PicklistEntry> picklistValues = eventTypeField.getPicklistValues();
                for (Schema.PicklistEntry entry : picklistValues) {
                    eventTypes.add(entry.getValue());
                }
            }
        }
        return eventTypes;
    }
    
}