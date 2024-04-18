/**
* @description       : Test class of Batch_ManagerWeeklySalesReport 
* @author            : kajal.c@samsung.com
* @group             : 
* @last modified on  : 2024-04-11
* @last modified by  : kajal.c@samsung.com
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2024-04-11   kajal.c@samsung.com   Initial Version
**/

global class Batch_DuplicateBOCode implements DataBase.Batchable<SObject>, Database.Stateful , DataBase.AllowsCallouts, Schedulable{ 
    
    String logText = '';
    
    global DataBase.QueryLocator start(DataBase.BatchableContext BC){
        
        String query_SELECT = '';
        
        if(Test.isRunningTest()){
         query_SELECT = 'Select Id,OpportunityCode__c from Opportunity where CompanyCode__c = \'T100\'';
        }
        else{
         query_SELECT = 'Select Id,OpportunityCode__c from Opportunity where CompanyCode__c = \'T100\' and Collaboration__c = true';    
        }
         Database.QueryLocator returnScope = DataBase.getQueryLocator(query_SELECT);
        
        return returnScope;            
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scopeList){
        System.debug('Execute::'+scopeList);
        Map<String,List<Opportunity>> mOpp = new Map<String,List<Opportunity>>();
        for(Opportunity opp : scopeList){
    if(mOpp.ContainsKey(opp.OpportunityCode__c)){
     mOpp.get(opp.OpportunityCode__c).add(opp);
     System.debug('Final oppCode : '+ mOpp);
         if(mOpp.containsKey(opp.OpportunityCode__c)){
    System.debug('Final opp1 oppCode : '+ mOpp.get(opp.OpportunityCode__c).size());
    if(mOpp.get(opp.OpportunityCode__c).size()>1){
        logText = logText + opp.OpportunityCode__c + ', ';
        System.debug('Final oppCode : '+ opp.OpportunityCode__c);
    }
    }
    // mOpp.put(opp.OpportunityCode__c, opp1);
    }
    else{
     mOpp.put(opp.OpportunityCode__c,new List<Opportunity>());
     mOpp.get(opp.OpportunityCode__c).add(opp);
     System.debug('Finale MapoppCode : '+ mOpp);
    }
  }

    }
    
    global void finish(Database.BatchableContext BC){
        IF_Log  log = new IF_Log();
        String guId  = IF_Util.generateGuid();
        IF_Log.InterfaceLog infLog = new IF_Log.InterfaceLog( 'Batch_DuplicateBOCode', guId, 'Batch_DuplicateBOCode', 'finish', logText, '');
        log.addLog('Duplicate records logged successfully');
        log.createLog(infLog);
    }
    
        public void execute( SchedulableContext SC){DataBase.executeBatch( new Batch_DuplicateBOCode(), 200);} 
    

}