/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-07
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2021-01-04   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class IF_EccProjectStrategySession_Test {
    final static String REQUEST_URL = '/services/apexrest/WebService/IF003';
    static Account acc = Utils_TestDataFactory.createAccount('TestAcc');
    static Opportunity oppty = Utils_TestDataFactory.createOpportunity('TestOppty', acc.id, 'SDS-20054670', 'ZP61');
    static Opportunity_Activity__c opptyAct = Utils_TestDataFactory.createOpportunityActivity(oppty.Id, 'ZP61');

    public IF_EccProjectStrategySession_Test() {

    }

    @TestSetup
    static void makeData(){
        
    }

    @isTest 
    static void restServiceTestAll() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;        
        request.httpMethod = 'POST';

        String reqeustBody =
        '{ ' +
        '    "DATA": [ ' +
        '      { ' +
        '        "IV_BUKRS": "T100", ' +
        '        "IV_ZZORDER_ID": "SDS-20054670", ' +
        '        "I_PROCESSTYPE": "ZP61" ' +
        '      } ' +
        '    ] ' +
        '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_EccProjectStrategySessionController.getProjectStrategySession();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }

    @isTest 
    static void restServiceTest() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;        
        request.httpMethod = 'POST';

        String reqeustBody =
        '{ ' +
        '    "DATA": [ ' +
        '      { ' +
        '        "IV_BUKRS": "", ' +
        '        "IV_ZZORDER_ID": "", ' +
        '        "I_PROCESSTYPE": "ZP61" ' +
        '      } ' +
        '    ] ' +
        '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_EccProjectStrategySessionController.getProjectStrategySession();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }


    @isTest 
    static void restServiceTest_DATA_NULL() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;        
        request.httpMethod = 'POST';

        String reqeustBody = 
        '{ ' +
        '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_EccProjectStrategySessionController.getProjectStrategySession();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }

    @isTest 
    static void restServiceTest_Exception() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;        
        request.httpMethod = 'POST';

        String reqeustBody =
        '{ ' +
        '    "DATA_Exception": [ ' +
        '      { ' +
        '        "IV_BUKRS": "T100", ' +
        '        "IV_ZZORDER_ID": "SDS-20054670", ' +
        '        "I_PROCESSTYPE": "ZP61" ' +
        '      } ' +
        '    ] ' +
        '}';


        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_EccProjectStrategySessionController.getProjectStrategySession();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }
}