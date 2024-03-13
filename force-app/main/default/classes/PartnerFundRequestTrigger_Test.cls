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
@isTest
private class PartnerFundRequestTrigger_Test {
    
    static User partner, partnerLoginProfile, mspAdmin;
    static PartnerFundRequest pfrDraft, pfrSubmitted, pfrDraftNew, pfrSubmittedNew;
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
        
        pfrDraft = new PartnerFundRequest(
            AllocationId = pfa.Id,
            ChannelPartnerId =a.Id,
            Title = 'Test',
            Amount = 10,
            RequestedAmount = 2,
            Status = 'Draft',
            OwnerId = partner.Id
        );
        insert pfrDraft;

        pfrSubmitted = new PartnerFundRequest(
            AllocationId = pfa.Id,
            ChannelPartnerId =a.Id,
            Title = 'Test',
            Amount = 10,
            RequestedAmount = 2,
            Status = 'Submitted'
        );
        insert pfrSubmitted;

        pfrDraftNew = new PartnerFundRequest(
            AllocationId = pfa.Id,
            ChannelPartnerId =a.Id,
            Title = 'Test New',
            Amount = 10,
            RequestedAmount = 4,
            Status = 'Draft',
            OwnerId = partnerLoginProfile.Id
        );
        insert pfrDraftNew;

        pfrSubmittedNew = new PartnerFundRequest(
            AllocationId = pfa.Id,
            ChannelPartnerId =a.Id,
            Title = 'Test New',
            Amount = 10,
            RequestedAmount = 4,
            Status = 'Submitted'
        );
        insert pfrSubmittedNew;
    }
    
    @isTest
    public static void updateToSubmitted() {
        Test.startTest();
        System.runAs(partner){
            pfrDraft.Status = 'Submitted';
            update pfrDraft;
        }
        Test.stopTest();
    }

    @isTest
    public static void updateToApproved() {
        Test.startTest();
        System.runAs(mspAdmin){
            pfrSubmitted.Status = 'Approved';
            update pfrSubmitted;
        }
        Test.stopTest();
    }

    @isTest
    public static void updateToRejected() {
        Test.startTest();
        System.runAs(mspAdmin){
            pfrSubmitted.Status = 'Rejected';
            update pfrSubmitted;
        }
        Test.stopTest();
    }

    @isTest
    public static void updateToSubmittedLoginProfile() {
        Test.startTest();
        System.runAs(partnerLoginProfile){
            pfrDraftNew.Status = 'Submitted';
            update pfrDraftNew;
        }
        Test.stopTest();
    }

    @isTest
    public static void updateToApprovedLoginProfile() {
        Test.startTest();
        System.runAs(mspAdmin){
            pfrSubmittedNew.Status = 'Approved';
            update pfrSubmittedNew;
        }
        Test.stopTest();
    }

    @isTest
    public static void updateToRejectedLoginProfile() {
        Test.startTest();
        System.runAs(mspAdmin){
            pfrSubmittedNew.Status = 'Rejected';
            update pfrSubmittedNew;
        }
        Test.stopTest();
    }
}