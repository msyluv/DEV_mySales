/**
 * @description       : 
 * @author            : dongyoung.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-01-18
 * @last modified by  : dongyoung.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-01-18   dongyoung.kim@dkbmc.com   Initial Version
**/
public class KnoxApprovalHTMLController {
    @AuraEnabled
    public static List<KnoxApproval__c> getKnoxAppInfo(Id recordId){
        List<KnoxApproval__c> getKnoxAppInfo = [SELECT id, HTML__C
                                                FROM KnoxApproval__c 
                                                WHERE id =: recordId];
        return getKnoxAppInfo;
    }
}