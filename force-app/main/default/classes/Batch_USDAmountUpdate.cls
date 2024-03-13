global class Batch_USDAmountUpdate implements DataBase.stateful, DataBase.Batchable<SObject> {
    List<Opportunity> OppLstUpdate = new List<Opportunity>();
    Map<id,Decimal> oppidAmount = new Map<id,Decimal>();
    //public Batch_USDAmountUpdate() {  }
     global DataBase.QueryLocator start(Database.BatchableContext BC){
         List<String> queryString = new List<String>();
         Database.QueryLocator returnScope;
         Set<ID> userIdSet =new Set<ID>{'0061s00000cL2ROAA0','0061s00000aaODDAA2','0061s00000cL7IGAA0'}; 
             //List<String> userIdSet =  new List<String>();
                    
                    //userIdSet = system.label.Weekly_Report_Users.split(',');
                    String idList = '\''+String.join(userIdSet,'\',\'')+'\'';
                     queryString.add('Select Id , name, convertCurrency(Amount) Amount,Amount_USD__c from Opportunity');
                        //queryString.add(' WHERE RecordType.Name=\'HQ\' AND companycode__c != \'T100\' AND Id IN ('+idList+')');
                        queryString.add(' WHERE Id IN('+idList +')');  
         returnScope = DataBase.getQueryLocator(String.join(queryString,''));            
            return returnScope;            
     }
    global void execute(DataBase.BatchableContext BC, List<Opportunity> OppLst){
        Set<ID> oppidSet = new Set<ID>();
        for(Opportunity oppeach : OppLst){
            oppidSet.add(oppeach.id);
        }
        List<Opportunity> oppNewLst = [SELECT id,name,Amount FROM Opportunity Where id IN: oppidSet];
        For(Opportunity oppLstEach : oppNewLst){
            system.debug('convertCurrency Number'+oppLstEach.Amount);
            if(!oppidAmount.containsKey(oppLstEach.id)){
                oppidAmount.put(oppLstEach.id,oppLstEach.Amount);
            }
        }
        For(Opportunity opp: OppLst){
            system.debug('Amount==>'+opp.Amount);
            system.debug('setscale==>'+Opp.Amount.setscale(2));
            Decimal val = opp.Amount.setscale(2);
            system.debug('Amount==>After'+val);
            //String strFormattedcurrency = '$' + String.valueOf(val.format());
           // system.debug('ConvertAmount'+opp.get(FORMAT(convertCurrency('Amount'))ConvertedinUserCurrency));
            opp.Amount_USD__c = val;
            opp.Amount = oppidAmount.get(opp.id);
            
            OppLstUpdate.add(opp);
        }
        if(!OppLstUpdate.isEmpty()){
            update OppLstUpdate;
        }
         
         
     }
     global void finish(Database.BatchableContext BC){
     }
    

}