@IsTest
public class KnoxApprovalHTMLController_Test {      
 	@isTest
    static void getKnoxAppInfo() {
        KnoxApproval__c KnoxAppInfo = new KnoxApproval__c();
        KnoxApprovalHTMLController.getKnoxAppInfo(KnoxAppInfo.Id);
        KnoxAppInfo.HTML__c = '3';    	
    }
}