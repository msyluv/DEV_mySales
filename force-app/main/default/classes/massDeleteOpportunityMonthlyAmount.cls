global class massDeleteOpportunityMonthlyAmount Implements Database.Batchable <sObject> {
    
    global Database.queryLocator start(Database.BatchableContext bc) {
        
        String SOQL = 'Select id,name from Opportunity_MonthlyAmount__c';
        return Database.getQueryLocator( SOQL );
        
    }

    global void execute( Database.BatchableContext bc, List<Opportunity_MonthlyAmount__c> listRecords ) {       
        
        delete listRecords;       
    }

    global void finish( Database.BatchableContext bc ) {
    
        massinsertOpportunityMonthlyAmount b = new massinsertOpportunityMonthlyAmount();
        Database.executeBatch(b);
    }

}