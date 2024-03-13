global class Batch_MonitoringRecords implements Database.Batchable<sObject>  {
    String APEX_CLASS   = 'Batch_MonitoringRecords';
        String METHOD_NAME   = 'Batch_MonitoringRecords';
        String INTERFACE_ID = 'UserRollIsNULL';
        String guId = IF_Util.generateGuid();
    
    global Database.QueryLocator start(Database.BatchableContext bc){
    return Database.getQueryLocator([Select id ,Owner.UserRole.Id,Owner.UserRole.Name, Owner.IsActive  from Opportunity where Owner.UserRole.id = '' and Owner.IsActive = true Limit 3]);
    }
    
    global void execute (Database.BatchableContext bc , List<Opportunity> opplist){
        
        try{
            List<IF_Log__c > iflist = new List<IF_Log__c>();
            if(opplist.size() >0){
            for(Opportunity opp : opplist){
               IF_Log__c mon = new IF_Log__c();
                mon.StartDatetime__c = System.today();
                mon.EndDatetime__c = System.today();
                mon.InterfaceId__c = INTERFACE_ID;
                mon.LogType__c = 'BATCH';
                mon.ExceptionType__c = 'No_Specified_Role';
                mon.ErrorMessage__c = 'Please Specify rolw :' ;
                mon.ApexName__c = APEX_CLASS;
                mon.ApexMethod__c = 'execute';
                mon.StatusCode__c = 'E';
                iflist.add(mon);
            }
                insert iflist ;
            }
        } catch(Exception e){
            system.debug('Exception e occur' + e.getMessage());
            IF_Log.InterfaceLog ifLog;
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, '', '',e);
        }
                
    }
    global void finish(Database.BatchableContext bc){

    }


}