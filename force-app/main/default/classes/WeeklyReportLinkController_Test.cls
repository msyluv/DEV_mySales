/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 02-17-2022
 * @last modified by  : ukhyeon.lee@samsung.com
**/
@isTest
private class WeeklyReportLinkController_Test {
    static Opportunity opportunity;
    static final String BO_CODE = 'SDS-12345678';
    
    static {
        opportunity = new Opportunity(
            Name = 'test',
            CurrencyIsoCode='EUR',
            StageName= 'stage1',
            OpportunityCode__c='SDS-12345678',
            CloseDate = System.today(),            
            Opportunity_Review_Checkbox1__c=false,
            Opportunity_Review_Checkbox2__c=false,
            Opportunity_Review_Consortium__c=false,
            Opportunity_Review_Exception__c=false,            
            Opportunity_Review_VRB_Type__c='10',
            BusinessType__c='TI'            
        );        
        insert opportunity;
        
    }
    
    @isTest static void test_method_1() {
        Test.startTest();
        WeeklyReportLinkController.getBOId(BO_CODE);
		Test.stopTest();
	}
}