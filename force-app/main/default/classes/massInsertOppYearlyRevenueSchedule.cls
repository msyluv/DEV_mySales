/**
 * @description       : Insert New data of Opportunity yearly Revenue Schedule Object
 * @author            : d.ashish@samsung.com
 * @group             : 
 * @last modified on  : 02-21-2024
 * @last modified by  : d.ashish@samsung.com
 * Modifications Log 
 * Ver   Date         Author            		Modification
 * 1.0   02-21-2024   d.ashish@samsung.com     Initial Version(MySales -450)
**/

global class massInsertOppYearlyRevenueSchedule Implements Database.Batchable <sObject> {
    
    global Database.queryLocator start(Database.BatchableContext bc) {
        String node = System.Label.YearlyRevenueScheduleNote2;
        String SOQL = 'Select id,name,cRevenueStartDate__c,cRevenueEndDate__c,CurrencyIsoCode,Amount from Opportunity where cPrimarySalesDepartment__r.Node2__c =:node   AND cRevenueStartDate__c != null AND cRevenueEndDate__c != null AND Amount != null AND StageName NOT IN (\'Z07\',\'Z08\') AND CloseDate >= 2023-01-01 AND RecordType.Name = \'HQ\' AND CompanyCode__c = \'T100\''; //클라우드서비스사업부  \'T100S4\' and cPrimaryDeliveryDivision__c = \'솔루션사업부\' \'Z06\',
        return Database.getQueryLocator( SOQL );
        
    }

    global void execute( Database.BatchableContext bc, List<Opportunity> listRecords ) {            
        List<Yearly_Revenue_Schedule__c> yrs = new List<Yearly_Revenue_Schedule__c>();
        Map<String,string> oppIds = new Map<String,string>();
        for(Opportunity opp : listRecords){
            oppIds.put(opp.Id,'');
        }
        for(Delivery_Probabiliy__c delObj : [Select id,Opportunity__c, name from Delivery_Probabiliy__c where Opportunity__c in:oppIds.keyset()]){
            oppIds.put(delObj.Opportunity__c,delObj.Id);
        }
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
            if(numOfSchedule > 0){
        	Decimal splitRev = (amount / numOfSchedule).setscale(2);
        	Decimal splitSum = splitRev * numOfSchedule;
        	Decimal splitGap = amount - splitSum;
	          integer yearNo = scheduleDate.year();
            Date firstJanschDate= Date.newInstance(scheduleDate.year(),1,1);
        	    Yearly_Revenue_Schedule__c yrsObj = new Yearly_Revenue_Schedule__c(name = 'Yearly Revenue for '+ yearNo, ContractYearDate__c = firstJanschDate, OpportunityId__c =opp.id);
               if(!oppIds.isEmpty() && oppIds.get(opp.Id) != '')
                  yrsObj.Delivery_probability__c = oppIds.get(opp.Id);
                yrsObj.CurrencyIsoCode = curr;
                yrs.add(yrsObj);
        
        	for(Integer count = 0; count <= duration; count++){
            	RevenueScheduleOpportunity__c rs = new RevenueScheduleOpportunity__c();
                //MYSALES-450
			if(scheduleDate.year() != yrsObj.ContractYearDate__c.year()){
                firstJanschDate= Date.newInstance(scheduleDate.year(),1,1);
        	    yrsObj = new Yearly_Revenue_Schedule__c(name = 'Yearly Revenue for '+ scheduleDate.year(), ContractYearDate__c = firstJanschDate, OpportunityId__c =opp.Id);
            if(!oppIds.isEmpty() && oppIds.get(opp.Id) != '')
                  yrsObj.Delivery_probability__c = oppIds.get(opp.Id);
                yrsObj.CurrencyIsoCode = curr;
                
               yrs.add(yrsObj);
            } 
            
            	rs.CurrencyIsoCode = curr;
            	if(count < duration){
                        //MYSALES-450
				OppRevenueSchTriggerHandler.setYearlyRevenueAmount(yrsObj, scheduleDate, splitRev);				
            
            	} else {
                        //MYSALES-450
				OppRevenueSchTriggerHandler.setYearlyRevenueAmount(yrsObj, endDate, splitRev + splitGap);				
            
            	}
            	//lrs.add(rs);
            	scheduleDate = scheduleDate.addMonths(1);
            }}
        }
        if(!yrs.isEmpty()){
            Database.SaveResult[] srList = Database.insert(yrs, false);
            
        }
    }

    global void finish( Database.BatchableContext bc ) {
    
    }

}