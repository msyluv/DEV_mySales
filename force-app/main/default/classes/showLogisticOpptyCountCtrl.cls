/**
 * @description       : Controller of showLogisticOpptyCount Aura cmp
 * @author            : d.ashish@samsung.com
 * @group             : 
 * @last modified on  : 2023-06-06
 * @last modified by  : d.ashish@samsung.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2023-06-06   d.ashish@samsung.com   Initial Version
**/

public class showLogisticOpptyCountCtrl {
@AuraEnabled
    public static List<BO_Matrix_cnt__c> getCount(){
        return [select id,From_RHQ__c,To_RHQ__c,Count__c,Related_Report__c,LastModifiedDate  from BO_Matrix_cnt__c order by From_RHQ__c,To_RHQ__c asc];
    }
@AuraEnabled
    public static User getUserDetail(){
        return [select id,Name,User_RHQ__c  from User where id =: UserInfo.getUserId() Limit 1];
    }

}