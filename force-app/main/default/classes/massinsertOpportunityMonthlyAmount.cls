global class massinsertOpportunityMonthlyAmount Implements Database.Batchable <sObject> {
    
    global Database.queryLocator start(Database.BatchableContext bc) {
        
        String SOQL = 'Select id,name,cRevenueStartDate__c,cRevenueEndDate__c,CurrencyIsoCode,Amount from Opportunity where cPrimaryDeliveryDivision__c = \'클라우드서비스사업부\' AND cRevenueStartDate__c != null AND cRevenueEndDate__c != null';
        system.debug('SOQL Query ----> '+ SOQL);
        return Database.getQueryLocator( SOQL );
        
    }

    global void execute( Database.BatchableContext bc, List<Opportunity> listRecords ) {            
        List<Opportunity_MonthlyAmount__c> oppMA = new List<Opportunity_MonthlyAmount__c>();        
        List<DatedConversionRate> currencyTypeList = [SELECT Id, IsoCode, ConversionRate, nextStartDate, startDate FROM DatedConversionRate where StartDate <= TODAY AND NextStartDate > TODAY ORDER BY NextStartDate DESC];
		Map<String , Decimal> isoWithRateMap = new Map<String, Decimal>();
		for(DatedConversionRate d : currencyTypeList) {
			isoWithRateMap.put(d.IsoCode , d.ConversionRate);
		}
        
        for(Opportunity opp : listRecords){
            Date StartDate = opp.cRevenueStartDate__c;
            Decimal exchnageRate = (isoWithRateMap.get('KRW')/isoWithRateMap.get(opp.CurrencyIsoCode));

            Date EndDate = opp.cRevenueEndDate__c;
            Integer Period = (((EndDate.year())-(StartDate.year()))*12+(EndDate.month())-(StartDate.month())+1);
            Decimal MonthlyAmount = (opp.Amount)/Period;
            Date currentDate = opp.cRevenueStartDate__c;
            
            for(Integer i=0; i < Period; i++){
               	Opportunity_MonthlyAmount__c omc = new Opportunity_MonthlyAmount__c();
               	omc.Opportunity_id__c = opp.Id;
               	omc.Contract_Start_Date__c = opp.cRevenueStartDate__c;
               	omc.Contract_End_Date__c = opp.cRevenueEndDate__c;
               	omc.Period__c = String.valueOf(Period);
               	omc.Monthly_Amount__c = (MonthlyAmount*exchnageRate).setscale(2);
                omc.CurrencyIsoCode = 'KRW';
                Integer month = currentDate.month();
                Integer year = currentDate.year();
                omc.Month__c = String.valueOf(year)+'/'+String.valueOf('0'+month).right(2);
                currentDate = currentDate.addMonths(1);
                oppMA.add(omc);
            }
        }
        if(!oppMA.isEmpty()){
            Database.SaveResult[] srList = Database.insert(oppMA, false);
            
            /*for (Database.SaveResult sr : srList) {
   				if (sr.isSuccess()) {
      				// This condition will be executed for successful records and will fetch the ids of successful records
      				System.debug('Successfully inserted : ' + sr.getId());
      				// Get the invoice id of inserted Account
     			} else {
      				// This condition will be executed for failed records
      				for(Database.Error objErr : sr.getErrors()) {
         				System.debug('The following error has occurred.');
         
         				// Printing error message in Debug log
         				System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
         				System.debug('Oject field which are affected by the error:' + objErr.getFields());
      				}
   				}
			}*/
        }
    }

    global void finish( Database.BatchableContext bc ) {
    
    }

}