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
public class IF_MdgBusinessBizController_Test {
 
    // IF_MdgBusinessBizController 테스트 클래스
    // NTERFACE_ID = 'IF-109BIZ';
    // PEX_CLASS   = 'IF_MdgBusinessBizController';
    // ETHOD_NAME  = 'saveBusinessMaster';    

    public IF_MdgBusinessBizController_Test() {    }

    @TestSetup
    static void makeData(){
        
    }

    @isTest 
    static void restServiceTest() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
//        request.requestURI = 'https://sdssfa--dev.my.salesforce.com/services/apexrest/WebService/IF109BIZ';
        request.requestURI = '/services/apexrest/WebService/IF109BIZ';        
        request.httpMethod = 'POST';

        String reqeustBody =    '{ ' +
                                '   "DATA":[ ' +
                                '       { ' +
                                '           "CLASS":"BIZ001T", ' +
                                '           "HCLAS":"X", ' +
                                '           "KLAGR":"XX", ' +
                                '           "VONDT":"20201221", ' +
                                '           "BISDT":"99991231", ' +
                                '           "USEYN":"Y" ' +
                                '       } ' +
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_MdgBusinessBizController.saveBusinessMaster();

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
//        request.requestURI = 'https://sdssfa--dev.my.salesforce.com/services/apexrest/WebService/IF109BIZ';
        request.requestURI = '/services/apexrest/WebService/IF109BIZ';        
        request.httpMethod = 'POST';

        String reqeustBody =    '{ ' +
                                '   "DATA":[ ' +
                                '       { ' +
                                '           "CLASS":"BIZ001T", ' +
                                '           "HCLAS":"X", ' +
                                '           "KLAGR":"XX", ' +
                                '           "VONDT":"20201221", ' +
                                '           "BISDT":"99991231", ' +
                                '           "USEYN":"Y" ' +
                                '       }, ' +
                                '       { ' +
                                '           "CLASS":"BIZ001T", ' +
                                '           "HCLAS":"X", ' +
                                '           "KLAGR":"XX", ' +
                                '           "VONDT":"20201221", ' +
                                '           "BISDT":"99991231", ' +
                                '           "USEYN":"Y" ' +
                                '       } ' +                                
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_MdgBusinessBizController.saveBusinessMaster();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }    
}