/**
 * @author            : sarthak.j1@samsung.com
 * @group             : 
 * @description       : Batch Class for OpportunityShare record creation
 * @last modified on  : 2024-03-08
 * @last modified by  : sarthak.j1@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2024-03-08   sarthak.j1@samsung.com   Initial Version
**/
global class Batch_OpportunityShareRecordCreation implements DataBase.Batchable<SObject>{
    
    List<Group> listofcloudRole = [Select Id from Group Where (DeveloperName = 'mig20005' OR DeveloperName = 'mig20002')
                                       AND type = 'RoleAndSubordinates'ORDER By DeveloperName desc limit 2];
    
    global DataBase.QueryLocator start(DataBase.BatchableContext BC){
        String query_RESULT = '';
        String query_SELECT = 'SELECT ';
        String query_FROM   = ' FROM Opportunity';
        String query_WHERE  = ' WHERE ';
        
        query_SELECT +='  Id ' +		
                        ', Cost_Center_Level_2__c ' + 
            			', S3_Check__c ' +
            			', S4_Check__c ';
        
        query_RESULT = query_SELECT + query_FROM;
        
        query_WHERE +=' Cost_Center_Level_2__c = \'T100S3\' OR Cost_Center_Level_2__c = \'T100S4\'';
        
        query_RESULT += query_WHERE;
        
        Database.QueryLocator returnScope = DataBase.getQueryLocator(query_RESULT);
        return returnScope;      
    }
    
    global void execute(DataBase.BatchableContext BC, List<Opportunity> scopeList){
        List<OpportunityShare> optyShareList = new List<OpportunityShare>();
        
        for(Opportunity opp : scopeList){
            if(opp.Cost_Center_Level_2__c == 'T100S3' && opp.S3_Check__c == false){
                	OpportunityShare optyShare = new OpportunityShare();
                    optyShare.OpportunityId = opp.Id;
                    optyShare.UserOrGroupId = listofcloudRole[0].Id;
                    optyShare.OpportunityAccessLevel = 'Read';
                    optyShare.RowCause = 'Manual';
                    optyShareList.add(optyShare);
            }
            else if(opp.Cost_Center_Level_2__c == 'T100S4' && opp.S4_Check__c == false){
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
                    IF_Log.InterfaceLog infLog = new IF_Log.InterfaceLog( 'OpportunityShare_Batch', guId, 'Batch_OpportunityShareRecordCreation', 'execute', '', '');
                
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
                    }  
                
                	log.createLog(infLog);
            }
            catch(Exception e){
            	System.debug('Error : ' + e.getMessage());
       		}
        }
    }
    
    global void finish(DataBase.BatchableContext BC){
        
    }
}