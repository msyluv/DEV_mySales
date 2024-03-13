/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-21-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   01-21-2021   soohong0.kim@partner.samsung.com   Initial Version
**/

@isTest
public class KnoxEmailCancelController_Test {

    @TestSetup
    static void setData(){
        KnoxEmail__c email = new KnoxEmail__c();
        email.ToAddress__c = 'test@test.com';
        email.CcAddress__c = 'test@test.com';
        email.BccAddress__c = 'test@test.com';
        email.MailId__c = 'test';
        insert email;

        Employee__c emp1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'EPID1');

        User salesRepHqUser1 = Utils_TestDataFactory.createUserFull(
                Utils_TestDataFactory.getProfile('Sales Rep.(HQ)')
                , emp1.EvMailAddr__c
                , emp1.EvUniqID__c);
    }

    private static testMethod void KnoxEmailCancelController_Test() {

        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());
        User salesRepHqUser1 = [select id, FederationIdentifier from User where FederationIdentifier = 'EPID1' limit 1];
        
        System.runAs(salesRepHqUser1) {
            Map<String, Object> paramMap = new Map<String,Object>();
            KnoxEmail__c obj = [select id, ToAddress__c, CcAddress__c, BccAddress__c, MailId__c from KnoxEmail__c where MailId__c = 'test' limit 1];
            paramMap.put('KnoxEmail__c',obj);

            KnoxEmailCancelController.cancelKnoxEmail(JSON.serialize(paramMap));        
        }
        
    
        Test.stopTest();
    }


}