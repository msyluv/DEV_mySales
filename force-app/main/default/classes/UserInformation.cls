public with sharing class UserInformation {
    @AuraEnabled(cacheable=true)
    public static Profile getUserInformation(String recId) {
        return [SELECT Id, Name FROM Profile WHERE Id IN (
            SELECT ProfileId FROM User WHERE Id = :recId
        )];
    }
}