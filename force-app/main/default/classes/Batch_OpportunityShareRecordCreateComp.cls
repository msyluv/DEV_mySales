/**
 * @author            : sarthak.j1@samsung.com
 * @group             : 
 * @description       : Batch Class for OpportunityShare record creation
 * @last modified on  : 2024-03-28
 * @last modified by  : sarthak.j1@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2024-03-08   sarthak.j1@samsung.com   Initial Version
**/
global class Batch_OpportunityShareRecordCreateComp implements DataBase.Batchable<SObject>, Database.Stateful , DataBase.AllowsCallouts, Schedulable {
    
    List<Group> listofcloudRole = [Select Id from Group Where (DeveloperName = 'mig20005' OR DeveloperName = 'mig20002')
                                       AND type = 'RoleAndSubordinates'ORDER By DeveloperName desc limit 2];
    
    global DataBase.QueryLocator start(DataBase.BatchableContext BC){
        //Start IF_Log Data 
        Integer oppS3 = [SELECT COUNT() FROM Opportunity WHERE cPrimarySalesDepartment__r.Node2__c = 'T100S3'];
        Integer oppS4 = [SELECT COUNT() FROM Opportunity WHERE cPrimarySalesDepartment__r.Node2__c = 'T100S4'];
        
        Integer oppShareS3 = [SELECT COUNT() FROM OpportunityShare WHERE UserOrGroupId =: listofcloudRole[0].Id];
        Integer oppShareS4 = [SELECT COUNT() FROM OpportunityShare WHERE UserOrGroupId =: listofcloudRole[1].Id];
        
        Map<Id, Opportunity> oppS3Diff = new Map<Id, Opportunity>([SELECT Id, Name FROM Opportunity WHERE cPrimarySalesDepartment__r.Node2__c = 'T100S3' 
                                       AND Id NOT IN (SELECT OpportunityId FROM OpportunityShare where UserOrGroupId =: listofcloudRole[0].Id)]);
        Set<Id> s3Set = oppS3Diff.keyset();
        
        Map<Id, Opportunity> oppS4Diff = new Map<Id, Opportunity>([SELECT Id, Name FROM Opportunity WHERE cPrimarySalesDepartment__r.Node2__c = 'T100S4' 
                                   AND Id NOT IN (SELECT OpportunityId FROM OpportunityShare where UserOrGroupId =: listofcloudRole[1].Id)]);
    	Set<Id> s4Set = oppS4Diff.keyset();
        
        String s3Data = '';
        for(Id i : s3Set){
            s3Data += (String)i + ', ';
        }
        s3Data = s3Data.removeEnd(', ');
        s3Data += '.'; 
            
        String s4Data = '';
        for(Id i : s4Set){
            s4Data += (String)i + ', ';
        }
        s4Data = s4Data.removeEnd(', ');
        s4Data += '.';     
        //End IF_Log Data
        
        String query_RESULT = '';
        String query_SELECT = 'SELECT ';
        String query_FROM   = ' FROM Opportunity';
        String query_WHERE  = ' WHERE';
        
        query_SELECT +='Id, cPrimarySalesDepartment__r.Node2__c';		
        
        query_RESULT = query_SELECT + query_FROM;
        
        query_WHERE +=' cPrimarySalesDepartment__r.Node2__c IN (\'T100S3\', \'T100S4\') AND Id NOT IN (SELECT OpportunityId' +
            			' FROM OpportunityShare WHERE UserOrGroupId IN (\''+listofcloudRole[0].Id+'\', \''+listofcloudRole[1].Id+
            			'\')) LIMIT 100';
        
        query_RESULT += query_WHERE;
        
        System.debug('SJ>> '+query_RESULT);
        
        IF_Log  log = new IF_Log();
        String guId  = IF_Util.generateGuid();
        IF_Log.InterfaceLog infLog = new IF_Log.InterfaceLog( 'OpportunityShare_Batch', guId, 'Batch_OpportunityShareRecordCreateComp', 'start', '', '');
        
        Database.QueryLocator returnScope = DataBase.getQueryLocator(query_RESULT);
        
        //log.addLog('Opportunity records to be updated: ' + returnScope);
        log.addLog('Opportunities with T100S3: ' +oppS3);
        log.addLog('Opportunities with T100S4: ' +oppS4);
        log.addLog('\nOpportunityShare with T100S3: ' +oppShareS3);
        log.addLog('OpportunityShare with T100S4: ' +oppShareS4);
        log.addLog('\nDifferences in T100S3: '+(oppS3-oppShareS3)+' ::: '+s3Data);
        log.addLog('\nDifferences in T100S4: '+(oppS4-oppShareS4)+' ::: '+s4Data);
        
        log.createLog(infLog);
        System.debug('Start::'+returnScope);
        return returnScope;            
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scopeList){
        System.debug('Execute::'+scopeList);
        List<OpportunityShare> optyShareList = new List<OpportunityShare>();
        
        for(Opportunity opp : scopeList){
            if(opp.cPrimarySalesDepartment__r.Node2__c == 'T100S3'){
                	OpportunityShare optyShare = new OpportunityShare();
                    optyShare.OpportunityId = opp.Id;
                    optyShare.UserOrGroupId = listofcloudRole[0].Id;
                    optyShare.OpportunityAccessLevel = 'Read';
                    optyShare.RowCause = 'Manual';
                    optyShareList.add(optyShare);
            }
            else if(opp.cPrimarySalesDepartment__r.Node2__c == 'T100S4'){
                	OpportunityShare optyShare = new OpportunityShare();
                    optyShare.OpportunityId = opp.Id;
                    optyShare.UserOrGroupId = listofcloudRole[1].Id;
                    optyShare.OpportunityAccessLevel = 'Read';
                    optyShare.RowCause = 'Manual';
                    optyShareList.add(optyShare);
            }
        }
        
        if(optyShareList.size() > 0){
            try{
                	IF_Log  log = new IF_Log();
                    String guId  = IF_Util.generateGuid();
                    IF_Log.InterfaceLog infLog = new IF_Log.InterfaceLog( 'OpportunityShare_Batch', guId, 'Batch_OpportunityShareRecordCreateComp', 'execute', '', '');
                	log.addLog('Total OpportunityShare records to be created: ' + scopeList.size()+'\n');
                	System.debug('SJ2>>> '+optyShareList);
                	Set<Id> oppShareSuccess = new Set<Id>();
                	Database.SaveResult[] srList = Database.Insert( optyShareList, false);
                    for (Database.SaveResult sr : srList) {
                        if (!sr.isSuccess()) {
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('OpportunityShare fields that affected this error: ' + err.getFields());
                                log.addLog(err.getStatusCode() + ': ' + err.getMessage());
                                log.addLog('OpportunityShare fields that affected this error: ' + err.getFields());
                            }
                        }
                        if (sr.isSuccess()) {                
                           System.debug('Record successfully created: ' + sr.getId());
                           //log.addLog('OpportunityShare records that got created: ' + sr.getId());
                           oppShareSuccess.add(sr.getId());
                        }
                    }  
                	String oppShareData = '';
                    for(Id i : oppShareSuccess){
                        oppShareData += (String)i + ', ';
                    }
                    oppShareData = oppShareData.removeEnd(', ');
        			oppShareData += '.'; 
                	log.addLog('OpportunityShare records that got created: ' +oppShareData);
                
                	log.createLog(infLog);
            }
            catch(Exception e){
            	System.debug('Error : ' + e.getMessage());
       		}
        }
    }
    
    global void finish(Database.BatchableContext BC){
        IF_Log  log = new IF_Log();
        String guId  = IF_Util.generateGuid();
        IF_Log.InterfaceLog infLog = new IF_Log.InterfaceLog( 'OpportunityShare_Batch', guId, 'Batch_OpportunityShareRecordCreateComp', 'finish', '', '');
        log.addLog('OpportunityShare records created successfully');
        log.createLog(infLog);
    }
    
    public void execute(SchedulableContext SC){
        Batch_OpportunityShareRecordCreateComp batch = new Batch_OpportunityShareRecordCreateComp();
        DataBase.executeBatch(batch, 200);
    }
}