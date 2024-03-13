/**
* @description       : 
* @author            : akash.g@samsung.com
* @group             : 
* @last modified on  : 07-27-2022
* @last modified by  : akash.g@samsung.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   07-27-2022   akash.g@samsung.com       Initial Version 
**/
@isTest
public class IF_DemandCallInAPIControllerTest {
    final static String REQUEST_URL = '/services/apexrest/WebService/IF157';
    static Opportunity oppty;
    public static Opportunity hqOpportunity;
    @TestSetup
    static void setData(){
        hqOpportunity = new Opportunity(
            Name = 'test',
            CurrencyIsoCode='EUR',
            OpportunityCode__c='SDS-123123',
            StageName= 'stage1',
            BusinessType__c='TI',
            CloseDate = System.today()
        );
        insert hqOpportunity;
    }
    
    @isTest
    static void restServiceCatchTest() {
        Test.startTest();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        
        Account acc = Utils_TestDataFactory.createAccount('Test Account 1');
        acc.AccountNumber = 'ACCTEST1';
        update acc;
        //Profile p = [Select id from Profile where name = 'System Administrator'];
        //User u = Utils_TestDataFactory.createUserFull(p,'test.g@sds.com',);
        IF_DemandCallInAPIController.InputHeader input = new IF_DemandCallInAPIController.InputHeader();        
        input.Name = 'Test Lead 1';
        input.Lead_Type = '31';
        input.Account = acc.accountNumber;
        input.Owner = 'akash.g1';
        input.Description = 'Test Desc.';
        input.Requester_Name = 'test.name';
        input.Requester_ID = 'testID';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_DemandCallInAPIController.doPost();
        Test.stopTest();
    }
    
    @isTest
    static void restServiceTest() {
        Test.startTest();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        
        Account acc = Utils_TestDataFactory.createAccount('Test Account 1');
        acc.AccountNumber = 'ACCTEST1';
        update acc;
        Profile p = [Select id from Profile where name = 'System Administrator'];
        User u = Utils_TestDataFactory.createUserFull(p,'test.g@sds.com','test');
        IF_DemandCallInAPIController.InputHeader input = new IF_DemandCallInAPIController.InputHeader();        
        input.Name = 'Test Lead 1';
        input.Lead_Type = '31';
        input.Account = acc.accountNumber;
        input.Owner = 'test.g';
        input.Description = 'Test Desc.';
        input.Requester_Name = 'test.name';
        input.Requester_ID = 'testID';
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_DemandCallInAPIController.doPost();
        Test.stopTest();
    }
}