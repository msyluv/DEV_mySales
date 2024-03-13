/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-07-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2020-12-31   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class IF_CelloTestShipDataSendController_Test {
    final static String REQUEST_URL = '/services/apexrest/WebService/IF123';
    static Account acc = Utils_TestDataFactory.createAccount('TestAcc');
    static Opportunity oppty = Utils_TestDataFactory.createOpportunity('TestOppty', acc.id);

    @TestSetup
    static void makeData(){
        
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
        '       { ' +
        '           "Opportunity": "'+oppty.id+'", ' +
        '           "Name": "TS181000003", ' +
        '           "cRevenueStartDate": "2020-10-19", ' +
        '           "cRevenueEndDate": "2021-03-26", ' +
        '           "ServiceType": "03", ' +
        '           "Route": "싱가폴 말련", ' +
        '           "Amount": "99999999.000000", ' +
        '           "isDeleted": "N" ' +
        '       } ' +
        '    ] ' +
        '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_CelloTestShipDataSendController.saveData();

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

            IF_CelloTestShipDataSendController.saveData();

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
        '       { ' +
        '           "Opportunity": "'+oppty.id+'", ' +
        '           "Name": "TS181000003", ' +
        '           "cRevenueStartDate": "2020-10-19", ' +
        '           "cRevenueEndDate": "2021-03-26", ' +
        '           "ServiceType": "03", ' +
        '           "Route": "싱가폴 말련", ' +
        '           "Amount": "99999999.000000", ' +
        '           "isDeleted": "N" ' +
        '       } ' +
        '    ] ' +
        '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_CelloTestShipDataSendController.saveData();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }
}