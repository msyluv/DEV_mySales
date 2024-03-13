/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-28-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   01-28-2021   soohong0.kim@partner.samsung.com   Initial Version
**/
@isTest
public class IF_OpenQAVrbCheckController_Test {
    final static String REQUEST_URL = '/services/apexrest/WebService/IF061';
    static Account acc;
    static Opportunity oppty;

    @TestSetup
    static void setData(){
        Map<String,String> pickMap = new Map<String,String>();
        acc = Utils_TestDataFactory.createAccount('TestAcc');
        acc.AccountNumber = 'A1065555';
        acc.MDGCheck__c = true;
        update acc;
        
        Company__c company = new Company__c();
        company.EPCompanyCode__c = 'A11';
        insert company;

        CostCenter__c cCenter = new CostCenter__c();
        cCenter.Company__c = company.id;
        insert cCenter;
        
        RecordType rec = [SELECT id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ'];
    
        pickMap = Utils.getPicklistOptionType('Opportunity','BusinessLevel__c')[0];
        oppty = Utils_TestDataFactory.createOpportunity('TestOppty', acc.id);
        oppty.cOriginAcc__c = acc.id;
        oppty.Amount = 1234124;
        oppty.BusinessLevel__c = pickMap.get('value');
        Test.setCreatedDate(oppty.Id, Date.today().addYears(-4));
        oppty.OpportunityCode__c = 'testcode';
        oppty.RecordTypeId = rec.id;
        oppty.SalesDepartment__c = cCenter.id;

        pickMap = Utils.getPicklistOptionType('Opportunity','VRBMethod__c')[0];
        oppty.VRBMethod__c = pickMap.get('value');
        update oppty;

        Biz_Review__c bizReview = new Biz_Review__c();
        bizReview.Opportunity__c = oppty.id;
        insert bizReview;

        Question__c question = new Question__c();
        question.BOBizReview__c = bizReview.id;
        pickMap = Utils.getPicklistOptionType('Question__c','Category1__c')[0];
        question.Category1__c = pickMap.get('value');
        pickMap = Utils.getPicklistOptionType('Question__c','Category1__c')[0];
        question.Category2__c = pickMap.get('value');
        question.Question__c = 'test';
        insert question;

        Answer__c answer = new Answer__c();
        answer.BOQuestion__c = question.id;
        answer.EvaluationDepartmentEvaluationBasis__c = 'test';
        pickMap = Utils.getPicklistOptionType('Answer__c','AnswnerGroupCode__c')[0];
        answer.AnswnerGroupCode__c = pickMap.get('value');
        answer.Score__c = 111;
        insert answer;


    }


    private static testMethod void restServiceTest() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;        
        request.httpMethod = 'POST';
        IF_OpenQAVrbCheckController.InputHeader input = new IF_OpenQAVrbCheckController.InputHeader();
        input.ZZORDER_ID = 'testcode';
        input.EP_COMPANY = 'A11';


        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_OpenQAVrbCheckController.doPost();

        } catch (Exception e) {
            system.debug(e);
            system.debug('e.getLine : '+e.getLineNumber());
        }        

        Test.stopTest();
    }
}