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
public class IF_CelloCreditRatingSendController_Test {
    final static String REQUEST_URL = '/services/apexrest/WebService/IF120';
    static Account acc = Utils_TestDataFactory.createAccount('TestAcc');
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
        '           "Name": "201901OSK0002", ' +
        '           "Opportunity": "'+oppty.id+'", ' +
        '           "CompanyName": "MAT Brakes India Pvt Ltd", ' +
        '           "Status": "DC", ' +
        '           "Grade": "B2", ' +
        '           "ValidetoDate": "2019-01-01", ' +
        '           "ShipperID": "SL564", ' +
        '           "USEYN": "Y", ' +
        '           "IsBlocked": "N" ' +
        '       } ' +
        '    ] ' +
        '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_CelloCreditRatingSendController.saveData();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }

    @isTest 
    static void restServiceTestDelete() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;        
        request.httpMethod = 'POST';

        String reqeustBody = 
        '{ ' +
        '    "DATA": [ ' +
        '       { ' +
        '           "Name": "201901OSK0002", ' +
        '           "Opportunity": "'+oppty.id+'", ' +
        '           "CompanyName": "MAT Brakes India Pvt Ltd", ' +
        '           "Status": "DC", ' +
        '           "Grade": "B2", ' +
        '           "ValidetoDate": "2019-01-01", ' +
        '           "ShipperID": "SL564", ' +
        '           "USEYN": "N", ' +
        '           "IsBlocked": "N" ' +
        '       } ' +
        '    ] ' +
        '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_CelloCreditRatingSendController.saveData();

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

            IF_CelloCreditRatingSendController.saveData();

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
        '           "Name": "201901OSK0002", ' +
        '           "Opportunity": "'+oppty.id+'", ' +
        '           "CompanyName": "MAT Brakes India Pvt Ltd", ' +
        '           "Status": "DC", ' +
        '           "Grade": "B2", ' +
        '           "ValidetoDate": "2019-01-01", ' +
        '           "ShipperID": "SL564", ' +
        '           "USEYN": "Y", ' +
        '           "IsBlocked": "N" ' +
        '       } ' +
        '    ] ' +
        '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_CelloCreditRatingSendController.saveData();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }
}