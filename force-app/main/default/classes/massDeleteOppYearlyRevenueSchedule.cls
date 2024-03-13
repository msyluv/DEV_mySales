/**
 * @description       : Delete existing data of Opportunity yearly Revenue Schedule Object
 * @author            : d.ashish@samsung.com
 * @group             : 
 * @last modified on  : 02-21-2024
 * @last modified by  : d.ashish@samsung.com
 * Modifications Log 
 * Ver   Date         Author            		Modification
 * 1.0   02-21-2024   d.ashish@samsung.com     Initial Version(MySales -450)
**/
global class massDeleteOppYearlyRevenueSchedule Implements Database.Batchable <sObject> {
    
    global Database.queryLocator start(Database.BatchableContext bc) {
        String node = System.Label.YearlyRevenueScheduleNote2;
        
        system.debug('ashish'+[select id from Yearly_Revenue_Schedule__c]);
        String SOQL = 'Select id,name from Yearly_Revenue_Schedule__c   where OpportunityId__r.cPrimarySalesDepartment__r.Node2__c =: node  AND OpportunityId__r.CloseDate >= 2023-01-01'; //클라우드서비스사업부 \'T100S4\' and Parent__r.cPrimaryDeliveryDivision__c = \'솔루션사업부\'
        return Database.getQueryLocator( SOQL );
        
    }

    global void execute( Database.BatchableContext bc, List<Yearly_Revenue_Schedule__c> listRecords ) {       
        
        delete listRecords;       
    }

    global void finish( Database.BatchableContext bc ) {
    
        if(!Test.isRunningTest()){
        	massInsertOppYearlyRevenueSchedule b = new massInsertOppYearlyRevenueSchedule();
        	Database.executeBatch(b);
        }
    }

}