global without sharing class BizClassMigController {
    
    @AuraEnabled    
    global static void executeBatch(String strOppIdSet, String strStartDate, String strEndDate, Boolean isModified){
        Set<Id> setOppId = new Set<Id>();
        List<String> listOppId = strOppIdSet.replaceAll('\'','').split(',');
        system.debug('### BizClassMigController :: executeBatch :: listOppId size = ' + listOppId.size());
        
        for(String strOppId : listOppId){
            if(!String.isEmpty(strOppId)){
                setOppId.add(strOppId.trim());
            }
        }
        
        system.debug('### BizClassMigController :: executeBatch :: strOppIdSet = ' + setOppId);
        
        system.debug('### BizClassMigController :: executeBatch :: strStartDate = ' + strStartDate);
        system.debug('### BizClassMigController :: executeBatch :: endDate = ' + strEndDate);
       
        String strPrefix = UserInfo.getName();
    	Id batchJobId = Database.executeBatch(new Batch_BizClassMigController(strPrefix, setOppId, strStartDate, strEndDate, isModified), 200);
    }
}