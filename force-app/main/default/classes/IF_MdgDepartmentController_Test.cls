/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-08-2021
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-12-30   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class IF_MdgDepartmentController_Test {

    // IF_MdgDepartmentController 테스트 클래스
    // INTERFACE_ID = 'IF-112';
    // APEX_CLASS   = 'IF_MdgDepartmentController';
    // METHOD_NAME  = 'regDepartment';

    final static String REQUEST_URL = '/services/apexrest/WebService/IF112';

    public IF_MdgDepartmentController_Test() {    }

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

        String reqeustBody =    '{ ' +
                                '    "TOTAL_COUNT": 0, ' +
                                '    "PAGE_COUNT": 50, ' +
                                '    "PAGE_NUM": 1, ' +
                                '    "DATA":[{ ' +
                                '        "KOSTL":"T100-10197", ' +
                                '        "DATBI":"4000-12-31", ' +
                                '        "KOKRS":"T100", ' +
                                '        "ABTEI":"C60AI133", ' +
                                '        "BKZER":"X", ' +
                                '        "BKZKP":"", ' +
                                '        "BKZKS":"", ' +
                                '        "BKZOB":"", ' +
                                '        "DATAB":"1900-01-01", ' +
                                '        "KHINR":"SDS_GLOBAL", ' +
                                '        "FUNC_AREA":"1000", ' +
                                '        "GSBER":"AT00", ' +
                                '        "KOSAR":"1", ' +
                                '        "MGEFL":"", ' +
                                '        "PKZER":"X", ' +
                                '        "PKZKP":"", ' +
                                '        "PKZKS":"", ' +
                                '        "PRCTR":"TA", ' +
                                '        "TXJCD":"", ' +
                                '        "VERAK":"IT운영팀", ' +
                                '        "VERAK_USER":"", ' +
                                '        "WAERS":"KRW", ' +
                                '        "ZZBRANCH":"1000", ' +
                                '        "ZZDELETE":"", ' +
                                '        "ZZPRFLG":"C", ' +
                                '        "ZZSECCODE":"SC01", ' +
                                '        "ZZEXPIRED":"", ' +
                                '        "ZZCHECK":"", ' +
                                '        "BUKRS":"T100", ' +
                                '        "ZZDUMMY":"", ' +
                                '        "CCTR_TEXT_DATA" : [{ ' +
                                '               "SPRAS":"KO", ' +
                                '               "KKTEXT": "", ' +
                                '               "KLTEXT": "IT운영팀", ' +
                                '               "EKTEXT": "IT운영팀", ' +
                                '               "ELTEXT": "IT운영팀" ' +
                                '        }] ' +
                                '    }, ' +
                                '    { ' +
                                '        "KOSTL":"T100-10197", ' +  // 중복건
                                '        "DATBI":"4000-12-31", ' +
                                '        "KOKRS":"T100", ' +
                                '        "ABTEI":"C60AI133", ' +
                                '        "BKZER":"X", ' +
                                '        "BKZKP":"", ' +
                                '        "BKZKS":"", ' +
                                '        "BKZOB":"", ' +
                                '        "DATAB":"1900-01-01", ' +
                                '        "KHINR":"SDS_GLOBAL", ' +
                                '        "FUNC_AREA":"1000", ' +
                                '        "GSBER":"AT00", ' +
                                '        "KOSAR":"1", ' +
                                '        "MGEFL":"", ' +
                                '        "PKZER":"X", ' +
                                '        "PKZKP":"", ' +
                                '        "PKZKS":"", ' +
                                '        "PRCTR":"TA", ' +
                                '        "TXJCD":"", ' +
                                '        "VERAK":"IT운영팀", ' +
                                '        "VERAK_USER":"", ' +
                                '        "WAERS":"KRW", ' +
                                '        "ZZBRANCH":"1000", ' +
                                '        "ZZDELETE":"", ' +
                                '        "ZZPRFLG":"C", ' +
                                '        "ZZSECCODE":"SC01", ' +
                                '        "ZZEXPIRED":"2020-12-31", ' +
                                '        "ZZCHECK":"", ' +
                                '        "BUKRS":"T100", ' +
                                '        "ZZDUMMY":"", ' +
                                '        "CCTR_TEXT_DATA" : [{ ' +
                                '               "SPRAS":"EN", ' +
                                '               "KKTEXT": "", ' +
                                '               "KLTEXT": "IT Operation Team", ' +
                                '               "EKTEXT": "IT Operation Team", ' +
                                '               "ELTEXT": "IT Operation Team" ' +
                                '        }] ' +
                                '    } ' + 
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_MdgDepartmentController.regDepartment();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }

    @isTest
    static void restServiceTest2() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';

        String reqeustBody =    '{ ' +
                                '    "TOTAL_COUNT": 0, ' +
                                '    "PAGE_COUNT": 50, ' +
                                '    "PAGE_NUM": 1, ' +
                                '    "DATA":[{ ' +
                                '        "KOSTL":"T100-10197", ' +
                                '        "DATBI":"4000-12-31", ' +
                                '        "KOKRS":"T100", ' +
                                '        "ABTEI":"C60AI133", ' +
                                '        "BKZER":"X", ' +
                                '        "BKZKP":"", ' +
                                '        "BKZKS":"", ' +
                                '        "BKZOB":"", ' +
                                '        "DATAB":"1900-01-01", ' +
                                '        "KHINR":"SDS_GLOBAL", ' +
                                '        "FUNC_AREA":"1000", ' +
                                '        "GSBER":"AT00", ' +
                                '        "KOSAR":"1", ' +
                                '        "MGEFL":"", ' +
                                '        "PKZER":"X", ' +
                                '        "PKZKP":"", ' +
                                '        "PKZKS":"", ' +
                                '        "PRCTR":"TA", ' +
                                '        "TXJCD":"", ' +
                                '        "VERAK":"IT운영팀", ' +
                                '        "VERAK_USER":"", ' +
                                '        "WAERS":"KRW", ' +
                                '        "ZZBRANCH":"1000", ' +
                                '        "ZZDELETE":"", ' +
                                '        "ZZPRFLG":"C", ' +
                                '        "ZZSECCODE":"SC01", ' +
                                '        "ZZEXPIRED":"", ' +
                                '        "ZZCHECK":"", ' +
                                '        "BUKRS":"T100", ' +
                                '        "ZZDUMMY":"", ' +
                                '        "CCTR_TEXT_DATA" : [{ ' +
                                '               "SPRAS":"KO", ' +
                                '               "KKTEXT": "", ' +
                                '               "KLTEXT": "IT운영팀", ' +
                                '               "EKTEXT": "IT운영팀", ' +
                                '               "ELTEXT": "IT운영팀" ' +
                                '        }] ' +
                                '    }, ' +
                                '    { ' +
                                '        "KOSTL":"T100-10197-2", ' +
                                '        "DATBI":"4000-12-31", ' +
                                '        "KOKRS":"T100", ' +
                                '        "ABTEI":"C60AI133", ' +
                                '        "BKZER":"X", ' +
                                '        "BKZKP":"", ' +
                                '        "BKZKS":"", ' +
                                '        "BKZOB":"", ' +
                                '        "DATAB":"1900-01-01", ' +
                                '        "KHINR":"SDS_GLOBAL", ' +
                                '        "FUNC_AREA":"1000", ' +
                                '        "GSBER":"AT00", ' +
                                '        "KOSAR":"1", ' +
                                '        "MGEFL":"", ' +
                                '        "PKZER":"X", ' +
                                '        "PKZKP":"", ' +
                                '        "PKZKS":"", ' +
                                '        "PRCTR":"TA", ' +
                                '        "TXJCD":"", ' +
                                '        "VERAK":"IT운영팀", ' +
                                '        "VERAK_USER":"", ' +
                                '        "WAERS":"KRW", ' +
                                '        "ZZBRANCH":"1000", ' +
                                '        "ZZDELETE":"", ' +
                                '        "ZZPRFLG":"C", ' +
                                '        "ZZSECCODE":"SC01", ' +
                                '        "ZZEXPIRED":"2020-12-31", ' +
                                '        "ZZCHECK":"", ' +
                                '        "BUKRS":"T100", ' +
                                '        "ZZDUMMY":"", ' +
                                '        "CCTR_TEXT_DATA" : [{ ' +
                                '               "SPRAS":"EN", ' +
                                '               "KKTEXT": "", ' +
                                '               "KLTEXT": "IT Operation Team", ' +
                                '               "EKTEXT": "IT Operation Team", ' +
                                '               "ELTEXT": "IT Operation Team" ' +
                                '        }] ' +
                                '    } ' + 
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_MdgDepartmentController.regDepartment();

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

            IF_MdgDepartmentController.regDepartment();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }
}