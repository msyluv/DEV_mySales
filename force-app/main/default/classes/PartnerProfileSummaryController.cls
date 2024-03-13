/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 08-29-2022
 * @last modified by  : ukhyeon.lee@samsung.com
**/
public without sharing class PartnerProfileSummaryController {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> partnerProfileSummary(String recId) {
        Map<String, Object> resultMap = new Map<String, Object>();
        String reAuthCnt = '0';
        Decimal businessAmountSum = 0;
        Decimal partnerDiscount = 0;    
        Decimal paidMigrationFund = 0;
        Decimal paidMarketingFund = 0;
        Decimal incentive = 0;
        Decimal partnerBenefit = 0;
        
        try{
            List<User> userList = [SELECT Id, AccountId, Email, Profile.Name, MobilePhone, CreatedDate FROM User WHERE isActive = true AND Id=:recId];
            if(!userList.isEmpty()){
                User user = userList[0];
                
                List<Account> accountList = [SELECT Id, Name, Partner_Type__c, Phone, Website, CorporateNumber__c, BillingStreet FROM Account WHERE isDeleted = false AND Id=: user.AccountId];
                if(!accountList.isEmpty()){
                    Account account = accountList[0];
                    
                    List<Partner_ReAuth_Requirement__c> prrList = [SELECT Id, Performance__c FROM Partner_ReAuth_Requirement__c WHERE Account__c=:account.Id AND toLabel(detail1__c)='자격 인증'];
                    if(!prrList.isEmpty()){
                        Partner_ReAuth_Requirement__c prr = prrList[0];
                        reAuthCnt = prr.Performance__c;
                    }
                    
                    for(Partner_Business_Management__c pbm : [SELECT Id, Partner_Account__c, Amount__c FROM Partner_Business_Management__c WHERE Partner_Account__c=:account.Id]){
                        businessAmountSum += pbm.Amount__c;
                    }

                    //TO-DO
                    //Partner Benefit = Discount + Paid Mig, Marketing Fund + Incentive 
                    
                    for(PartnerFundClaim pfc : [SELECT Id, Amount FROM PartnerFundClaim WHERE Status__c='Paid' AND ChannelPartnerId=:account.Id]){
                        paidMarketingFund += pfc.Amount;
                    }                   

                    partnerBenefit = partnerDiscount + paidMigrationFund+ paidMarketingFund + incentive;

                }
            }
        } catch(Exception e){
            System.debug(e.getMessage());
        }
        resultMap.put('reAuthCnt', reAuthCnt);
        resultMap.put('businessAmountSum', businessAmountSum/1000000);
        resultMap.put('partnerBenefit', partnerBenefit/1000000);

        return resultMap;
    }
}