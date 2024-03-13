@isTest
public class ObjectMemory_Test {
    
    private static testMethod void test01() {
        //Account 생성
        Account rowAcc1 = new account(Name = 'Acme', Description = 'Acme Account');
        insert rowAcc1;
        
        Account rowAcc2 = new account(Name = 'Mark', Description = 'Mark Account');
        insert rowAcc2;
        
        Account clonedAcc = rowAcc1.clone(true, true);
        
        Account rowAcc3 = [SELECT Id, Name, Description FROM Account WHERE Id = :rowAcc1.Id];
        System.assertEquals(rowAcc1, clonedAcc);
        
        /*
        Account clonedAcc = acc.clone(false, false, false, false);
        System.assertEquals(acc, clonedAcc);
        
        Map<String, opportunity> mapOppty = new Map<String, opportunity>();
        
        opportunity rowOppty1 = [select id, name, RecordTypeId, CurrencyIsoCode from opportunity where id = '0061s00000XyPgFAAV'];
        opportunity rowOppty2 = [select id, name, RecordTypeId, CurrencyIsoCode from opportunity where id = '0061s00000XyPgFAAV'];
        opportunity rowOppty3 = new opportunity(id = rowOppty1.id, name = rowOppty1.name, RecordTypeId = rowOppty1.RecordTypeId, CurrencyIsoCode = rowOppty1.CurrencyIsoCode);
        
        mapOppty.put(rowOppty1.id,rowOppty1);
        
        //Account clonedAcc = acc.clone(false, false, false, false);
        System.assertEquals(rowOppty1, rowOppty2);        
        
        //system.debug('### rowOppty1 = ' + rowOppty1);
        //system.debug('### rowOppty1 = ' + rowOppty1);
        //system.debug('### rowOppty2 = ' + rowOppty2);
        //system.debug('### rowOppty3 = ' + rowOppty3);
        //system.debug('### map.rowOppty1 = ' + mapOppty.get(rowOppty1.id)); 
        */     
        
    }
    
}