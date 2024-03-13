/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-05-25
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2020-12-31   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class IF_CelloApsDataSendController_Test {
    final static String REQUEST_URL = '/services/apexrest/WebService/IF122';
    static Account     acc   = Utils_TestDataFactory.createAccount('TestAcc');
    static{

        acc.MDGCheck__c = true;
        update acc;
    }
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
        '           "APSID": "AP2009003186", ' +
        '           "BiddingType": "Normal Bidding", ' +
        '           "RequestDate": "2020-09-18-19.01.09.000000", ' +
        '           "RequestStatus": "Completed", ' +
        '           "ShippingType": "Air Trans.", ' +
        '           "isDeleted": "N" ' +
        '       } ' +
        '    ] ' +
        '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_CelloApsDataSendController.saveData();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }

    @isTest 
    static void restServiceTest_Delete() {
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
        '           "APSID": "AP2009003186", ' +
        '           "BiddingType": "Normal Bidding", ' +
        '           "RequestDate": "2020-09-18-19.01.09.000000", ' +
        '           "RequestStatus": "Completed", ' +
        '           "ShippingType": "Air Trans.", ' +
        '           "isDeleted": "Y" ' +
        '       } ' +
        '    ] ' +
        '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_CelloApsDataSendController.saveData();

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

            IF_CelloApsDataSendController.saveData();

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
        '           "APSID": "AP2009003186", ' +
        '           "BiddingType": "Normal Bidding", ' +
        '           "RequestDate": "2020-09-18-19.01.09.000000", ' +
        '           "RequestStatus": "Completed", ' +
        '           "ShippingType": "Air Trans.", ' +
        '           "isDeleted": "N" ' +
        '       } ' +
        '    ] ' +
        '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_CelloApsDataSendController.saveData();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }
}