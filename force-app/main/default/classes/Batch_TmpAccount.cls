//account 필드 업데이트용 temp batch
public class Batch_TmpAccount implements Database.Stateful, Database.Batchable<sObject>, Database.AllowsCallouts{
    List<Account> updateList;
    public String lastId = '';
    public Integer querySize = 0;
    public String limitNo = '5000';
    
    
    public Batch_TmpAccount(String lastId){
        system.debug('--------- constructor ---------');
        system.debug('LastId : '+lastId);
        system.debug('querySize : '+querySize);
        system.debug('--------------------------');
        this.lastId = lastId;
        updateList = new List<Account>();
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = '';
        if(lastId == ''){
            query = 'select id, accountnumber, externalId__c from account where AccountNumber != null and externalId__c = null order by id asc limit '+limitNo;
        } 
        else{
            query = 'select id, accountnumber, externalId__c from account where AccountNumber != null and externalId__c = null and id >: lastId order by id asc limit '+limitNo;
        }
        system.debug('--------- start ---------');
        system.debug('LastId : '+lastId);
        system.debug('querySize : '+querySize);
        system.debug('--------------------------');
        
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Account> objList) {
        querySize += objList.size();
        system.debug('--------- excute ---------');
        system.debug('LastId : '+lastId);
        system.debug('querySize : '+querySize);
        system.debug('--------------------------');
        
        system.debug('start approval size : '+objList.size());
        try{
            for(Account obj : objList){
                obj.ExternalId__c = obj.AccountNumber;
                updateList.add(obj);
                lastId = obj.id;
           }

        }catch(Exception e){
            System.debug('e : '+e);
            system.debug('e.getLine : '+e.getLineNumber());
        }
    }

    public void finish(Database.BatchableContext bc) {
        system.debug('--------- finish ---------');
        system.debug('LastId : '+lastId);
        system.debug('querySize : '+querySize);
        system.debug('updateList.size : '+updateList.size());
        system.debug('--------------------------');
        try{
            
            if(updateList.size()>0) Database.update(updateList,false);

            if(querySize >= Integer.valueOf(limitNo) ){
                system.debug('----------------- batch recursion');
                database.executeBatch(new Batch_TmpAccount(lastId));
            }

        }catch(Exception e){
            System.debug('e : '+e);
            System.debug('e.stack trace'+e.getStackTraceString());
            System.debug('e.Line : '+e.getLineNumber());
        }
    }


}