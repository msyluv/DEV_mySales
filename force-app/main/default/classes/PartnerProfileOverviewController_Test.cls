/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 08-30-2022
 * @last modified by  : ukhyeon.lee@samsung.com
**/
@isTest(SeeAllData=true)
private class PartnerProfileOverviewController_Test {
    static User partner;
    static {
        partner = [Select Id, AccountId From User Where UserType='PowerPartner' and isActive=true AND Account.isPartner=true Limit 1];
        List<Partner_ReAuth_Requirement__c> prrList = new List<Partner_ReAuth_Requirement__c>();
        

        Partner_Business_Management__c pbm = new Partner_Business_Management__c(
            Project_Name__c = 'test',
            Partner_Account__c = partner.AccountId,
            Amount__c=5000,
            SDS_Sales_Email__c = 'test@test.com' ,
            SDS_Sales__c = 'test',
            mBizTypeL1Code__c = 'L100',
            Discount_Rate__c = '5',
            Contract_No__c = 'A123123'
        );
        insert pbm;

        Partnership_Info__c pi = new Partnership_Info__c(
            Contract_Start_Date__C = Date.newInstance(2022, 1, 1),
            Contract_End_Date__C = Date.newInstance(2022, 2, 17)
        );
        insert pi;

        PartnerMarketingBudget pmb = new PartnerMarketingBudget(
            Title = 'Test',
            Amount = 100,
            Type = 'Marketing Funds'
        );
        insert pmb;

        PartnerFundAllocation pfa = new PartnerFundAllocation(
            Title = 'Test',
            Amount = 10,
            ChannelPartnerId = partner.AccountId,
            budgetId = pmb.Id
        );
        insert pfa;

        PartnerFundRequest pfrApproved = new PartnerFundRequest(
            AllocationId = pfa.Id,
            ChannelPartnerId =partner.AccountId,
            Title = 'Test',
            Amount = 10,
            RequestedAmount = 2,
            Status = 'Approved',
            OwnerId = partner.Id
        );
        insert pfrApproved;

        PartnerFundClaim pfcPaid = new PartnerFundClaim(
            requestId = pfrApproved.Id,
            Title = 'Test',
            Amount = 10,
            Status = 'Draft',
            Status__c = 'Paid',
            OwnerId = partner.Id
        );
        insert pfcPaid;        
    }
    


    @isTest 
    static void PartnerProfileOverviewController_Test() {
        Test.startTest();
        PartnerProfileOverviewController.partnerProfileOverview(partner.AccountId);
		Test.stopTest();
    }
}