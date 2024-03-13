/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-10-19
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2020-12-01   seonju.jin@dkbmc.com   Initial Version
**/
@isTest
public class OpportunitySolutionItemController_Test {
    static Master_Solution__c master_solution;
	static Service__c service;
    static Opportunity opport;
    static Opportunity opport2;
    static SvcSolBizAttr__c svcSolAttr;
    static BizAttribute__c bizAttr;
    static Master_Service__c master_service;
    static Solution__c solution;

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

        opport.CollaborationInOut__c = 'IN';
        opport.CollaborationBOId__c = opport2.Id;

        opport2.CollaborationInOut__c = 'OUT';
        opport2.CollaborationBOId__c = opport.Id;

        update opport;
        update opport2;

        master_service = new Master_Service__c(
            Name = 'test',
            Code__c = '12313',
            Use__c = true
        );
        insert master_service;
        
        service = new Service__c(
            //Name = 'testservice',
            Opportunity__c = opport2.Id,
            Service__c = master_service.Id
        );
        insert service;
        
        Date d = System.today();
        Date startDate = d.addDays(-7);
        Date endDate = d.addDays(7);
        master_solution = new Master_Solution__c(
            Name ='Test Solution 1 - 1',
            Code__c = '123',
            Service__c = service.Service__c,
            Use__c = true,
            ValidityEndDate__c = endDate,
            ValidityStartDate__c = startDate
        ); 
        insert master_solution;

        bizAttr = new BizAttribute__c(
            Name = 'testbizattr',
            Code__c = '123123',
            Active__c = true
        );
        insert bizAttr;

        svcSolAttr = new SvcSolBizAttr__c(
            BizAttribute__c = bizAttr.Id,
            Solution__c = master_solution.Id,
            Use__c = true
        );
        insert svcSolAttr;

        solution = new Solution__c(
            Service__c = service.Id,
            Solution__c = master_solution.Id,
            BizAttribute__c = bizAttr.Id
        );
        insert solution;
        
    }
    
    @isTest public static void test_method_01(){
        Test.startTest();
        //OpportunitySolutionItemController.getSolutionOptions(service.Service__c, opport.Id, opport.CollaborationBOId__c, true, true,  OpportunityServiceSolutionMainController.INIT_SERVICE, false);
		OpportunitySolutionItemController.getSolutionOptions(service.Service__c, opport.Id, opport.CollaborationBOId__c, true, true, false);

        
        //List<String> solIdList, String solPSType, Boolean psTypeCheck, String solRecordId
        OpportunitySolutionItemController.getBizAttributeOptions(new List<String>{master_solution.Id}, 'SI', true);
        OpportunitySolutionItemController.getBizAttributeOptions(new List<String>{master_solution.Id}, '', false);
        OpportunitySolutionItemController.getSalesTypeOptions();
        Test.stopTest();
    }
    @isTest public static void test_method_02(){
        Test.startTest();
        //OpportunitySolutionItemController.getSolutionOptions(service.Service__c, opport.Id, '', false, false, OpportunityServiceSolutionMainController.NORMAL_SERVICE, true);
        OpportunitySolutionItemController.getSolutionOptions(service.Service__c, opport.Id, '', false, false, true);
        Test.stopTest();
    }
    @isTest public static void test_method_03(){
        Test.startTest();
        //OpportunitySolutionItemController.getSolutionOptions(service.Service__c, opport.Id, '', false, false, OpportunityServiceSolutionMainController.TECH_SERVICE, true);
        OpportunitySolutionItemController.getSolutionOptions(service.Service__c, opport.Id, '', false, false, true);
        Test.stopTest();
    }
    @isTest public static void test_method_04(){
        Test.startTest();
        //OpportunitySolutionItemController.getSolutionOptions(service.Service__c, opport.Id, '', false, false, OpportunityServiceSolutionMainController.TECH_SERVICE, true);
        OpportunitySolutionItemController.getSolutionduplicterecord(service.id, opport.Id, solution.BizAttribute__c, solution.Solution__c);
        Test.stopTest();
    }

}