/**
 * @description       : 
 * @author            : Junghwa.Kim@dkbmc.com
 * @group             : 
 * @last modified on  : 11-25-2020
 * @last modified by  : Junghwa.Kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   11-24-2020   Junghwa.Kim@dkbmc.com   Initial Version
**/
public class SalesLeadPathController {
    @AuraEnabled
    public static Map<String, List<Object>> getStageVal(String recordId){
        Map<String, List<Object>> returnMap = new Map<String, List<Object>>();
        List<Sales_Lead__c> sl = [SELECT Id, LeadStage__c FROM Sales_Lead__c WHERE Id = :recordId];

        List<String> picVal = new List<String>();
        Schema.DescribeFieldResult Category2Result = Sales_Lead__c.LeadStage__c.getDescribe();
        List<Schema.PicklistEntry> Category2ple = Category2Result.getPicklistValues();  
        for(Schema.PicklistEntry p : Category2ple){
            picVal.add(String.valueOf(p.label));
        }

        returnMap.put('SalesLead', sl);
        returnMap.put('picVal', picVal);

        return returnMap;
    }
}