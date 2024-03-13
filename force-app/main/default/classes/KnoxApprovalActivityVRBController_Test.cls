@isTest
public class KnoxApprovalActivityVRBController_Test {
    static Account acc;
	static Opportunity opp;
    static User user1;
    static Employee__c emp4;
    static Biz_Review__c biz;
    static{
        acc = Utils_TestDataFactory.createAccount('TestAccount');
		opp = Utils_TestDataFactory.createOpportunity('TestOpportunity', acc.Id);
        emp4 = Utils_TestDataFactory.createEmployee('TestEmp4', 'EPID4');
        user1 = Utils_TestDataFactory.createUserFull(Utils_TestDataFactory.getProfile('System Administrator'), emp4.EvMailAddr__c, emp4.EvUniqID__c);
        biz = new Biz_Review__c(
            Opportunity__c = opp.id
        );
    }
    
    @isTest
    static void getStrategyInfo(){
        Test.startTest();
        System.runAs(user1){
            KnoxApprovalActivityVRBController.getStrategyInfo(biz.id);
        }
        Test.stopTest();
    }
}