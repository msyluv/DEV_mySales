/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 08-31-2022
 * @last modified by  : gitesh.s@samsung.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   08-31-2022   gitesh.s@samsung.com    Added Community Login Profile
**/
@isTest(SeeAllData=true)
private class PartnerFundClaimTrigger_Test {
    
    static User partner, partnerLoginProfile, mspAdmin;
    static PartnerFundRequest pfrDraft, pfrSubmitted, pfrDraftNew, pfrSubmittedNew;
    static PartnerFundClaim pfcDraft, pfcSubmitted, pfcDraftNew, pfcSubmittedNew;
    static {
        partner = [Select Id From User Where Profile.Name='Partner Community Manager' and isActive=true Limit 1];
        
        /*Ver 1.0 Added Community Login Profile*/
        partnerLoginProfile = [Select Id From User Where Profile.Name='Partner Community Login Manager' and isActive=true Limit 1];
        mspAdmin = [Select Id From User Where Profile.Name='MSP Admin' and isActive=true Limit 1];
        
        Account a = new Account(
            Name = 'Test',
            Partner_Type__c = 'Reseller'
        );
        insert a;
        a.IsPartner = true;
        update a;

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

        PartnerFundRequest pfrApprovedNew = new PartnerFundRequest(
            AllocationId = pfa.Id,
            ChannelPartnerId =a.Id,
            Title = 'Test New',
            Amount = 10,
            RequestedAmount = 4,
            Status = 'Approved',
            OwnerId = partnerLoginProfile.Id
        );
        insert pfrApprovedNew;

        pfcDraftNew = new PartnerFundClaim(
            requestId = pfrApprovedNew.Id,
            Title = 'Test New',
            Amount = 10,
            Status = 'Draft',
            Status__c = 'Claimable',
            OwnerId = partnerLoginProfile.Id
        );
        insert pfcDraftNew;

        pfcSubmittedNew = new PartnerFundClaim(
            requestId = pfrApprovedNew.Id,
            Title = 'Test New',
            Amount = 10,
            Status = 'Submitted',
            Status__c = 'Submitted'
        );
        insert pfcSubmittedNew;
        
    }
    
    @isTest
    public static void updateToSubmitted() {
        Test.startTest();
        System.runAs(partner){
            pfcDraft.Status__c = 'Submitted';
            update pfcDraft;
        }
        Test.stopTest();
    }

    @isTest
    public static void updateToApproved() {
        Test.startTest();
        System.runAs(mspAdmin){
            pfcSubmitted.Status__c = 'Approved';
            update pfcSubmitted;
        }
        Test.stopTest();
    }

    @isTest
    public static void updateToRejected() {
        Test.startTest();
        System.runAs(mspAdmin){
            pfcSubmitted.Status__c = 'Rejected';
            update pfcSubmitted;
        }
        Test.stopTest();
    }

    @isTest
    public static void updateToSubmittedLoginProfile() {
        Test.startTest();
        System.runAs(partnerLoginProfile){
            pfcDraftNew.Status__c = 'Submitted';
            update pfcDraftNew;
        }
        Test.stopTest();
    }

    @isTest
    public static void updateToApprovedLoginProfile() {
        Test.startTest();
        System.runAs(mspAdmin){
            pfcSubmittedNew.Status__c = 'Approved';
            update pfcSubmittedNew;
        }
        Test.stopTest();
    }

    @isTest
    public static void updateToRejectedLoginProfile() {
        Test.startTest();
        System.runAs(mspAdmin){
            pfcSubmittedNew.Status__c = 'Rejected';
            update pfcSubmittedNew;
        }
        Test.stopTest();
    }
}