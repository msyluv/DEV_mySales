/**
* @description       : Create IF_Monitoring record BO with No-Role-User owner. 
* @author            : saurav.k@partner.samsung.com
* @group             :  
* @last modified on  : 05-10-2023
* @last modified by  : saurav.k@partner.samsung.com
* Modifications Log 
* Ver   Date         Author                        Modification
* 1.0   05-10-2023  saurav.k@partner.samsung.com   Initial Version(MySales -189)

**/
public class Batch_MonitoringInsertBasisonBO implements Database.Batchable<sObject>,Database.Stateful,Schedulable {
    private static final String INTERFACE_ID = 'Batch_MonitoringBO'; 
    private static final String APEX_CLASS   = 'Batch_MonitoringInsertBasisonBO'; 
    private static final String METHOD_NAME  = 'Execute';
    private static String guId = IF_Util.generateGuid(); 
    Public Integer TotalisActiveRecords = 0;
    
    public Database.QueryLocator start(Database.BatchableContext BC) {   
        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
        ifStartLog.addLog('#####-----##### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + '#####-----##### ');
        Set<String> stageNameSet = new Set<String> ();
        stageNameSet.add('Z01');
        stageNameSet.add('Z02');
        stageNameSet.add('Z03');
        stageNameSet.add('Z04');
        String queryString = 'SELECT Id,owner.IsActive,owner.UserRoleId,StageName from Opportunity ';             			 
        queryString += ' WHERE StageName IN :stageNameSet ';       
        ifStartLog.createLog(batchStartLog);
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> scopeList) {
        system.debug('Scopelist____' + scopeList);
        system.debug('ScopelistSize____' + scopeList.Size());
        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        List<IF_Log__c> insertIFLogList = new List<IF_Log__c>();         
		String IdsOfOpportunity ;        
        if(scopeList.size() > 0){
            List<Opportunity> listOfNotActiveOpportunity = [Select Id,owner.IsActive from opportunity Where Id IN:scopeList AND owner.IsActive = false];                      
           	 TotalisActiveRecords += listOfNotActiveOpportunity.Size();             
            for(Opportunity opp : scopeList){                   
                if(opp.owner.IsActive  && opp.owner.UserRoleId == Null){
                    IF_Log__c logUserRoleisNULL = new IF_Log__c();
                    logUserRoleisNULL.StatusCode__c = 'E';
                    logUserRoleisNULL.StartDatetime__c = system.now();
                    logUserRoleisNULL.EndDatetime__c = system.now();
                    logUserRoleisNULL.InterfaceId__c = 'UserRoleisNULL';
                    logUserRoleisNULL.LogType__c = 'BATCH';
                    logUserRoleisNULL.ExceptionType__c = 'No_Role_Specified';
                    logUserRoleisNULL.ErrorMessage__c = 'Please specify role for Sales Representative' + ' BO_Id : ' + opp.Id + ', BO_OwnerId : ' + opp.OwnerId;                    
                    logUserRoleisNULL.ApexName__c = 'Batch_MonitoringInsertBasisonBO';
                    logUserRoleisNULL.ApexMethod__c = 'Execute';                    
                    insertIFLogList.add(logUserRoleisNULL);
                }else if(opp.owner.IsActive == false){
						                   
                    if(String.IsEmpty(IdsOfOpportunity) && String.IsBlank(IdsOfOpportunity)){
                      IdsOfOpportunity = opp.Id;                     
                    }else{
                      IdsOfOpportunity = IdsOfOpportunity + ',' + opp.Id;
                    }
                }
            }
            
            ifExcuteLog.addLog( '#####-----##### ['+insertIFLogList.size()+']#####-----#####  IF_Logs Inserted');
            try{
                if(insertIFLogList.size() > 0) insert insertIFLogList;                
            } catch(dmlexception e){
                batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, e.getMessage(), 0, 0,e);
                ifExcutelog.createLog(batchExcuteLog);
                
            }
            //create Interface Log
            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', '', 0);
            ifExcutelog.createLog(batchExcuteLog);
            
        }  
    }
    
    public void finish(Database.BatchableContext BC) {
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        Boolean IsSandbox = Utils.getIsSandbox();
        List<IF_Log__c> insertlogUserIsNotActive = new List<IF_Log__c>();
        IF_Log__c logUserIsNotActive = new IF_Log__c();
            logUserIsNotActive.StatusCode__c = 'E';
            logUserIsNotActive.StartDatetime__c = system.now();
            logUserIsNotActive.EndDatetime__c = system.now();
            logUserIsNotActive.InterfaceId__c = 'UserIsNotActive';
            logUserIsNotActive.LogType__c = 'BATCH';
            logUserIsNotActive.ExceptionType__c = 'Sales_Rep_is_Not_Active';
        if(IsSandbox){
            logUserIsNotActive.ErrorMessage__c = 'Please check Sales Representative active status' + ' Total_Records : ' + TotalIsActiveRecords + ', Report URL : ' +  Label.Report_URL_Qa;                    
        }else {
            logUserIsNotActive.ErrorMessage__c = 'Please check Sales Representative active status' + ' Total_Records : ' + TotalIsActiveRecords + ', Report URL : ' +  Label.Report_URL_Prod;
        }
            logUserIsNotActive.ApexName__c = 'Batch_MonitoringInsertBasisonBO';
            logUserIsNotActive.ApexMethod__c = 'Execute';                    
            insertlogUserIsNotActive.add(logUserIsNotActive);
        	insert insertlogUserIsNotActive;
        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);
        ifFinishLog.addLog('#####-----##### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + '#####-----##### ');
        ifFinishLog.createLog(batchFinishLog);
    }
    
    public void execute(SchedulableContext sc)
    {
        /* Cron Expression for Scheduling a Job
		Batch_MonitoringInsertBasisonBO bo = new Batch_MonitoringInsertBasisonBO(); 
		System.schedule('Batch_MonitoringInsertBasisonBO', '0 45 08 * * ? *' , bo);*/
        Database.executeBatch(new Batch_MonitoringInsertBasisonBO(),200);
        
    }
}