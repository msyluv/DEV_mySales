/**
* @description       : Batch to Delete Retired Employee 
* @author            : waris.m@samsung.com
* @group             : 
* @last modified on  : 2024-02-29
* @last modified by  : waris.m@samsung.com 
* Modifications Log 
* Ver   Date         Author                      Modification
* 1.0   2024-02-29   waris.m@samsung.com   Initial Version for MYSALES-455
**/

global class Batch_Employee_Deletion implements Database.Batchable<sObject>,schedulable
 {
    private static final String INTERFACE_ID = 'Batch_Employee_Deletion';
    private static final String APEX_CLASS   = 'Batch_Employee_Deletion';
    private static String guId = IF_Util.generateGuid();
       global Database.QueryLocator start(Database.BatchableContext bc)
        {   
          IF_Log ifStartLog = new IF_Log();
          IF_Log.BatchLog batchStartLog;
          batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
          ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' +  '(Start:' + BC.getJobId() + ') 시작' + ' ####################');
          String queryString;
            if(Test.isRunningTest())
            {
              queryString = 'Select Id from Employee__c WHERE Status__c=\'R\' AND LastmodifiedDate < TOMORROW' ;   
            }
            else
            {
             queryString = 'Select Id from Employee__c WHERE Status__c=\'R\' AND LastmodifiedDate < LAST_N_MONTHS:6' ;
            }
               
         ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | '  + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');
         ifStartLog.createLog(batchStartLog);
         return Database.getQueryLocator(queryString);
       }
  
       global void execute(Database.BatchableContext BC, List<Employee__c> scopeList)
       {
         List<Employee__c>employeeToDelete = new List<Employee__c>();
         String employeeId;  
         for( Employee__c emp : scopeList)
         { 
           employeeToDelete.add(emp);
           employeeId+=emp.Id+ ', '; 
         }
         try{
               Database.delete(employeeToDelete);
            }
         catch(Exception e)
            {
                IF_Log__c logRec = new IF_Log__c(InterfaceId__c=INTERFACE_ID,InterfaceGuid__c = guId,ApexMethod__c = 'Execute',StatusCode__c = 'E',LogType__c = 'Batch',LogText__c = employeeId,EndDatetime__c  = System.now(),StartDatetime__c = System.now());
                logRec.ExceptionType__c = e.getTypeName();
                logRec.ErrorMessage__c = e.getMessage();
                logRec.StackTrace__c = e.getStackTraceString();
        
                insert logRec; 
            }
       }

      global void finish(Database.BatchableContext BC)
      {
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);
        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + 'Finish' + ' 종료' + ' ####################');
        ifFinishLog.createLog(batchFinishLog);
      }
       public void execute(SchedulableContext sc) {
        database.executebatch(new Batch_Employee_Deletion() ,200);
       }
  }