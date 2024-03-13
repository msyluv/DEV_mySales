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
public class IF_MdgBusinessCdescController_Test {

    // IF_MdgBusinessCdescController 테스트 클래스
    // INTERFACE_ID = 'IF-109CDESC';
    // APEX_CLASS   = 'IF_MdgBusinessCdescController';
    // METHOD_NAME  = 'saveBusinessMaster';    

    public IF_MdgBusinessCdescController_Test() {    }

    @TestSetup
    static void makeData(){
        
    }

    @isTest 
    static void restServiceTest() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
//        request.requestURI = 'https://sdssfa--dev.my.salesforce.com/services/apexrest/WebService/IF109CDESC';
        request.requestURI = '/services/apexrest/WebService/IF109CDESC';        
        request.httpMethod = 'POST';

        String reqeustBody =    '{ ' +
                                '   "DATA":[ ' +
                                '       { ' +
                                '            "CLASS":"biz001", ' +
                                '            "SPRAS":"E", ' +
                                '            "KLAGR":"X", ' +
                                '            "KSCHL":"biz001 English Name2", ' +
                                '            "NORMB":"X"  ' +
                                '       } ' +
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_MdgBusinessCdescController.saveBusinessMaster();

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
//        request.requestURI = 'https://sdssfa--dev.my.salesforce.com/services/apexrest/WebService/IF109CDESC';
        request.requestURI = '/services/apexrest/WebService/IF109CDESC';        
        request.httpMethod = 'POST';

        String reqeustBody =    '{ ' +
                                '   "DATA":[ ' +
                                '       { ' +
                                '            "CLASS":"biz001", ' +
                                '            "SPRAS":"E", ' +
                                '            "KLAGR":"X", ' +
                                '            "KSCHL":"biz001 English Name2", ' +
                                '            "NORMB":"X"  ' +
                                '       }, ' +
                                '       { ' +
                                '            "CLASS":"biz001", ' +
                                '            "SPRAS":"E", ' +
                                '            "KLAGR":"X", ' +
                                '            "KSCHL":"biz001 English Name2", ' +
                                '            "NORMB":"X"  ' +
                                '       } ' +                                
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_MdgBusinessCdescController.saveBusinessMaster();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }    
}