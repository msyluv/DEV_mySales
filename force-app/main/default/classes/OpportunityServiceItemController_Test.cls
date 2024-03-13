/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-10-13
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2020-11-26   seonju.jin@dkbmc.com   Initial Version
**/
@isTest
public class OpportunityServiceItemController_Test {
    static Service__c service;
    static Opportunity opport;
    static Opportunity opport2;
    static Master_Service__c master_service;
    static SvcDlvrDept__c svcDlvrDept;
    static CostCenter__c costCenter;

    static{
        opport = new Opportunity(
            Name = 'Test Oppty',
            CloseDate = System.today(),
            StageName = 'Z01'
		);        
        insert opport;
        
        opport2 = new Opportunity(
            Name = 'Test Oppty2',
            CloseDate = System.today(),
            StageName = 'Z01'
		);        
        insert opport2;

        Date d = System.today();
        Date startDate = d.addDays(-7);
        Date endDate = d.addDays(7);
        master_service = new Master_Service__c(
            Name = 'test',
            Code__c = '12313',
            Use__c = true,
            ValidityEndDate__c = endDate,
            ValidityStartDate__c = startDate
        );
        insert master_service;
        
        opport.CollaborationInOut__c = 'IN';
        opport.CollaborationBOId__c = opport2.Id;

        opport2.CollaborationInOut__c = 'OUT';
        opport2.CollaborationBOId__c = opport.Id;

        update opport;
        update opport2;
        
        service = new Service__c(
            //Name = 'testservice',
            Opportunity__c = opport2.Id,
            Service__c = master_service.Id
        );
        insert service;

        costCenter = new CostCenter__c(
            Name = 'testcost',
            CostCenter__c = '123123',
            ZZCheck__c = true,
            ClosingDate__c = system.today()
        );
        insert costCenter;

        svcDlvrDept = new SvcDlvrDept__c(
            DeliveryDepartment__c = costCenter.Id, 
            Service__c = service.Service__c
        );
        insert svcDlvrDept;
        
    }
    
    @isTest public static void test_method_01(){
        Test.startTest();
        OpportunityServiceItemController.getServiceOptions(opport.CollaborationBOId__c, true, true);
        OpportunityServiceItemController.getDepartmentOptions(new List<String>{service.Service__c});
        Test.stopTest();
    }
    @isTest public static void test_method_02(){
        Test.startTest();
        OpportunityServiceItemController.getServiceOptions(opport.CollaborationBOId__c, false, false);
        Test.stopTest();
    }
}