/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-05-25
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   01-07-2021   soohong0.kim@partner.samsung.com   Initial Version
**/

@isTest
public class IF_SdBOStatusUpdateController_Test {
    final static String REQUEST_URL = '/services/apexrest/WebService/IF103';
    static Account acc;
    static Opportunity oppty;
    static Opportunity coOpp;
    private static String opptyCode = 'Test Code';
    private static STring companyCode = 'test';
    @TestSetup
    static void setData(){

        Company__c company = new Company__c();
        company.Name = 'test';
        company.CompanyCode__c = companyCode;
        insert company;
        
        CostCenter__c cCenter = new CostCenter__c();
        cCenter.CostCenter__c = 'test12';
        cCenter.Company__c = company.id;
        insert cCenter;


        Map<String,String> pickMap = new Map<String,String>();
        acc = Utils_TestDataFactory.createAccount('TestAcc');
        acc.AccountNumber = 'A2222233';
        acc.MDGCheck__c   = true;
        update acc;
        

        RecordType rcType = [Select id From RecordType where SobjectType = 'Opportunity' And DeveloperName = 'HQ'];
        pickMap = Utils.getPicklistOptionType('Opportunity','BusinessLevel__c')[0];
        oppty = Utils_TestDataFactory.createOpportunity('TestOppty', acc.id);
        oppty.cOriginAcc__c = acc.id;
        oppty.Amount = 1234124;
        oppty.BusinessLevel__c = pickMap.get('value');
        oppty.OpportunityCode__c = opptyCode;
        oppty.RecordTypeId = rcType.id;
        oppty.SalesDepartment__c = cCenter.id;
        
        coOpp = Utils_TestDataFactory.createOpportunity('TestCoOppty', acc.id);
        coOpp.cOriginAcc__c = acc.id;
        coOpp.Amount = 1234124;
        coOpp.BusinessLevel__c = pickMap.get('value');
        update coOpp;
        
        oppty.CollaborationBOId__c = coOpp.id;
        update oppty;
    }

    private static testMethod void restServiceTest() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;        
        request.httpMethod = 'POST';

        IF_SdBOStatusUpdateController.InputClass input = new IF_SdBOStatusUpdateController.InputClass();
        input.IV_BUKRS = companyCode;
        input.IV_ZZORDER_ID = opptyCode;
      

        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_SdBOStatusUpdateController.updateOppty();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }
}