/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-25
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-12-28   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class IF_EccProjectStatusController_Test {

    // IF_EccProjectStatusController 테스트 클래스
    // INTERFACE_ID = 'IF-007';
    // APEX_CLASS   = 'IF_EccProjectStatusController';
    // METHOD_NAME  = 'updateProjectSatus';

    public IF_EccProjectStatusController_Test() {    }

    final static String REQUEST_URL = '/services/apexrest/WebService/IF007';

    @TestSetup
    static void makeData(){

        IF_Callout_TestDataSetup.dataSetup();
    }

    @isTest
    static void restServiceTest() { // Exception Cover 되도록 해야 함
        Test.startTest();

        List<Project__c> selectProjectList = [
            Select  Id
                    , ProjectCode__c
            From    Project__c
        ];

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';

        String reqeustBody =    '{ ' +
                                '   "DATA":[ ' +
                                '       { ' +
                                '            "BUKRS": "T100", ' +
                                // '            "PSPID": "SIC-20055891-A0", ' +
                                '            "PSPID": "' + selectProjectList[0].ProjectCode__c + '", ' +
                                '            "DELETE_FLAG":"X" ' +
                                '       }, ' +
                                '       { ' +
                                '            "BUKRS": "T100", ' +
                                // '            "PSPID": "SIC-20055891-A1", ' +
                                '            "PSPID": "' + selectProjectList[1].ProjectCode__c + '", ' +
                                '            "DELETE_FLAG":"_" ' +
                                '       } ' +                                
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_EccProjectStatusController.updateProjectSatus();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }

    @isTest
    static void restServiceTest_noData() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';

        String reqeustBody =    '{ ' +
                                '   "DATA":[   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_EccProjectStatusController.updateProjectSatus();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }
}