/**
* @author            : anish.jain@partner.samsung.com
* @group             : 
* @last modified on  : 2024-03-05
* @last modified by  : vikrant.ks@samsung.com
* Modifications Log 
* Ver   Date         Author                          Modification
* 1.0   2023-11-24   anish.jain@partner.samsung.com  Initial Version -  (MS-365)
* 1.1   2024-03-05   vikrant.ks@samsung.com          Added condition 'CollaborationBOId__r.Owner.IsActive = true' in Query(MySales-464)
**/
global class Batch_CollabTeamMemberInfo implements Database.Batchable<sObject>, Database.Stateful, Schedulable{
    
    private String logText = '';
    Set<String> stageSet = new Set<String>{'Z05', 'Z06', 'Z07', 'Z08'};
    private String InterfaceId = 'CHECK_COLLAB_AUTH' ;
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, CompanyCode__c, OpportunityCode__c, CollaborationBOId__c, OwnerId, CollaborationBOId__r.OwnerId FROM Opportunity '+
                       'where Collaboration__c = true and StageName NOT IN : stageSet and CollaborationBOId__r.Owner.IsActive = true ';//V1.1
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> OppList) {
        
        Set<Id> UserIdSet        = new Set<Id>();
        Set<Id> OpportunityIdSet = new Set<Id>();
        Set<String> OppUserSet   = new Set<String>();
        
        for(Opportunity opp:OppList){
            UserIdSet.add(opp.CollaborationBOId__r.OwnerId);
            OpportunityIdSet.add(opp.Id);
        }
        
        List<OpportunityTeamMember> oppHQTeam = [Select Id, OpportunityId, User.Id from OpportunityTeamMember where OpportunityId IN :OpportunityIdSet and User.Id IN :UserIdSet and OpportunityAccessLevel !='None'];
        if(oppHQTeam.Size()>0){
            for(OpportunityTeamMember OTM : oppHQTeam){
                OppUserSet.add(OTM.OpportunityId+'_'+OTM.User.Id);
            }
        }
        for(Opportunity opp:OppList){
            if(OppUserSet.contains(opp.Id+'_'+opp.CollaborationBOId__r.OwnerId) == false){
                logText = logText + '\r\n' + opp.OpportunityCode__c + ' ' + '(' + opp.CompanyCode__c + ')' ; 
            }
        }        
    }
    
    global void finish(Database.BatchableContext BC){
        IF_Log__c ifLog = new IF_Log__c();
        
        String StatusCode = 'S';
        if(logText !=''){
            StatusCode    = 'E';
        }
        ifLog.InterfaceId__c   = InterfaceId;
        ifLog.StatusCode__c    = StatusCode;
        ifLog.LogText__c       = logText;
        ifLog.LogType__c 	   = 'Batch';
        ifLog.StartDatetime__c = System.Now();
        ifLog.EndDatetime__c   = System.Now();
        ifLog.ApexName__c 	   = 'Batch_CollabTeamMemberInfo';
        ifLog.ApexMethod__c    = 'Execute';
        
        try{
            Insert ifLog;
        }catch(Exception e){
            System.debug('Ani Test Collab '+ e.getMessage());
        }
    }
    
    global void execute(SchedulableContext sc){
        Database.executeBatch(new Batch_CollabTeamMemberInfo(),500);
    }
}