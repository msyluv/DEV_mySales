/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-22
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-12-30   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class IF_EccEmployRegController_Test {

    // IF_EccEmployRegController 테스트 클래스
    // INTERFACE_ID = 'IF-118';
    // APEX_CLASS   = 'IF_EccEmployRegController';
    // METHOD_NAME  = 'regEmployeeInfo';

    final static String REQUEST_URL = '/services/apexrest/WebService/IF118';

    public IF_EccEmployRegController_Test() {    }

    @TestSetup
    static void makeData(){

        IF_Callout_TestDataSetup.dataSetup();

    }

    @isTest
    static void restServiceTest() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';

        String reqeustBody =    '{ ' +
                                '   "DATA":[ ' +
                                '       { ' +
                                '            "EV_SAP_EMPNO": "111", ' +
                                '            "EV_ACUBE_ID": "data1", ' +
                                '            "EV_EMPNO": "data1", ' +
                                '            "EV_UNIQ_ID": "data1", ' +
                                '            "EV_HNAME": "data1", ' +
                                '            "EV_ENAME": "data1", ' +
                                '            "EV_COMPANY": "data1", ' +
                                '            "EV_SAP_BUKRS": "1", ' +
                                '            "EV_COMPNM": "data1", ' +
                                '            "EV_JIKGUB": "data1", ' +
                                '            "EV_JIKGUBNM": "data1", ' +
                                '            "EV_TITLE_JIKCHAK_NM": "data1", ' +
                                '            "EV_DEPT": "data1", ' +
                                '            "EV_SDEPTNM": "data1", ' +
                                '            "EV_KOSTL": "data1", ' +
                                '            "EV_CELL_TEL": "data1", ' +
                                '            "EV_COMP_TEL": "data1", ' +
                                '            "EV_SAP_USRID": "data1", ' +
                                '            "EV_MAIL_ADDR": "data1", ' +
                                '            "EV_STATUS": "1", ' +
                                '            "EV_MAIL_RELANGUAGE": "data1", ' +
                                '            "EV_COMPENM": "data1", ' +
                                '            "EV_SDEPTENM": "data1", ' +
                                '            "EV_TITLE_JIKCHAK_EN": "data1", ' +
                                '            "EV_GSBER": "data1", ' +
                                '            "EV_FLAG": "X" ' +
                                '       }, ' +
                                '       { ' +
                                '            "EV_SAP_EMPNO": "111", ' +
                                '            "EV_ACUBE_ID": "data1", ' +
                                '            "EV_EMPNO": "data1", ' +
                                '            "EV_UNIQ_ID": "data1", ' + // 중복
                                '            "EV_HNAME": "data1", ' +
                                '            "EV_ENAME": "data1", ' +
                                '            "EV_COMPANY": "data2", ' + // 위 데이터와 다름 (ExcternalId 확인)
                                '            "EV_SAP_BUKRS": "1", ' +
                                '            "EV_COMPNM": "data1", ' +
                                '            "EV_JIKGUB": "data1", ' +
                                '            "EV_JIKGUBNM": "data1", ' +
                                '            "EV_TITLE_JIKCHAK_NM": "data1", ' +
                                '            "EV_DEPT": "data1", ' +
                                '            "EV_SDEPTNM": "data1", ' +
                                '            "EV_KOSTL": "data1", ' +
                                '            "EV_CELL_TEL": "data1", ' +
                                '            "EV_COMP_TEL": "data1", ' +
                                '            "EV_SAP_USRID": "data1", ' +
                                '            "EV_MAIL_ADDR": "data1", ' +
                                '            "EV_STATUS": "1", ' +
                                '            "EV_MAIL_RELANGUAGE": "data1", ' +
                                '            "EV_COMPENM": "data1", ' +
                                '            "EV_SDEPTENM": "data1", ' +
                                '            "EV_TITLE_JIKCHAK_EN": "data1", ' +
                                '            "EV_GSBER": "data1", ' +
                                '            "EV_FLAG": "X" ' +
                                '       } ' +                                
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_EccEmployRegController.regEmployeeInfo();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }

    @isTest
    static void restServiceTest2() {        // 중복으로 Exception 체크
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';

        String reqeustBody =    '{ ' +
                                '   "DATA":[ ' +
                                '       { ' +
                                '            "EV_SAP_EMPNO": "111", ' +
                                '            "EV_ACUBE_ID": "data1", ' +
                                '            "EV_EMPNO": "data1", ' +
                                '            "EV_UNIQ_ID": "uniq1", ' +
                                '            "EV_HNAME": "data1", ' +
                                '            "EV_ENAME": "data1", ' +
                                '            "EV_COMPANY": "data1", ' +
                                '            "EV_SAP_BUKRS": "1", ' +
                                '            "EV_COMPNM": "data1", ' +
                                '            "EV_JIKGUB": "data1", ' +
                                '            "EV_JIKGUBNM": "data1", ' +
                                '            "EV_TITLE_JIKCHAK_NM": "data1", ' +
                                '            "EV_DEPT": "data1", ' +
                                '            "EV_SDEPTNM": "data1", ' +
                                '            "EV_KOSTL": "data1", ' +
                                '            "EV_CELL_TEL": "data1", ' +
                                '            "EV_COMP_TEL": "data1", ' +
                                '            "EV_SAP_USRID": "data1", ' +
                                '            "EV_MAIL_ADDR": "data1", ' +
                                '            "EV_STATUS": "1", ' +
                                '            "EV_MAIL_RELANGUAGE": "data1", ' +
                                '            "EV_COMPENM": "data1", ' +
                                '            "EV_SDEPTENM": "data1", ' +
                                '            "EV_TITLE_JIKCHAK_EN": "data1", ' +
                                '            "EV_GSBER": "data1", ' +
                                '            "EV_FLAG": "X" ' +
                                '       }, ' +
                                '       { ' +
                                '            "EV_SAP_EMPNO": "111", ' +
                                '            "EV_ACUBE_ID": "data1", ' +
                                '            "EV_EMPNO": "data1", ' +
                                '            "EV_UNIQ_ID": "uniq1", ' +     // 중복
                                '            "EV_HNAME": "data1", ' +
                                '            "EV_ENAME": "data1", ' +
                                '            "EV_COMPANY": "data1", ' +
                                '            "EV_SAP_BUKRS": "1", ' +
                                '            "EV_COMPNM": "data1", ' +
                                '            "EV_JIKGUB": "data1", ' +
                                '            "EV_JIKGUBNM": "data1", ' +
                                '            "EV_TITLE_JIKCHAK_NM": "data1", ' +
                                '            "EV_DEPT": "data1", ' +
                                '            "EV_SDEPTNM": "data1", ' +
                                '            "EV_KOSTL": "data1", ' +
                                '            "EV_CELL_TEL": "data1", ' +
                                '            "EV_COMP_TEL": "data1", ' +
                                '            "EV_SAP_USRID": "data1", ' +
                                '            "EV_MAIL_ADDR": "data1", ' +
                                '            "EV_STATUS": "1", ' +
                                '            "EV_MAIL_RELANGUAGE": "data1", ' +
                                '            "EV_COMPENM": "data1", ' +
                                '            "EV_SDEPTENM": "data1", ' +
                                '            "EV_TITLE_JIKCHAK_EN": "data1", ' +
                                '            "EV_GSBER": "data1", ' +
                                '            "EV_FLAG": "X" ' +
                                '       } ' +                                
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_EccEmployRegController.regEmployeeInfo();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }

    @isTest
    static void restServiceTest3() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';

        String reqeustBody =    '{ ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_EccEmployRegController.regEmployeeInfo();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }
}