/**
* @description       : 
* @author            : akash.g@samsung.com
* @group             : 
* @last modified on  : 06-17-2022
* @last modified by  : akash.g@samsung.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   06-17-2022   akash.g@samsung.com       Initial Version
**/
@isTest
public class IF_SdUpdatePMFieldController_Test {
    final static String REQUEST_URL = '/services/apexrest/WebService/IF156';
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
    static void restServiceTest() {
        Test.startTest();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        Opportunity tmpOppty = [SELECT Id, OpportunityCode__c, CompanyCode__c FROM Opportunity ];
        Employee__c emp = new Employee__c(EvSapEmpNO__c = '12345');
        insert emp;
        IF_SdUpdatePMFieldController.InputHeader input = new IF_SdUpdatePMFieldController.InputHeader();        
        input.BO_CODE = tmpOppty.OpportunityCode__c;
        input.Company_Code = tmpOppty.CompanyCode__c;
        input.Proposal_PM = emp.EvSapEmpNO__c;
        input.Exec_PM = emp.EvSapEmpNO__c;
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;
        IF_SdUpdatePMFieldController.doPost();
        Test.stopTest();
    }
}