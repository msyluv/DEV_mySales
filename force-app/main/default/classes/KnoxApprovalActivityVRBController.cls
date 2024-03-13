/**
 * @description       : 
 * @author            : dongyoung.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-03-03
 * @last modified by  : Junghwa.Kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-02-03   dongyoung.kim@dkbmc.com   Initial Version
**/
public class KnoxApprovalActivityVRBController {
    @AuraEnabled
    public static List<Biz_Review__c> getStrategyInfo(Id recordId){
        List<Biz_Review__c> StrategyInfo = [SELECT id, IsAnswerCount__c, IsPMAnswerCount__c, TotalQuestionCount__c, Decision__c, CreatedById
                                            FROM Biz_Review__c 
                                            WHERE id =: recordId];
        return StrategyInfo;
    }
}