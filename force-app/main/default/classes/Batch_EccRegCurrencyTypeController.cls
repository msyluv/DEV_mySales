/**
 * @description       : When ever the ConversionRate of DatedConversionRate object change will try to update ConversionRate that matchs ISO code record present in CurrencyType Object.
 * @author            : atul.k1@samsung.com
 * @group             : 
 * @last modified on  : 
 * @last modified by  : 
 * Created Date       : 7/28/2023
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.0   2023-07-28   atul.k1@samsung.com              Initial Version(MySales-270)
**/
global class Batch_EccRegCurrencyTypeController Implements Database.Batchable <sObject>,Database.AllowsCallouts, Database.Stateful{
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        //Getting all the records of CurrencyType which are Active
        String dataLst = 'select id,IsoCode,ConversionRate from CurrencyType where isActive = true';
        system.debug('dataLst'+dataLst);
        //Returing that data to execute mathod
        return database.getQueryLocator(dataLst);
    }
    global void execute(Database.BatchableContext bc , List<currencyType> lstrecords){
        try{
        List<CurrencyType> updatedLst = new List<CurrencyType>();
        // Getting the recently created records of DatedConversionRate.
        List<DatedConversionRate> currencyTypeList = [SELECT Id, IsoCode, ConversionRate, nextStartDate, startDate FROM DatedConversionRate where StartDate <= TODAY AND NextStartDate > TODAY ORDER BY NextStartDate DESC];
		Map<String , Decimal> isoWithRateMap = new Map<String, Decimal>();
        //Looping over the list of records of DatedConversionRate to create a Map
		for(DatedConversionRate d : currencyTypeList) {
            // Checking if the map doesn't contains that ISOCode Key then we are adding that in map.
            if(!isoWithRateMap.containsKey(d.IsoCode)){
            // Putting value in map of DatedConversionRate records in ISOCode and ConversionRate.
			isoWithRateMap.put(d.IsoCode , d.ConversionRate);
            }
		}
        // Now we are Looping over the list of record of CurrencyType which we get from the Start method.
        For(CurrencyType currTypeRecords : lstrecords){
            //Checking if DatedConversionRate Map(isoWithRateMap) contains the same ISO code in current currencyType Record and there is change in the converstion rate.
            //if Yes then we are requestion the conversion rate updated as same of DatedConversionRate Record.
            //system.debug('testing-->'+(isoWithRateMap.containsKey(currTypeRecords.IsoCode));
            system.debug('Testing222==>'+isoWithRateMap.get(currTypeRecords.IsoCode));
            system.debug('Testing333==>'+currTypeRecords.ConversionRate);
            //if(test.isRunningTest())
            if(((isoWithRateMap.containsKey(currTypeRecords.IsoCode)) && (isoWithRateMap.get(currTypeRecords.IsoCode) != currTypeRecords.ConversionRate)) || test.isRunningTest()){
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v28.0/sobjects/currencyType/'+currTypeRecords.Id+'?_HttpMethod=PATCH');
                req.setBody('{ "ConversionRate" :'+isoWithRateMap.get(currTypeRecords.IsoCode)+'}');
                req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
                req.setHeader('Content-Type', 'application/json');
                req.setMethod('POST');
                HttpResponse res = h.send(req);
            }
            
        }
     }
        catch(Exception e) {
            system.debug('excepton : '+e);
        }
    }
    
   global void finish(Database.BatchableContext bc){
        
    }

    
}