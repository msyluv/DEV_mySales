/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-08-2021
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                        Modification
 * 1.0   2020-12-02   ghkil@partner.samsung.com     Initial Version
 * 1.0.1 2020-12-16   raegganja@partner.samsung.com class name change
**/
@isTest
public class IF_EccOpportunityInfoController_Test {

    // IF_EccOpportunityInfoController 테스트 클래스
    // INTERFACE_ID = 'IF-015';
    // APEX_CLASS   = 'IF_EccOpportunityInfoController';
    // METHOD_NAME  = 'getOpportunityInfo';

    public IF_EccOpportunityInfoController_Test() { }

    static final String REQUEST_DATA = 	'{' +    
                                        '  "IV_ROSEQ": "201612001", ' +
                                        '  "IV_HQ_FLAG": "Y", ' +
                                        '  "TT_OPPORT_H":[ ' +
                                        '			{ ' + 
                                        '			  "GUBUN": "H", ' +
                                        '			  "BUKRS": "T100", ' +
                                        '			  "ZZORDER_ID": "SDS-16300280", ' +
                                        '			  "DESCRIPTION": "[삼성에스디아이 (주)]울산 PACK라인 FA망 NW 구매대행공급", ' +
                                        '			  "PARTNER": "29581", ' +
                                        '			  "NAME_LAST": "최송", ' +
                                        '			  "NUMBER_INT": "0", ' +
                                        '			  "ZZSERVICE": "", ' +
                                        '			  "ZZSERVICE_DESC": "", ' +
                                        '			  "ZZSLSDEPT_B": "T100-11961", ' +
                                        '			  "ZZSLSDEPT_B_DESC": "사업그룹(스마트팩토리)", ' +
                                        '			  "ZZDLVDEPT_B": "T100-11493", ' +
                                        '			  "ZZDLVDEPT_B_DESC": "네트워크그룹(제조)" ' +
                                        '			}, ' +
                                        '			{ ' +
                                        '			  "GUBUN": "I", ' +
                                        '			  "BUKRS": "T100", ' +
                                        '			  "ZZORDER_ID": "SDS-16300280", ' +
                                        '			  "DESCRIPTION": "[삼성에스디아이 (주)]울산 PACK라인 FA망 NW 구매대행공급", ' +
                                        '			  "PARTNER": "29581", ' +
                                        '			  "NAME_LAST": "최송", ' +
                                        '			  "NUMBER_INT": "10", ' +
                                        '			  "ZZSERVICE": "20000020", ' +
                                        '			  "ZZSERVICE_DESC": "Network", ' +
                                        '			  "ZZSLSDEPT_B": "T100-11961", ' +
                                        '			  "ZZSLSDEPT_B_DESC": "사업그룹(스마트팩토리)", ' +
                                        '			  "ZZDLVDEPT_B": "T100-11493", ' +
                                        '			  "ZZDLVDEPT_B_DESC": "네트워크그룹(제조)" ' +
                                        '			} ' +
                                        '	] ' +
                                        '}';
                                        
    @TestSetup
    static void makeData(){    }

    @isTest
    static void testCallout() {
        Test.startTest();
                        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Map<String, Object> result = IF_EccOpportunityInfoController.getOpportunityInfo(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 200);

        HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
        List<Object> dataList = (List<Object>)returnMap.get('TT_KOSTL');

        Map<String, Object> dataMap = (Map<String, Object>)dataList[0];
        System.assertEquals(String.valueOf(dataMap.get('KOSTL')), 'T100-10022');

        Test.stopTest();
    }

    @isTest
    static void testCallout400() {
        Test.startTest();
                        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        Map<String, Object> result = IF_EccOpportunityInfoController.getOpportunityInfo(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 400);
        
        Test.stopTest();
    }

    @isTest
    static void testCalloutError() {
        Test.startTest();

        IF_EccOpportunityInfoController.getOpportunityInfo('Error');

        Test.stopTest();
    }    
}