/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 08-29-2022
 * @last modified by  : ukhyeon.lee@samsung.com
**/
@isTest(SeeAllData=true)
private class PartnerProfileSummaryController_Test {
    static User partner;
    static {
        partner = [Select Id, AccountId From User Where UserType='PowerPartner' and isActive=true AND Account.isPartner=true Limit 1];
        
        List<Partner_ReAuth_Requirement__c> prrList = new List<Partner_ReAuth_Requirement__c>();
        Partner_ReAuth_Requirement__c prr1 = new Partner_ReAuth_Requirement__c(
            Category__C  = '1',
            Detail1__c ='1',
            Account__c = partner.AccountId
        );
        prrList.add(prr1);
        Partner_ReAuth_Requirement__c prr2 = new Partner_ReAuth_Requirement__c(
            Category__C  = '1',
            Detail1__c ='1',
            Detail2__c = '1',
            Account__c = partner.AccountId,
            Goal__c = '3',
            Performance__c='3'
        );
        prrList.add(prr2);
        Partner_ReAuth_Requirement__c prr3 = new Partner_ReAuth_Requirement__c(
            Category__C  = '1',
            Detail1__c = '1',
            Detail2__c = '2',
            Account__c = partner.AccountId,
            Goal__c = '3',
            Performance__c='3'
        );
        prrList.add(prr3);
        Partner_ReAuth_Requirement__c prr4 = new Partner_ReAuth_Requirement__c(
            Category__C  = '1',
            Detail1__c ='1',
            Detail2__c = '3',
            Account__c = partner.AccountId,
            Goal__c = '3',
            Performance__c='3'
        );
        prrList.add(prr4);
        Partner_ReAuth_Requirement__c prr5 = new Partner_ReAuth_Requirement__c(
            Category__C  = '1',
            Detail1__c ='2',
            Account__c = partner.AccountId,
            Goal__c = '3',
            Performance__c='3'
        );
        prrList.add(prr5);
        Partner_ReAuth_Requirement__c prr6 = new Partner_ReAuth_Requirement__c(
            Category__C  = '2',
            Detail1__c ='3',
            Account__c = partner.AccountId
        );
        prrList.add(prr6);
        Partner_ReAuth_Requirement__c prr7 = new Partner_ReAuth_Requirement__c(
            Category__C  = '2',
            Detail1__c ='3',
            Detail2__c = '4',
            Account__c = partner.AccountId,
            Goal__c = '3',
            Performance__c='3'
        );
        prrList.add(prr7);
        Partner_ReAuth_Requirement__c prr8 = new Partner_ReAuth_Requirement__c(
            Category__C  = '2',
            Detail1__c ='3',
            Detail2__c = '5',
            Account__c = partner.AccountId,
            Goal__c = '3',
            Performance__c='3'
        );
        prrList.add(prr8);
        Partner_ReAuth_Requirement__c prr9 = new Partner_ReAuth_Requirement__c(
            Category__C  = '2',
            Detail1__c ='3',
            Detail2__c = '6',
            Account__c = partner.AccountId,
            Goal__c = '3',
            Performance__c='3'
        );
        prrList.add(prr9);
        Partner_ReAuth_Requirement__c prr10 = new Partner_ReAuth_Requirement__c(
            Category__C  = '2',
            Detail1__c ='4',
            Account__c = partner.AccountId,
            Goal__c = '3',
            Performance__c='3'
        );
        prrList.add(prr10);



        insert prrList;

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
    static void PartnerProfileSummaryController_Test() {
        Test.startTest();
        PartnerProfileSummaryController.partnerProfileSummary(partner.Id);
		Test.stopTest();
    }
}