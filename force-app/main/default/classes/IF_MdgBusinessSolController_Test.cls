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
public class IF_MdgBusinessSolController_Test {

    // IF_MdgBusinessSolController 테스트 클래스
    // INTERFACE_ID = 'IF-109SOL';
    // APEX_CLASS   = 'IF_MdgBusinessSolController';
    // METHOD_NAME  = 'saveBusinessMaster';

    public IF_MdgBusinessSolController_Test() {    }

    @TestSetup
    static void makeData(){
        
    }

    @isTest 
    static void restServiceTest() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
//        request.requestURI = 'https://sdssfa--dev.my.salesforce.com/services/apexrest/WebService/IF109SOL';
        request.requestURI = '/services/apexrest/WebService/IF109SOL';        
        request.httpMethod = 'POST';

        String reqeustBody =    '{ ' +
                                '   "DATA":[ ' +
                                '       { ' +
                                '            "CLASS":"sol001", ' +
                                '            "HCLAS":"svc001", ' +
                                '            "KLAGR":"X", ' +
                                '            "VONDT":"20201201", ' +
                                '            "BISDT":"99991231", ' +
                                '            "USEYN":"Y", ' +
                                '            "SOLTY":"10", ' +
                                '            "PRDYN":"Y", ' +
                                '            "SOLMNC":"sol-1", ' +
                                '            "SOLMNT":"sol-11", ' +
                                '            "SOLDPC":"sol-111", ' +
                                '            "SOLDPT":"sol-1111", ' +
                                '            "BRAND":"X", ' +
                                '            "COMPC":"sol-11111", ' +
                                '            "PLLEV":"o", ' +
                                '            "PLCST":"A", ' +
                                '            "LODAT":"sol-111111", ' +
                                '            "EOPDT":"sol-1111111", ' +
                                '            "EOSDT":"sol-11111111" ' +
                                '       } ' +
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_MdgBusinessSolController.saveBusinessMaster();

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
//        request.requestURI = 'https://sdssfa--dev.my.salesforce.com/services/apexrest/WebService/IF109SOL';
        request.requestURI = '/services/apexrest/WebService/IF109SOL';        
        request.httpMethod = 'POST';

        String reqeustBody =    '{ ' +
                                '   "DATA":[ ' +
                                '       { ' +
                                '            "CLASS":"sol001", ' +
                                '            "HCLAS":"svc001", ' +
                                '            "KLAGR":"X", ' +
                                '            "VONDT":"20201201", ' +
                                '            "BISDT":"99991231", ' +
                                '            "USEYN":"Y", ' +
                                '            "SOLTY":"10", ' +
                                '            "PRDYN":"Y", ' +
                                '            "SOLMNC":"sol-1", ' +
                                '            "SOLMNT":"sol-11", ' +
                                '            "SOLDPC":"sol-111", ' +
                                '            "SOLDPT":"sol-1111", ' +
                                '            "BRAND":"X", ' +
                                '            "COMPC":"sol-11111", ' +
                                '            "PLLEV":"o", ' +
                                '            "PLCST":"A", ' +
                                '            "LODAT":"sol-111111", ' +
                                '            "EOPDT":"sol-1111111", ' +
                                '            "EOSDT":"sol-11111111" ' +
                                '       }, ' +
                                '       { ' +
                                '            "CLASS":"sol001", ' +
                                '            "HCLAS":"svc001", ' +
                                '            "KLAGR":"X", ' +
                                '            "VONDT":"20201201", ' +
                                '            "BISDT":"99991231", ' +
                                '            "USEYN":"Y", ' +
                                '            "SOLTY":"10", ' +
                                '            "PRDYN":"Y", ' +
                                '            "SOLMNC":"sol-1", ' +
                                '            "SOLMNT":"sol-11", ' +
                                '            "SOLDPC":"sol-111", ' +
                                '            "SOLDPT":"sol-1111", ' +
                                '            "BRAND":"X", ' +
                                '            "COMPC":"sol-11111", ' +
                                '            "PLLEV":"o", ' +
                                '            "PLCST":"A", ' +
                                '            "LODAT":"sol-111111", ' +
                                '            "EOPDT":"sol-1111111", ' +
                                '            "EOSDT":"sol-11111111" ' +
                                '       } ' +                                
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_MdgBusinessSolController.saveBusinessMaster();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }        
}