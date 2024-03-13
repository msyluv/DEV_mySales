@isTest
public class KnoxApprovalHistoryController_Test {
	@isTest
    static void OpptActyInfo() {
        KnoxApproval__c KnoxAppInfo = new KnoxApproval__c();
        Opportunity opty = new Opportunity();
        Opportunity_Activity__c  optyacty= new Opportunity_Activity__c();
        
        KnoxApprovalHistoryController.getOpptActyInfo(opty.Id, optyacty.Id);
        KnoxApprovalHistoryController.getPickList();
    }
}