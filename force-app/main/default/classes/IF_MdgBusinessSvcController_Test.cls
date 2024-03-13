/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-08-2021
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-12-21   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class IF_MdgBusinessSvcController_Test {

    // IF_MdgBusinessSvcController 테스트 클래스
    // INTERFACE_ID = 'IF-109SVC';
    // APEX_CLASS   = 'IF_MdgBusinessSvcController';
    // METHOD_NAME  = 'saveBusinessMaster';

    public IF_MdgBusinessSvcController_Test() {    }

    @TestSetup
    static void makeData(){
        
    }

    @isTest 
    static void restServiceTest() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
//        request.requestURI = 'https://sdssfa--dev.my.salesforce.com/services/apexrest/WebService/IF109SVC';
        request.requestURI = '/services/apexrest/WebService/IF109SVC';        
        request.httpMethod = 'POST';

        String reqeustBody =    '{ ' +
                                '   "DATA":[ ' +
                                '       { ' +
                                '            "CLASS":"svc001", ' +
                                '            "HCLAS":"biz001", ' +
                                '            "KLAGR":"X", ' +
                                '            "VONDT":"20201201", ' +
                                '            "BISDT":"99991231", ' +
                                '            "USEYN":"Y", ' +
                                '            "SRVBNC":"svc3", ' +
                                '            "SRVBNT":"svc4", ' +
                                '            "SRVDPC":"svc5", ' +
                                '            "SRVDPT":"svc6"    ' +
                                '       } ' +
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_MdgBusinessSvcController.saveBusinessMaster();

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
//        request.requestURI = 'https://sdssfa--dev.my.salesforce.com/services/apexrest/WebService/IF109SVC';
        request.requestURI = '/services/apexrest/WebService/IF109SVC';        
        request.httpMethod = 'POST';

        String reqeustBody =    '{ ' +
                                '   "DATA":[ ' +
                                '       { ' +
                                '            "CLASS":"svc001", ' +
                                '            "HCLAS":"biz001", ' +
                                '            "KLAGR":"X", ' +
                                '            "VONDT":"20201201", ' +
                                '            "BISDT":"99991231", ' +
                                '            "USEYN":"Y", ' +
                                '            "SRVBNC":"svc3", ' +
                                '            "SRVBNT":"svc4", ' +
                                '            "SRVDPC":"svc5", ' +
                                '            "SRVDPT":"svc6"    ' +
                                '       }, ' +
                                '       { ' +
                                '            "CLASS":"svc001", ' +
                                '            "HCLAS":"biz001", ' +
                                '            "KLAGR":"X", ' +
                                '            "VONDT":"20201201", ' +
                                '            "BISDT":"99991231", ' +
                                '            "USEYN":"Y", ' +
                                '            "SRVBNC":"svc3", ' +
                                '            "SRVBNT":"svc4", ' +
                                '            "SRVDPC":"svc5", ' +
                                '            "SRVDPT":"svc6"    ' +
                                '       } ' +                                
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_MdgBusinessSvcController.saveBusinessMaster();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }        
}