/**
 * @description       : Delete existing data of Opportunity Revenue Schedule Object
 * @author            : aditya.r2@samsung.com
 * @group             : 
 * @last modified on  : 07-24-2023
 * @last modified by  : aditya.r2@samsung.com
 * Modifications Log 
 * Ver   Date         Author            		Modification
 * 1.0   07-23-2023   aditya.r2@samsung.com     Initial Version(MySales -262)
**/
global class massDeleteOppRevenueSchedule Implements Database.Batchable <sObject> {
    
    global Database.queryLocator start(Database.BatchableContext bc) {
        String node = System.Label.RevenueScheduleNote2;
        String SOQL = 'Select id,name from RevenueScheduleOpportunity__c where Parent__r.cPrimarySalesDepartment__r.Node2__c =: node    AND Parent__r.CloseDate >= 2023-01-01'; //클라우드서비스사업부 \'T100S4\' and Parent__r.cPrimaryDeliveryDivision__c = \'솔루션사업부\'
        return Database.getQueryLocator( SOQL );
        
    }

    global void execute( Database.BatchableContext bc, List<RevenueScheduleOpportunity__c> listRecords ) {       
        
        delete listRecords;       
    }

    global void finish( Database.BatchableContext bc ) {
    
        if(!Test.isRunningTest()){
        	massInsertOppRevenueSchedule b = new massInsertOppRevenueSchedule();
        	Database.executeBatch(b);
        }
    }

}