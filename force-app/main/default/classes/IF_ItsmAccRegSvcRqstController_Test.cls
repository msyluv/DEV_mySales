/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-03-17
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                          Modification
 * 1.0   2020-12-17   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class IF_ItsmAccRegSvcRqstController_Test {
    static final String REQUEST_DATA = 	
    '{' +
    '  "srcertid": "IT-VOC", ' +
    '  "CallDataWithWorkVOV2": [ ' +
    '	{ ' +
    '     "EXTNL_SYS_ID": "IT-VOC", ' +
    '     "SERV_CALL_RLSE_NO": "SF202012101013200001", ' +
    '     "TITLE": "SFDC MDG 데이터 등록 요청 건.", ' +
    '     "REQ_CTNT": "요청내용을 상세하게 등록바랍니다.", ' +
    '     "REQ_CTNT_TP_CD": "T", ' +
    '     "REQ_DTM": "20201210233313", ' +
    '     "END_REQ_DTM": "20201810233313", ' +
    '     "START_SCHED_DTM": "", ' +
    '     "APPLYR_ID": "", ' +
    '     "APPLYR_EMP_NO": "16241", ' +
    '     "IS_APPLYR_EMP_NO": "Y", ' +
    '     "APPLYR_NM": "김경남", ' +
    '     "REGR_ID": "S020126190831C600013", ' +
    '     "REGR_NM": "김경남", ' +
    '     "ATCH_FILE_YN": "N", ' +
    '     "END_SCHED_DTM": "", ' +
    '     "MAILING_YN": "Y", ' +
    '     "URG_YN": "Y", ' +
    '     "SRVC_KEY": "SR201010261401201986660", ' +
    '     "CUST_COMP_CD": "C60", ' +
    '     "CUST_ORG_CD": "C60AH319", ' +
    '     "CUST_COMP_KEY": "CU200703230441191491343", ' +
    '     "REG_IP_ADDR": "", ' +
    '     "IRP_CODE": "", ' +
    '     "IRP_NAME": "" ' +
    '	} ' +
    '  ] ' +
    '}';

    public IF_ItsmAccRegSvcRqstController_Test() {

    }

    @TestSetup
    static void makeData(){
        
    }

    @isTest
    static void testCallout() {
        Test.startTest();
                        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Map<String,Object> result =  IF_ItsmAccRegSvcRqstController.accRegSvcRqst(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 200);
        
        HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());

        System.assertEquals(String.valueOf(returnMap.get('RET_SUCCS_CD')), 'Y');

        Test.stopTest();
    }

    @isTest
    static void testCallout400() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        Map<String, Object> result = IF_ItsmAccRegSvcRqstController.accRegSvcRqst(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 400);

        Test.stopTest();
    }

    @isTest
    static void testCalloutError() {
        Test.startTest();

        Map<String,Object> result =  IF_ItsmAccRegSvcRqstController.accRegSvcRqst(REQUEST_DATA);

        Test.stopTest();
    }
}