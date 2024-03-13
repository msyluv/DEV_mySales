/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 11-17-2020
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   11-17-2020   soohong0.kim@partner.samsung.com   Initial Version
**/


global class Batch_KnoxApprovalStatusController implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('approval status start ------------------');
        String query = 'SELECT id, MISID__c FROM KnoxApproval__c where MISID__c != null and Status__c != \'2\' ';
        
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<KnoxApproval__c> objList) {
        List<IF_KnoxApprovalStatusController.InputClass> inputList = new List<IF_KnoxApprovalStatusController.InputClass>();
        List<KnoxApproval__c> upsertList = new List<KnoxApproval__c>();
        for(KnoxApproval__c obj : objList){
            inputList.add(new IF_KnoxApprovalStatusController.InputClass(obj.MISID__c));
        }
        system.debug('JSON inputList : '+inputList);
        Map<String,Object> returnMap = IF_KnoxApprovalStatusController.approvalStatus(inputList);
        List<Object> dataList = (List<Object>) returnMap.get('data');
        if(String.valueOf(returnMap.get('result')) == 'success'){
            for(Object obj : dataList){
                Map<String,Object> dataMap = (Map<String,Object>) obj;
                KnoxApproval__c target = new KnoxApproval__c();
                target.MISID__c = String.valueOf(dataMap.get('apInfId'));
                target.Status__c = String.valueOf(dataMap.get('status'));
    
                upsertList.add(target);
            }
            system.debug('upsertList : '+upsertList);
    
            Schema.SObjectField keys = KnoxApproval__c.Fields.MISID__c;
            
            system.debug(Database.upsert(upsertList, keys, false));
        }
        

    }

    global void finish(Database.BatchableContext bc) {
        
    }

    global void execute(SchedulableContext sc) {
        database.executebatch(new Batch_KnoxApprovalStatusController(), 100);
    }

}