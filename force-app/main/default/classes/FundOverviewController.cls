/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 08-09-2022
 * @last modified by  : ukhyeon.lee@samsung.com
**/
public without sharing class FundOverviewController {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getFundInformation(String recId) {
        Map<String, Object> resultMap = new Map<String, Object>();
        Set<Id> claimIds = new Set<Id>();
        Decimal fundAllocationAvailable = 0;
        Decimal fundRequestSubmittedAndApproved =0;
        Decimal fundClaimApproved = 0;
        Decimal fundClaimPaid = 0;

        List<PartnerFundAllocation> pfaList = [SELECT Amount, TotalApprovedFrs, TotalApprovedFcs FROM PartnerFundAllocation WHERE ChannelPartnerId IN (SELECT AccountId FROM User WHERE Id=:recId) AND Amount != Null];
        if(!pfaList.isEmpty()){
            for(PartnerFundAllocation pfa : pfaList){
                fundAllocationAvailable += pfa.Amount;
            }   
        }


        List<PartnerFundClaim> pfcList = [SELECT Amount, Status__c, RequestId FROM PartnerFundClaim WHERE Status__c IN ('Approved', 'Paid') AND ChannelPartnerId IN (SELECT AccountId FROM User WHERE Id=:recId) AND Amount != Null];
        if(!pfcList.isEmpty()){
            for(PartnerFundClaim pfc : pfcList){
                if(pfc.Status__c=='Approved'){
                    fundClaimApproved += pfc.Amount;
                } else{
                    fundClaimPaid += pfc.Amount;
                }
                claimIds.add(pfc.RequestId);
            }
        }     
        
        List<PartnerFundRequest> pfrList = [SELECT RequestedAmount, Amount, Status FROM PartnerFundRequest WHERE Status IN ('Submitted', 'Approved') AND ChannelPartnerId IN (SELECT AccountId FROM User WHERE Id=:recId) AND Id!=:claimIds];
        if(!pfrList.isEmpty()){            
            for(PartnerFundRequest pfr : pfrList){
                if('Submitted' == pfr.Status && pfr.RequestedAmount != Null){
                    fundRequestSubmittedAndApproved += pfr.RequestedAmount;
                } else if('Approved' == pfr.Status && pfr.Amount != Null){
                    fundRequestSubmittedAndApproved += pfr.Amount;
                }                
            }
        }

       
        resultMap.put('fundAllocationAvailable', fundAllocationAvailable - fundRequestSubmittedAndApproved - fundClaimApproved - fundClaimPaid);
        resultMap.put('fundRequestSubmittedAndApproved', fundRequestSubmittedAndApproved);
        resultMap.put('fundClaimApproved', fundClaimApproved);
        resultMap.put('fundClaimPaid', fundClaimPaid);
        
        return resultMap;
    }
}