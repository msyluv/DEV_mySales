/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 08-11-2022
 * @last modified by  : ukhyeon.lee@samsung.com
**/
@IsTest(SeeAllData=true) 
public with sharing class FundOverviewController_Test {    
    static User partner, mspAdmin;
    static PartnerFundRequest pfrDraft, pfrSubmitted;
    static PartnerFundClaim pfcDraft, pfcSubmitted;
    static {
              

        partner = [Select Id, AccountId From User Where AccountId!=null AND Account.isPartner=true and isActive=true Limit 1];
        Account a =[SELECT Id FROM Account WHERE Id=:partner.AccountId LIMIT 1];

        PartnerMarketingBudget pmb = new PartnerMarketingBudget(
            Title = 'Test',
            Amount = 100,
            Type = 'Marketing Funds'
        );
        insert pmb;

        PartnerFundAllocation pfa = new PartnerFundAllocation(
            Title = 'Test',
            Amount = 10,
            ChannelPartnerId = a.Id,
            budgetId = pmb.Id
        );
        insert pfa;
        
        PartnerFundRequest pfrApproved = new PartnerFundRequest(
            AllocationId = pfa.Id,
            ChannelPartnerId =a.Id,
            Title = 'Test',
            Amount = 10,
            RequestedAmount = 2,
            Status = 'Approved',
            OwnerId = partner.Id
        );
        insert pfrApproved;

        pfcDraft = new PartnerFundClaim(
            requestId = pfrApproved.Id,
            Title = 'Test',
            Amount = 10,
            Status = 'Draft',
            Status__c = 'Claimable',
            OwnerId = partner.Id
        );
        insert pfcDraft;

        pfcSubmitted = new PartnerFundClaim(
            requestId = pfrApproved.Id,
            Title = 'Test',
            Amount = 10,
            Status = 'Submitted',
            Status__c = 'Submitted'
        );
        insert pfcSubmitted;
        
    }
    
    @isTest
    public static void updateToSubmitted() {
        Test.startTest();
        FundOverviewController.getFundInformation(partner.Id);
        Test.stopTest();
    }
}