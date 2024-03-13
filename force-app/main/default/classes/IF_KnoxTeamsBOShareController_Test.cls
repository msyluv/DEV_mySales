/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-08
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2021-01-08   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class IF_KnoxTeamsBOShareController_Test {
    final static String REQUEST_URL = '/services/apexrest/WebService/IF083';
    static Account acc = Utils_TestDataFactory.createAccount('TestAcc');
    static Opportunity oppty = Utils_TestDataFactory.createOpportunity('TestOppty', acc.id, 'SDS-XXXXXXXX', '');

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
        '           "appId": "5db79d6c-86a8-4c15-9f9d-442f03359a4c", ' +
        '           "workspaceId": "12125", ' +
        '           "channelId": "101771013407641000", ' +
        '           "userId": "825392860624326000", ' +
        '           "messageId": "1587652967730", ' +
        '           "localDate": "2020-02-21", ' +
        '           "localTime": "16:57:31", ' +
        '           "timeZone": "+09:0", ' +
        '           "language": "ko", ' +
        '           "requestUrl": "https://app-server.com/api/v1/action", ' +
        '           "ID": "'+oppty.OpportunityCode__c+'" ' +
        '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_KnoxTeamsBOShareController.shareBO();

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
        '           "appId": "5db79d6c-86a8-4c15-9f9d-442f03359a4c", ' +
        '           "workspaceId": "12125", ' +
        '           "channelId": "101771013407641000", ' +
        '           "userId": "825392860624326000", ' +
        '           "messageId": "1587652967730", ' +
        '           "localDate": "2020-02-21", ' +
        '           "localTime": "16:57:31", ' +
        '           "timeZone": "+09:0", ' +
        '           "language": "ko", ' +
        '           "requestUrl": "https://app-server.com/api/v1/action", ' +
        '           "ID": "XXXXX" ' +
        '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_KnoxTeamsBOShareController.shareBO();

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
        '           "appId": "5db79d6c-86a8-4c15-9f9d-442f03359a4c", ' +
        '           "workspaceId": "12125", ' +
        '           "channelId": "101771013407641000", ' +
        '           "userId": "825392860624326000", ' +
        '           "messageId": "1587652967730", ' +
        '           "localDate": "2020-02-21", ' +
        '           "localTime": "16:57:31", ' +
        '           "timeZone": "+09:0", ' +
        '           "language": "ko", ' +
        '           "requestUrl": "https://app-server.com/api/v1/action", ' +
        '           "ID": "'+oppty.OpportunityCode__c+'" ' +
        '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_KnoxTeamsBOShareController.shareBO();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }
}