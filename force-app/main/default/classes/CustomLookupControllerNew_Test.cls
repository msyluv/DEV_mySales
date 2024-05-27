/**
 * @author            : divyam.gupta@samsung.com
 * @group             : 
 * @description       : Test class for CustomLookupControllerNew
 * @last modified on  : 2024-05-10
 * @last modified by  : divyam.gupta@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2024-05-10   divyam.gupta@samsung.com	Initial Version
**/

@isTest
public class CustomLookupControllerNew_Test {
    public static WeeklyReport__c wr;
    static {
        // [Trigger Switch Setting ]
        TriggerSwitch__c profileSwitch = new TriggerSwitch__c(
            All__c = true,
            Opportunity__c = true,
            SetupOwnerId = UserInfo.getProfileId()
        );
        insert profileSwitch;

        RecordType recordId = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'HQ' Limit 1];
        
        Account accAct = new Account(Name = 'accTest', MDGCheck__c = true);

        insert accAct;

        Opportunity oppty = new Opportunity(Name ='Test', RecordTypeId = recordId.Id, AccountId =accAct.Id,
                                            CloseDate =System.today(), StageName = 'Z01');
        insert oppty;

        wr = new WeeklyReport__c(
            Name = 'Weekly Report', 
            ReportingDate__c = system.today(), 
            Critical__c = true,
            Contents__c = 'longtext contents',
            CheckedforIssue__c = true,
            IssueDescription__c = '<div>test</div>'
        );

        insert wr;
        Campaign campaign1 = new Campaign(Name = 'test1');
        insert campaign1;
        
        CostCenter__c costCenter = new CostCenter__c(CostCenterName__c = 'Test1', Name ='Test1');
        insert costCenter;
      /*  Sales_Lead__c sl = new Sales_Lead__c(
            Name = 'TestSalesLead', 
            CampaignId__c = campaign1.Id,
            Company__c = 'Company__c',
            Email__c = 'tse@sdfjo.com.vop',
            LeadChannel__c='Demand',
            LeadStage__c = 'Hot',
            Amount__c = 5000, 
            CloseDate__c = Date.today().addDays(1),  
            RevenueEndDate__c = Date.today().addDays(3), 
            RevenueStartDate__c = Date.today().addDays(2),
            Budget__c = true,
            Authority__c = true,
            SalesDepartment__c = costCenter.Id
        );
		insert sl;  */
    }
    
    public static testMethod void CustomLookupControllerTest(){
        ApexPages.currentPage().getParameters().put('name','Test');
        ApexPages.currentPage().getParameters().put('objname', 'Opportunity');
        CustomLookupControllerNew custlook = new CustomLookupControllerNew();
    } 
      public static testMethod void CustomLookupControllerTest1(){
        ApexPages.currentPage().getParameters().put('name','Test');
        ApexPages.currentPage().getParameters().put('objname', 'Account');
        CustomLookupControllerNew custlook = new CustomLookupControllerNew();
    } 
    public static testMethod void CustomLookupControllerTest2(){
        ApexPages.currentPage().getParameters().put('name','Test');
        ApexPages.currentPage().getParameters().put('objname', 'Sales Lead');
        CustomLookupControllerNew custlook = new CustomLookupControllerNew();
    } 

}