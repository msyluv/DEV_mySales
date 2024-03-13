/**
 * @description       : 
 * @author            : zenith21c@test.com
 * @group             : 
 * @last modified on  : 08-16-2022
 * @last modified by  : ukhyeon.lee@samsung.com
**/
public with sharing class PartnerSignupReconsentController {
    
    @AuraEnabled(cacheable=true)
    public static List<Partner_Signup_T_C_Agreement__c> getPartnerTCAgreement(String recId) {
        User email = [SELECT Id, Username FROM User WHERE Id = :recId];
        String userEmail = email.Username;
        return [SELECT Name, Partner_T_C_Name__c, Partner_Signup__c, isAgree__c, Agreement_Date__c FROM Partner_Signup_T_C_Agreement__c WHERE Partner_Signup__c IN (
            SELECT Id FROM Partner_Signup_Request__c WHERE Partner_ID__c = :userEmail
        ) ORDER BY Partner_T_C_Name__c ASC];
    }

    @AuraEnabled
    public static void updatePartnerTCAgreement(String partnerSignup , List<String> updatedList){
        List<Partner_Signup_T_C_Agreement__c> pStc = new List<Partner_Signup_T_C_Agreement__c>();

        for(String tncidVal: updatedList) {
            Partner_Signup_T_C_Agreement__c ps = new Partner_Signup_T_C_Agreement__c();
            ps.isAgree__c = true;
            ps.Partner_Signup__c = partnerSignup.replaceAll('"', '');
            ps.Agreement_Date__c = Date.today();
            ps.Partner_T_C_Name__c = tncidVal.replaceAll('"', '');
            pStc.add(ps);
        }
        
        insert pStc;
    }

    @AuraEnabled(cacheable=true)
    public static List<Partner_T_C_Master__c> getReconsentTCList(String recId) {

        List<Partner_T_C_Master__c> resultList = new List<Partner_T_C_Master__c>();

        User email = [SELECT Id, Username FROM User WHERE Id = :recId AND Username LIKE '%sdspartner'];
        String userEmail = email.Username;
        
        List<Partner_T_C_Master__c> tcMasterList = [SELECT Id, Name, T_C_Type__c, Apply_Date__c, T_C_Detail__c
                                                    FROM Partner_T_C_Master__c
                                                    WHERE T_C_Use__c = 'Sign Up'
                                                    AND isActive__c = true
                                                    ORDER BY Id ASC];
        
        List<Partner_Signup_T_C_Agreement__c> userAgreeList = [SELECT Id, Name, Partner_T_C_Name__c
                                                                FROM Partner_Signup_T_C_Agreement__c
                                                                WHERE Partner_Signup__c IN 
                                                                (SELECT Id FROM Partner_Signup_Request__c WHERE Partner_ID__c = :userEmail)
                                                                ORDER BY LastModifiedDate DESC];
        
        Map<Id, Partner_Signup_T_C_Agreement__c> userAgreeMap = new Map<Id, Partner_Signup_T_C_Agreement__c>();
        
        if (!userAgreeList.isEmpty()){
            for(Partner_Signup_T_C_Agreement__c ua : userAgreeList){
                if (!userAgreeMap.containsKey(ua.Partner_T_C_Name__c)){
                    userAgreeMap.put(ua.Partner_T_C_Name__c, ua);
                }
            }
        }
        
        for(Partner_T_C_Master__c tm : tcMasterList){
            if(userAgreeMap.isEmpty() || !userAgreeMap.containsKey(tm.Id)){
                resultList.add(tm);
            }
        }
        
        return resultList;
    }
}