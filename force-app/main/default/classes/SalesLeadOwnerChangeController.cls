/**
* @author            : vikrant.ks@samsung.com
* @group             : 
* @description       : 
* @last modified on  : 2024-01-31
* @last modified by  : vikrant.ks@samsung.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   2024-01-31   vikrant.ks@samsung.com    Initial Version
**/
public class SalesLeadOwnerChangeController{
    
    @AuraEnabled
    public static String OwnerChangeAlertMsg(String SalesLeadId){
        DateTime temp = DateTime.now().addSeconds(-120);
        List<Sales_Lead__c> SLList = [Select Id,Owner_Change_Time__c from Sales_Lead__c where Id = :SalesLeadId and Owner_Change_Time__c > :temp and Owner_Change_Time__c != Null Limit 1];
        if(SLList.size()>0){
            SLList[0].Owner_Change_Time__c = Null;
            update SLList;
            return System.Label.SalesLeadOwnerChangeAlertMsg;
        }
        return 'NoOwnerChange';
    }

}