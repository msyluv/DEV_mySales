/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 02-17-2022
 * @last modified by  : ukhyeon.lee@samsung.com
**/
public class WeeklyReportLinkController { 
    @AuraEnabled
    public static Map<String, Object> getBOId(String boCode){
        Map<String, String> rtnMap = new Map<String, String>();
        List<Opportunity> ids = [select id from Opportunity where OpportunityCode__c=:boCode and CompanyCode__C='T100'];
        rtnMap.put('cnt', String.valueOf(ids.size()));
        if(ids.size()==1){
            rtnMap.put('id', String.valueOf(ids[0].id));
        }
        return rtnMap;
    }
}