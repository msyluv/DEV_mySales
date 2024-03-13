/**
@author            : divyam.gupta@samsung.com
  @description       : Warning if Close Date is later than Contract Start Date. 
  @last modified on  : 09-18-2023
  @last modified by  : divyam.gupta@samsung.com
  Modifications Log 
  Ver   Date         Author                     Modification
  1.0   2023-09-18   Divyam.gupta@samsung.com       Initial Version
 **/
public class opportunityCheckCloseDateCont {
    
     @AuraEnabled
    public static String getCloseDatevaluecheck(String oppid){
     
        String msg = '';
        Opportunity opprec =[select id,Check_Close_Date__c,CloseDate,RecordType.DeveloperName,cRevenueStartDate__c,FirstCloseDate__c from Opportunity where id =: oppid];
        if(opprec.RecordType.DeveloperName == 'HQ' && opprec.cRevenueStartDate__c != null && opprec.CloseDate > opprec.cRevenueStartDate__c && opprec.FirstCloseDate__c == null){
            opprec.Check_Close_Date__c = false;
            update opprec;
            msg = 'CheckCloseDate';
        }
        
        return msg;
        
    }

}