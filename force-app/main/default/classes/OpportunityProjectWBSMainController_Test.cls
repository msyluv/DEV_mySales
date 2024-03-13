/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2020-12-04
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-12-04   seonju.jin@dkbmc.com   	Initial Version
**/

@isTest
public class OpportunityProjectWBSMainController_Test {
	public static Opportunity opprty; 
    public static Project__c project; 
    public static WBS__c wbs;
    static{
    	opprty = new Opportunity(
            Name = 'test',
            StageName= 'stage1',
            CloseDate = System.today()
        );
        insert opprty;
        
        project = new Project__c(
            Opportunity__c =  opprty.Id,
            Name = 'Test2',
            Description__c = 'Test2',
            ProjectCode__c = 'testProject002'
        );
        insert project;
        
        wbs = new WBS__c(
            OpportunityID__c = opprty.Id,
        	ServiceCode__c = '124',
        	ProjectCode__c = 'testProject002',
        	SolutionCode__c = '123123'
        );
        insert wbs;
    }
    
    @isTest public static void test_method_01(){
        OpportunityProjectWBSMainController.getProjectInfo(opprty.Id);
        OpportunityProjectWBSMainController.getWBSInfo(opprty.Id, project.ProjectCode__c);
        OpportunityProjectWBSMainController.getAllProejctWBSInfo(opprty.Id);
    }
}