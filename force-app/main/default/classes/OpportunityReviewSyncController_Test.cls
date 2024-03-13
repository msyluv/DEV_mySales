/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 09-15-2023 
 * @last modified by  : anish.jain@partner.samsung.com
 * 1.1   09-15-2023     anish.jain@partner.samsung.com  BO Review Confirm error on CollaborationBO - MS -298
**/
@isTest
public class OpportunityReviewSyncController_Test {
	public static Opportunity hq21, subs20, hq10, subs30, hq30, subs10;
    public static Project__c project; 
    public static WBS__c wbs;
    public static String inputData;
    public static Map<String, String> inputMap;
    static{
        hq21 = new Opportunity(
            Name = 'test',
            CurrencyIsoCode='EUR',
            OpportunityCode__c='SDS-123123',
            StageName= 'stage1',
            BusinessType__c='TI',
            CloseDate = System.today(),
            Opportunity_Review_Confirm__c=true,
            Opportunity_Review_VRB_Type_Confirm__c='21'            
        );
        subs20 = new Opportunity(
            Name = 'test',
            OpportunityCode__c='SDS-123123',
            StageName= 'stage1',
            BusinessType__c='TI',
            CloseDate = System.today(),        
            Opportunity_Review_Confirm__c=true,
            Opportunity_Review_VRB_Type_Confirm__c='20'
        );

        
        insert hq21;
        insert subs20;
        
        

        Company__c hqc = new Company__c();
        hqc.CompanyCode__c = 'T100';
        hqc.Name = 'hq';
        insert hqc;

        Company__c subsc = new Company__c();
        subsc.CompanyCode__c = 'T810';
        subsc.Name = 'subsc';
        insert subsc;

        CostCenter__c hqCenter = new CostCenter__c();
        hqCenter.CostCenter__c = 'test12';
        hqCenter.Company__c = hqc.id;
        insert hqCenter;
        
        CostCenter__c subsCenter = new CostCenter__c();
        subsCenter.CostCenter__c = 'test13';
        subsCenter.Company__c = subsc.id;
        insert subsCenter;

        Account acc = new Account(
            Name = 'SUBS ACCOUNT',
            AccountNumber = 'A1234567',
            mBizLoan__c = '320',
            MDGCheck__c = true
        );
        insert acc;
        
        hq21.CollaborationBOId__c = subs20.id;
        hq21.SalesDepartment__c =hqCenter.id;
        hq21.cOriginAcc__c = acc.id;
        hq21.AccountId = acc.id;
        
        subs20.CollaborationBOId__c = hq21.id;
        subs20.SalesDepartment__c = subsCenter.id;
        subs20.cOriginAcc__c = acc.id;
        subs20.AccountId = acc.id;

        update hq21;
        update subs20;
    }
    
    @isTest public static void syncVRBType1(){
        OpportunityReviewSyncController.syncVRBType(hq21.Id); //Added by Anish - V 1.1
    }


}