/**
 * @description       : Insert data of Opportunity Revenue Schedule Object
 * @author            : aditya.r2@samsung.com
 * @group             : 
 * @last modified on  : 07-24-2023
 * @last modified by  : aditya.r2@samsung.com
 * Modifications Log 
 * Ver   Date         Author            		Modification
 * 1.0   07-23-2023   aditya.r2@samsung.com     Initial Version(MySales -262)
**/
global class massInsertOppRevenueSchedule Implements Database.Batchable <sObject> {
    
    global Database.queryLocator start(Database.BatchableContext bc) {
        String node = System.Label.RevenueScheduleNote2;
        String SOQL = 'Select id,name,cRevenueStartDate__c,cRevenueEndDate__c,CurrencyIsoCode,Amount from Opportunity where cPrimarySalesDepartment__r.Node2__c =:node   AND cRevenueStartDate__c != null AND cRevenueEndDate__c != null AND Amount != null AND StageName NOT IN (\'Z07\',\'Z08\') AND CloseDate >= 2023-01-01  '; //\'Z06\', 클라우드서비스사업부  \'T100S4\' and cPrimaryDeliveryDivision__c = \'솔루션사업부\'
        return Database.getQueryLocator( SOQL );
        
    }

    global void execute( Database.BatchableContext bc, List<Opportunity> listRecords ) {            
        list<RevenueScheduleOpportunity__c> lrs = new list<RevenueScheduleOpportunity__c>();
        
        for(Opportunity opp : listRecords){   
        	map<String, Object> baseObj = new map<String, Object>();
            baseObj.put('start', opp.cRevenueStartDate__c);
            baseObj.put('end', opp.cRevenueEndDate__c);
            baseObj.put('amount', opp.Amount);
            baseObj.put('currency', opp.CurrencyIsoCode);

        	String curr = (String) baseObj.get('currency');

        	Date startDate = (Date) baseObj.get('start');
        	Date endDate = (Date) baseObj.get('end');
        	Date scheduleDate = startDate;
        	Integer duration = startdate.monthsBetween(endDate);
        	Integer numOfSchedule = duration + 1;

        	Decimal amount = (Decimal) baseObj.get('amount');
        	//Decimal splitRev = Math.floor(amount / numOfSchedule);
            if(numOfSchedule > 0){
        	Decimal splitRev = (amount / numOfSchedule).setscale(2);
        	Decimal splitSum = splitRev * numOfSchedule;
        	Decimal splitGap = amount - splitSum;

        	for(Integer count = 0; count <= duration; count++){
            	RevenueScheduleOpportunity__c rs = new RevenueScheduleOpportunity__c();
            	rs.CurrencyIsoCode = curr;
            	if(count < duration){
                	rs.ScheduleDate__c = scheduleDate;
                	rs.Revenue__c = splitRev;
                	rs.Parent__c = opp.Id;
                	rs.Period__c = String.valueOf(numOfSchedule);
            	} else {
                	rs.ScheduleDate__c = endDate;
                	rs.Revenue__c = splitRev + splitGap;
                	rs.Parent__c = opp.Id;
                	rs.Period__c = String.valueOf(numOfSchedule);
            	}
            	lrs.add(rs);
            	scheduleDate = scheduleDate.addMonths(1);
            }}
        }
        if(!lrs.isEmpty()){
            Database.SaveResult[] srList = Database.insert(lrs, false);
            
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